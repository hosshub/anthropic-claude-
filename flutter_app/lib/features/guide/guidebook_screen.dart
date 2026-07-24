import 'package:flutter/material.dart';

import '../../data/guidebook_data.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';
import '../../widgets/nutrition_summary.dart';
import '../../widgets/zone_badge.dart';
import '../capture/capture_screen.dart';

/// دليل الوجبات الكامل: وجبات جاهزة بفئات (فطور/غداء/عشاء/سناك/صيام) مع
/// المكوّنات وطريقة التحضير والتقديرات الغذائية. البحث والتصفية محليان.
class GuidebookScreen extends StatefulWidget {
  const GuidebookScreen({super.key});

  @override
  State<GuidebookScreen> createState() => _GuidebookScreenState();
}

class _GuidebookScreenState extends State<GuidebookScreen> {
  GuidebookCategory? _category;
  String _query = '';

  String _categoryLabel(AppLocalizations l, GuidebookCategory? c) {
    switch (c) {
      case null:
        return l.guidebook_cat_all;
      case GuidebookCategory.breakfast:
        return l.guidebook_cat_breakfast;
      case GuidebookCategory.lunch:
        return l.guidebook_cat_lunch;
      case GuidebookCategory.dinner:
        return l.guidebook_cat_dinner;
      case GuidebookCategory.snack:
        return l.guidebook_cat_snack;
      case GuidebookCategory.fasting:
        return l.guidebook_cat_fasting;
    }
  }

  List<GuidebookMeal> _filtered(String locale) {
    var meals = GuidebookData.byCategory(_category);
    final q = _query.trim();
    if (q.isNotEmpty) {
      meals = meals
          .where((m) =>
              m.nameAr.contains(q) ||
              m.nameEn.toLowerCase().contains(q.toLowerCase()) ||
              m.components(locale).any((c) =>
                  c.toLowerCase().contains(q.toLowerCase())))
          .toList();
    }
    return meals;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final meals = _filtered(locale);

    return Scaffold(
      appBar: AppBar(title: Text(l.guidebook_title)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: l.guidebook_searchHint,
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  filled: true,
                  fillColor: TColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  for (final c in <GuidebookCategory?>[
                    null,
                    ...GuidebookCategory.values,
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(_categoryLabel(l, c)),
                        selected: _category == c,
                        selectedColor: TColors.primary,
                        labelStyle: TextStyle(
                          color: _category == c
                              ? Colors.white
                              : TColors.textPrimary,
                          fontSize: 13,
                        ),
                        onSelected: (_) => setState(() => _category = c),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: meals.isEmpty
                  ? Center(
                      child: Text(
                        l.guidebook_empty,
                        style:
                            const TextStyle(color: TColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: meals.length,
                      itemBuilder: (_, i) => _MealCard(
                        meal: meals[i],
                        categoryLabel:
                            _categoryLabel(l, meals[i].category),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final GuidebookMeal meal;
  final String categoryLabel;
  const _MealCard({required this.meal, required this.categoryLabel});

  void _openDetail(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        maxChildSize: 0.94,
        builder: (ctx, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TColors.textSecondary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meal.name(locale),
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: TColors.textPrimary,
                      ),
                    ),
                  ),
                  ZoneBadge(zone: meal.zone),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                categoryLabel,
                style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.guidebook_components,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: TColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final c in meal.components(locale))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('• $c',
                            style: const TextStyle(height: 1.6)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.guidebook_prep,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: TColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      meal.prep(locale),
                      style: const TextStyle(height: 1.7, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l.guidebook_approxNutrition,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: TColors.primary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          l.nutrition_kcalValue(meal.kcal),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: TColors.primary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    MacroRow(nutrition: meal.nutrition),
                    const SizedBox(height: 8),
                    Text(
                      l.nutrition_estimateNote,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: TColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const CaptureScreen()),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: Text(l.mealBanks_capture),
                style: FilledButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name(locale),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$categoryLabel • ${l.nutrition_kcalValue(meal.kcal)}',
                        style: const TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                ZoneBadge(zone: meal.zone),
                const SizedBox(width: 6),
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  color: TColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
