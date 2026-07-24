import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/meal_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/analysis_result.dart';
import '../../models/meal.dart';
import '../../services/notification_service.dart';
import '../../theme/theme.dart';
import '../../util/format.dart';
import '../../widgets/card_container.dart';
import '../../widgets/nutrition_summary.dart';
import '../../widgets/zone_badge.dart';
import '../body_response/body_response_card.dart';
import '../body_response/body_response_flow.dart';
import '../capture/capture_screen.dart';
import 'edit_items_sheet.dart';

/// تفاصيل وجبة محفوظة. تُعاد القراءة من المستودع عند العودة من تدفّق الجسم.
///
/// When [isPostCapture] is true, the chrome adapts for the just-analyzed
/// experience: a close-X leading button, a sticky bottom action bar with
/// "Done" + "Capture another", and the delete affordance is hidden (delete
/// only belongs on a meal reached from History, to avoid one-tap regret).
class MealDetailScreen extends StatefulWidget {
  final String mealId;
  final bool isPostCapture;
  const MealDetailScreen({
    super.key,
    required this.mealId,
    this.isPostCapture = false,
  });

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

  Future<void> _openEditItems(Meal meal) async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final saved = await showEditItemsSheet(context, meal);
    if (!mounted) return;
    if (saved) {
      setState(_reload);
      messenger.showSnackBar(SnackBar(content: Text(l.editItems_saved)));
    }
  }

  Future<void> _relog(Meal meal) async {
    final l = AppLocalizations.of(context)!;
    final repo = context.read<MealRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final clone = await repo.relogMeal(meal.id);
    if (!mounted || clone == null) return;
    HapticFeedback.lightImpact();
    messenger.showSnackBar(SnackBar(content: Text(l.mealDetail_logAgainDone)));
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
    // Capture everything that needs `context` before the first await so we
    // never touch BuildContext across an async gap.
    final notifications = context.read<NotificationService>();
    final meals = context.read<MealRepository>();
    final navigator = Navigator.of(context);
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
    await notifications.cancelBodyFollowup(meal.id);
    await meals.delete(meal.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MealRepository>();
    // إعادة التحميل عند أي تغيير في المستودع (مثلاً بعد حفظ متابعة الجسم).
    _future ??= repo.load(widget.mealId);

    final l = AppLocalizations.of(context)!;
    final postCapture = widget.isPostCapture;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.mealDetail_title),
        // Post-analysis screen replaces the default back arrow with an
        // explicit close X — this is the terminal result of an action,
        // not a navigable node.
        automaticallyImplyLeading: !postCapture,
        leading: postCapture
            ? IconButton(
                icon: const Icon(Icons.close),
                tooltip: l.common_close,
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      bottomNavigationBar: postCapture
          ? _PostCaptureActionBar(
              onDone: () => Navigator.of(context).pop(),
              onCaptureAnother: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const CaptureScreen()),
              ),
            )
          : null,
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
                  l.common_percentValue(meal.overallScore),
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
                if (meal.wasEdited) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: TColors.gold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit, size: 12, color: TColors.gold),
                        const SizedBox(width: 4),
                        Text(
                          l.mealDetail_editedBadge,
                          style: const TextStyle(
                            color: TColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  TFormat.dateTime(context, meal.capturedAt),
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
          if (meal.nutrition != null) ...[
            const SizedBox(height: 14),
            NutritionCard(nutrition: meal.nutrition!),
          ],
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  l.mealDetail_items,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (meal.items.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _openEditItems(meal),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(l.mealDetail_editItems),
                  style: TextButton.styleFrom(
                    foregroundColor: TColors.primary,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
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
          // v1.2.1 — سجّل نفس الوجبة من جديد بلا استهلاك تحليل.
          if (!widget.isPostCapture) ...[
            OutlinedButton.icon(
              onPressed: () => _relog(meal),
              icon: const Icon(Icons.replay),
              label: Text(l.mealDetail_logAgain),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Delete only belongs in the History → MealDetail flow, never on the
          // freshly-captured result screen (avoids accidental one-tap regret).
          if (!widget.isPostCapture)
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
            if (item.caloriesKcal != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: TColors.gold, size: 15),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!
                        .nutrition_kcalValue(item.caloriesKcal!),
                    style: const TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
            if (item.micros.isNotEmpty) ...[
              const SizedBox(height: 8),
              MicrosWrap(micros: item.micros),
            ],
          ],
        ),
      ),
    );
  }

}

/// Sticky bottom action bar shown after a fresh meal analysis. Two CTAs:
/// "Done" (pops back to Today / wherever the user came from) and
/// "Capture another" (`pushReplacement` straight into the camera).
class _PostCaptureActionBar extends StatelessWidget {
  final VoidCallback onDone;
  final VoidCallback onCaptureAnother;
  const _PostCaptureActionBar({
    required this.onDone,
    required this.onCaptureAnother,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(
          color: TColors.surface,
          border: Border(
            top: BorderSide(color: Color(0x14000000), width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCaptureAnother,
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(l.result_captureAnother),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TColors.primary,
                  side: const BorderSide(color: TColors.primary, width: 1.2),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: onDone,
                style: FilledButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(l.common_done),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
