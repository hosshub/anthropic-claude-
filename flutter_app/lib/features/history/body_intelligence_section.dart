import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/analysis_result.dart';
import '../../models/body_response.dart';
import '../../models/meal.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';
import 'meal_detail_screen.dart';

/// قسم "كيف يتجاوب جسمك؟" داخل تبويب السجل (يقرأ من قائمة الوجبات).
class BodyIntelligenceSection extends StatelessWidget {
  final List<Meal> meals;
  const BodyIntelligenceSection({super.key, required this.meals});

  DateTime get _now => DateTime.now();
  DateTime get _thirtyDaysAgo => _now.subtract(const Duration(days: 30));
  DateTime get _sevenDaysAgo => _now.subtract(const Duration(days: 7));

  List<BodyResponse> get _responsesIn30 => meals
      .where((m) =>
          m.bodyResponse != null &&
          m.bodyResponse!.loggedAt.isAfter(_thirtyDaysAgo))
      .map((m) => m.bodyResponse!)
      .toList();

  List<Meal> get _mealsWithResponseIn30 => meals
      .where((m) =>
          m.bodyResponse != null &&
          m.bodyResponse!.loggedAt.isAfter(_thirtyDaysAgo))
      .toList();

  double? get _avgSatisfaction {
    final r = _responsesIn30;
    if (r.isEmpty) return null;
    return r.map((e) => e.satisfyingFullness).reduce((a, b) => a + b) / r.length;
  }

  double? get _avgBloating {
    final r = _responsesIn30;
    if (r.isEmpty) return null;
    return r.map((e) => e.bloating).reduce((a, b) => a + b) / r.length;
  }

  Color _bloatingColor(double avg) {
    if (avg < 1.0) return TColors.primary;
    if (avg < 2.5) return TColors.gold;
    return TColors.khabith;
  }

  List<Meal> get _topComforting {
    final list = _mealsWithResponseIn30
        .where((m) =>
            (m.bodyResponse?.satisfyingFullness ?? 0) >= 4 &&
            (m.bodyResponse?.bloating ?? 0) <= 2)
        .toList()
      ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
    return list.take(3).toList();
  }

  List<Meal> get _heaviest {
    final list = _mealsWithResponseIn30
        .where((m) => (m.bodyResponse?.bloating ?? 0) >= 3)
        .toList()
      ..sort((a, b) =>
          (b.bodyResponse?.bloating ?? 0).compareTo(a.bodyResponse?.bloating ?? 0));
    return list.take(3).toList();
  }

  Map<SleepImpact, int> get _sleepCounts {
    final result = <SleepImpact, int>{
      for (final v in SleepImpact.values) v: 0,
    };
    for (final r in _responsesIn30) {
      result[r.sleepImpact] = (result[r.sleepImpact] ?? 0) + 1;
    }
    return result;
  }

  Color _sleepColor(SleepImpact i) {
    switch (i) {
      case SleepImpact.positive:
        return TColors.primary;
      case SleepImpact.neutral:
        return TColors.textSecondary;
      case SleepImpact.negative:
        return TColors.khabith;
      case SleepImpact.unknown:
        return TColors.textSecondary.withOpacity(0.5);
    }
  }

  Color _zoneColor(FoodZone z) {
    switch (z) {
      case FoodZone.green:
        return TColors.zoneGreen;
      case FoodZone.yellow:
        return TColors.zoneYellow;
      case FoodZone.red:
        return TColors.zoneRed;
    }
  }

  /// نسبة كل منطقة من عناصر الوجبات في نافذة زمنية.
  Map<FoodZone, double> _zoneShareSince(DateTime since) {
    final items = meals
        .where((m) => m.capturedAt.isAfter(since))
        .expand((m) => m.items)
        .toList();
    if (items.isEmpty) {
      return {for (final z in FoodZone.values) z: 0};
    }
    final counts = <FoodZone, int>{for (final z in FoodZone.values) z: 0};
    for (final it in items) {
      counts[it.zone] = (counts[it.zone] ?? 0) + 1;
    }
    final total = items.length;
    return {
      for (final z in FoodZone.values) z: (counts[z] ?? 0) / total * 100,
    };
  }

  @override
  Widget build(BuildContext context) {
    final responses = _responsesIn30;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.favorite, color: TColors.primary),
            SizedBox(width: 8),
            Text(
              'كيف يتجاوب جسمك؟',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _metricsCard,
        if (responses.isEmpty) ...[
          const SizedBox(height: 12),
          _emptyResponsesCard,
        ] else ...[
          if (_topComforting.isNotEmpty) ...[
            const SizedBox(height: 12),
            _mealsListCard(
              context: context,
              title: 'وجبات أعطتك راحة وشبعاً',
              icon: Icons.thumb_up,
              accent: TColors.primary,
              entries: _topComforting,
              badgeFor: (m) => '${m.bodyResponse?.satisfyingFullness ?? 0} / ٥ شبع',
            ),
          ],
          if (_heaviest.isNotEmpty) ...[
            const SizedBox(height: 12),
            _mealsListCard(
              context: context,
              title: 'وجبات أثقلت جسمك',
              icon: Icons.warning_amber,
              accent: TColors.khabith,
              entries: _heaviest,
              badgeFor: (m) => 'انتفاخ ${m.bodyResponse?.bloating ?? 0} / ٥',
            ),
          ],
          const SizedBox(height: 12),
          _sleepDistributionCard,
        ],
        const SizedBox(height: 12),
        _zoneDistributionCard,
      ],
    );
  }

  // ---- metrics ----

  Widget get _metricsCard => CardContainer(
        child: IntrinsicHeight(
          child: Row(
            children: [
              _metricTile(
                label: 'متوسط الشبع',
                value: _avgSatisfaction == null
                    ? '—'
                    : _avgSatisfaction!.toStringAsFixed(1),
                suffix: '/ ٥',
                color: TColors.primary,
                icon: Icons.restaurant,
              ),
              const VerticalDivider(width: 14),
              _metricTile(
                label: 'معدّل الانتفاخ',
                value: _avgBloating == null
                    ? '—'
                    : _avgBloating!.toStringAsFixed(1),
                suffix: '/ ٥',
                color: _avgBloating == null
                    ? TColors.textSecondary
                    : _bloatingColor(_avgBloating!),
                icon: Icons.air,
              ),
            ],
          ),
        ),
      );

  Widget _metricTile({
    required String label,
    required String value,
    required String suffix,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                suffix,
                style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Text(
            'آخر ٣٠ يوماً',
            style: TextStyle(
              color: TColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _emptyResponsesCard => CardContainer(
        child: Row(
          children: const [
            Icon(Icons.info_outline, color: TColors.gold),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'ابدأ بتسجيل متابعة الجسم بعد وجباتك حتى يعرف التطبيق ما يناسبك ويظهر أنماطك هنا.',
                style: TextStyle(color: TColors.textSecondary, height: 1.55),
              ),
            ),
          ],
        ),
      );

  // ---- meal lists ----

  Widget _mealsListCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color accent,
    required List<Meal> entries,
    required String Function(Meal) badgeFor,
  }) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: TColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final m in entries)
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MealDetailScreen(mealId: m.id),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    _thumb(m),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.primaryLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _shortDate(m.capturedAt),
                            style: const TextStyle(
                              color: TColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text(
                        badgeFor(m),
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _thumb(Meal m) {
    if (m.imagePath == null) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: TColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image, size: 18, color: TColors.textSecondary),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(m.imagePath!),
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 36,
          height: 36,
          color: TColors.background,
          child:
              const Icon(Icons.broken_image, color: TColors.textSecondary, size: 18),
        ),
      ),
    );
  }

  // ---- sleep ----

  Widget get _sleepDistributionCard {
    final counts = _sleepCounts;
    final maxCount =
        counts.values.fold<int>(0, (a, b) => b > a ? b : a).clamp(1, 999);
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.nights_stay, color: TColors.primary, size: 18),
              SizedBox(width: 6),
              Text(
                'تأثير الوجبات على نومك',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: TColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final entry in counts.entries) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      entry.key.labelAr,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (_, c) {
                        final w = c.maxWidth * entry.value / maxCount;
                        return Stack(
                          children: [
                            Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: TColors.textSecondary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            Container(
                              height: 14,
                              width: w,
                              decoration: BoxDecoration(
                                color: _sleepColor(entry.key),
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${entry.value}',
                      style: const TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---- zone distribution ----

  Widget get _zoneDistributionCard {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.grid_view, color: TColors.primary, size: 18),
              SizedBox(width: 6),
              Text(
                'توزّع الإشارات في طبقك',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: TColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _zoneStackBar(
              title: 'آخر ٧ أيام', shares: _zoneShareSince(_sevenDaysAgo)),
          const SizedBox(height: 10),
          _zoneStackBar(
              title: 'آخر ٣٠ يوماً', shares: _zoneShareSince(_thirtyDaysAgo)),
        ],
      ),
    );
  }

  Widget _zoneStackBar({
    required String title,
    required Map<FoodZone, double> shares,
  }) {
    final hasData = shares.values.any((v) => v > 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(color: TColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 6),
        if (!hasData)
          const Text(
            'لا بيانات بعد',
            style: TextStyle(color: TColors.textSecondary, fontSize: 12),
          )
        else ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LayoutBuilder(
              builder: (_, c) => Row(
                children: [
                  for (final entry in shares.entries)
                    Container(
                      height: 14,
                      width: c.maxWidth * (entry.value / 100),
                      color: _zoneColor(entry.key),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            children: [
              for (final entry in shares.entries)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _zoneColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.value.round()}٪ ${entry.key.labelAr}',
                      style: const TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ],
    );
  }

  String _shortDate(DateTime dt) {
    final l = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}/${two(l.month)}/${two(l.day)} • ${two(l.hour)}:${two(l.minute)}';
  }
}
