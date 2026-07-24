import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/analysis_result.dart';
import '../theme/theme.dart';
import 'card_container.dart';

/// بطاقة القيم الغذائية لوجبة واحدة: سعرات كبيرة + صف الماكروز +
/// ملاحظة "تقديرات". تُخفى بالكامل عندما لا تملك الوجبة أرقامًا
/// (وجبات ما قبل v1.1).
class NutritionCard extends StatelessWidget {
  final MealNutrition nutrition;
  const NutritionCard({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department,
                  color: TColors.gold, size: 22),
              const SizedBox(width: 8),
              Text(
                l.nutrition_title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                l.nutrition_kcalValue(nutrition.caloriesKcal),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: TColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          MacroRow(nutrition: nutrition),
          const SizedBox(height: 10),
          Text(
            l.nutrition_estimateNote,
            style: const TextStyle(
              fontSize: 11.5,
              color: TColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// صف الماكروز الثلاثة: بروتين / كارب / دهون.
class MacroRow extends StatelessWidget {
  final MealNutrition nutrition;
  const MacroRow({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Row(
      children: [
        _MacroPill(
          label: l.nutrition_protein,
          grams: nutrition.proteinG,
          color: TColors.primary,
        ),
        const SizedBox(width: 8),
        _MacroPill(
          label: l.nutrition_carbs,
          grams: nutrition.carbsG,
          color: TColors.gold,
        ),
        const SizedBox(width: 8),
        _MacroPill(
          label: l.nutrition_fat,
          grams: nutrition.fatG,
          color: TColors.zoneGreen,
        ),
      ],
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final double grams;
  final Color color;
  const _MacroPill({
    required this.label,
    required this.grams,
    required this.color,
  });

  String _fmt(double g) =>
      g >= 10 ? g.round().toString() : g.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              l.nutrition_gramsValue(_fmt(grams)),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                color: TColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// شارات العناصر الدقيقة لعنصر طعام (حديد، فيتامين ج…).
class MicrosWrap extends StatelessWidget {
  final List<String> micros;
  const MicrosWrap({super.key, required this.micros});

  @override
  Widget build(BuildContext context) {
    if (micros.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final m in micros)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: TColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              m,
              style: const TextStyle(
                fontSize: 11,
                color: TColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
