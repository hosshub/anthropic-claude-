import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/meal_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/analysis_result.dart';
import '../../models/meal.dart';
import '../../services/notification_service.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';
import '../../widgets/zone_badge.dart';
import '../body_response/body_response_card.dart';
import '../body_response/body_response_flow.dart';

/// تفاصيل وجبة محفوظة. تُعاد القراءة من المستودع عند العودة من تدفّق الجسم.
class MealDetailScreen extends StatefulWidget {
  final String mealId;
  const MealDetailScreen({super.key, required this.mealId});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  Future<Meal?>? _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = context.read<MealRepository>().load(widget.mealId);
  }

  Future<void> _openBodyResponse(Meal meal) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => BodyResponseFlow(meal: meal),
      ),
    );
    if (!mounted) return;
    setState(_reload);
  }

  Future<void> _delete(Meal meal) async {
    final l = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.mealDetail_deleteTitle),
        content: Text(l.mealDetail_deleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.common_cancel),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(foregroundColor: TColors.khabith),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.common_delete),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await context.read<NotificationService>().cancelBodyFollowup(meal.id);
    if (!mounted) return;
    await context.read<MealRepository>().delete(meal.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MealRepository>();
    // إعادة التحميل عند أي تغيير في المستودع (مثلاً بعد حفظ متابعة الجسم).
    _future ??= repo.load(widget.mealId);

    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.mealDetail_title),
      ),
      body: FutureBuilder<Meal?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final meal = snap.data;
          if (meal == null) {
            return Center(child: Text(l.mealDetail_notFound));
          }
          return _body(meal);
        },
      ),
    );
  }

  Widget _body(Meal meal) {
    final l = AppLocalizations.of(context)!;
    final scoreColor = TColors.scoreColor(meal.overallScore);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _mealImage(meal),
          const SizedBox(height: 18),
          CardContainer(
            child: Column(
              children: [
                Text(
                  '${meal.overallScore}%',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w800,
                    color: scoreColor,
                  ),
                ),
                if (meal.scoreLabelAr.isNotEmpty)
                  Text(
                    meal.scoreLabelAr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: scoreColor,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(meal.capturedAt),
                  style: const TextStyle(
                    color: TColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (meal.scoreExplanationAr.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    meal.scoreExplanationAr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: TColors.textSecondary,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            l.mealDetail_items,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          ...meal.items.map(_itemCard),
          const SizedBox(height: 14),
          if (meal.bodyResponse != null)
            BodyResponseCard(
              response: meal.bodyResponse!,
              onEdit: () => _openBodyResponse(meal),
            )
          else
            OutlinedButton.icon(
              onPressed: () => _openBodyResponse(meal),
              icon: const Icon(Icons.favorite_border),
              label: Text(l.mealDetail_logBodyResponse),
              style: OutlinedButton.styleFrom(
                foregroundColor: TColors.primary,
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: TColors.primary, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          if (meal.suggestions.isNotEmpty) ...[
            const SizedBox(height: 14),
            CardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb, color: TColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        l.mealDetail_suggestions,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: TColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...meal.suggestions.map(
                    (s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('• $s'),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () => _delete(meal),
            icon: const Icon(Icons.delete_outline),
            label: Text(l.mealDetail_deleteMeal),
            style: TextButton.styleFrom(foregroundColor: TColors.khabith),
          ),
          const SizedBox(height: 8),
          Text(
            l.mealDetail_footerDisclaimer,
            textAlign: TextAlign.center,
            style: const TextStyle(color: TColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _mealImage(Meal meal) {
    final path = meal.imagePath;
    if (path == null) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: TColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported,
            color: TColors.textSecondary, size: 40),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.file(
        File(path),
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 220,
          color: TColors.surface,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, color: TColors.textSecondary),
        ),
      ),
    );
  }

  Widget _itemCard(FoodItem item) {
    final hasCaution =
        item.zone == FoodZone.yellow && (item.cautionAr ?? '').isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nameAr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.category} • ${item.estimatedPortion}',
                        style: const TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ZoneBadge(zone: item.zone),
              ],
            ),
            if (hasCaution) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.visibility,
                      color: TColors.gold, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.cautionAr!,
                      style: const TextStyle(
                        color: TColors.gold,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (item.reasoningAr.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.reasoningAr,
                style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}/${two(local.month)}/${two(local.day)} • ${two(local.hour)}:${two(local.minute)}';
  }
}
