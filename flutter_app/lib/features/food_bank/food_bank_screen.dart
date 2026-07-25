import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/food_bank_data.dart';
import '../../data/meal_repository.dart';
import '../../l10n/enum_labels.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/health_service.dart';
import '../../theme/theme.dart';
import '../../widgets/zone_badge.dart';

/// بنك الطعام: بحث عن الأصناف المصرية/العربية وتسجيلها كوجبة بلا تصوير.
class FoodBankScreen extends StatefulWidget {
  const FoodBankScreen({super.key});

  @override
  State<FoodBankScreen> createState() => _FoodBankScreenState();
}

class _FoodBankScreenState extends State<FoodBankScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  FoodBankCategory? _category;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _catLabel(AppLocalizations l, FoodBankCategory? c) => switch (c) {
        null => l.foodBank_cat_all,
        FoodBankCategory.breakfast => l.foodBank_cat_breakfast,
        FoodBankCategory.lunch => l.foodBank_cat_lunch,
        FoodBankCategory.dinner => l.foodBank_cat_dinner,
        FoodBankCategory.street => l.foodBank_cat_street,
        FoodBankCategory.drink => l.foodBank_cat_drink,
        FoodBankCategory.sweet => l.foodBank_cat_sweet,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final results = searchFoodBank(_query, category: _category);
    return Scaffold(
      appBar: AppBar(title: Text(l.foodBank_title)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: TextField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l.foodBank_searchHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() {
                            _search.clear();
                            _query = '';
                          }),
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final c in <FoodBankCategory?>[null, ...FoodBankCategory.values])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(_catLabel(l, c)),
                        selected: _category == c,
                        onSelected: (_) => setState(() => _category = c),
                        selectedColor: TColors.primary.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: _category == c
                              ? TColors.primary
                              : TColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(
                        l.foodBank_empty,
                        style: const TextStyle(color: TColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) =>
                          _FoodRow(item: results[i], locale: locale),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodRow extends StatelessWidget {
  final FoodBankItem item;
  final String locale;
  const _FoodRow({required this.item, required this.locale});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Material(
      color: TColors.surface,
      borderRadius: BorderRadius.circular(TRadii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(TRadii.card),
        onTap: () => _openDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name(locale),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.nutrition_kcalValue(item.caloriesKcal),
                      style: const TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              ZoneBadge(zone: item.zone),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: TColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDetail(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TColors.background,
      builder: (_) => _FoodDetailSheet(item: item, locale: locale),
    );
  }
}

class _FoodDetailSheet extends StatefulWidget {
  final FoodBankItem item;
  final String locale;
  const _FoodDetailSheet({required this.item, required this.locale});

  @override
  State<_FoodDetailSheet> createState() => _FoodDetailSheetState();
}

class _FoodDetailSheetState extends State<_FoodDetailSheet> {
  int _portions = 1;
  bool _logging = false;

  Future<void> _log() async {
    final l = AppLocalizations.of(context)!;
    setState(() => _logging = true);
    final repo = context.read<MealRepository>();
    final health = context.read<HealthService>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final meal = await repo.logFromFoodBank(widget.item, portions: _portions);
    unawaited(health.writeMealEnergy(
      kcal: meal.nutrition?.caloriesKcal ?? 0,
      at: meal.capturedAt,
    ));
    HapticFeedback.lightImpact();
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text(l.foodBank_logged)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final it = widget.item;
    final loc = widget.locale;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    it.name(loc),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ZoneBadge(zone: it.zone),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${foodZoneLabel(l, it.zone)} • ${it.portion(loc)}',
              style: const TextStyle(color: TColors.textSecondary, fontSize: 13),
            ),
            if (it.note(loc) != null) ...[
              const SizedBox(height: 8),
              Text(
                it.note(loc)!,
                style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 14),
            _NutritionStrip(item: it, portions: _portions),
            const SizedBox(height: 6),
            Text(
              l.foodBank_approxNote,
              style: const TextStyle(
                color: TColors.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(l.foodBank_portions,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  onPressed: _portions > 1
                      ? () => setState(() => _portions--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: TColors.primary,
                ),
                Text('$_portions',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
                IconButton(
                  onPressed: _portions < 10
                      ? () => setState(() => _portions++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                  color: TColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _logging ? null : _log,
                icon: _logging
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.add),
                label: Text(l.foodBank_log),
                style: FilledButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionStrip extends StatelessWidget {
  final FoodBankItem item;
  final int portions;
  const _NutritionStrip({required this.item, required this.portions});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    Widget cell(String label, String value, Color c) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(value,
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: c, fontSize: 15)),
                const SizedBox(height: 2),
                Text(label,
                    style: const TextStyle(
                        color: TColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        );
    String g(double v) => (v * portions).toStringAsFixed(0);
    return Row(
      children: [
        cell(l.nutrition_kcalUnit, '${item.caloriesKcal * portions}',
            TColors.gold),
        cell(l.nutrition_protein, g(item.proteinG), TColors.zoneGreen),
        cell(l.nutrition_carbs, g(item.carbsG), TColors.gold),
        cell(l.nutrition_fat, g(item.fatG), TColors.primary),
      ],
    );
  }
}
