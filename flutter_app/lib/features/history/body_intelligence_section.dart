import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/enum_labels.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/health_service.dart';
import '../../models/analysis_result.dart';
import '../../models/body_response.dart';
import '../../models/meal.dart';
import '../../theme/theme.dart';
import '../../util/format.dart';
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
        return TColors.textSecondary.withValues(alpha: 0.5);
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
    final l = AppLocalizations.of(context)!;
    final responses = _responsesIn30;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.favorite, color: TColors.primary),
            const SizedBox(width: 8),
            Text(
              l.intel_title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ScoreTrendChart(meals: meals),
        const SizedBox(height: 12),
        _buildMetricsCard(l),
        const _HealthWeightCard(),
        if (responses.isEmpty) ...[
          const SizedBox(height: 12),
          _buildEmptyResponsesCard(l),
        ] else ...[
          if (_topComforting.isNotEmpty) ...[
            const SizedBox(height: 12),
            _mealsListCard(
              context: context,
              title: l.intel_topComforting,
              icon: Icons.thumb_up,
              accent: TColors.primary,
              entries: _topComforting,
              badgeFor: (m) =>
                  l.intel_satietyBadge(m.bodyResponse?.satisfyingFullness ?? 0),
            ),
          ],
          if (_heaviest.isNotEmpty) ...[
            const SizedBox(height: 12),
            _mealsListCard(
              context: context,
              title: l.intel_heaviest,
              icon: Icons.warning_amber,
              accent: TColors.khabith,
              entries: _heaviest,
              badgeFor: (m) =>
                  l.intel_bloatingBadge(m.bodyResponse?.bloating ?? 0),
            ),
          ],
          const SizedBox(height: 12),
          _buildSleepDistributionCard(l),
        ],
        const SizedBox(height: 12),
        _buildZoneDistributionCard(l),
      ],
    );
  }

  // ---- metrics ----

  Widget _buildMetricsCard(AppLocalizations l) => CardContainer(
        child: IntrinsicHeight(
          child: Row(
            children: [
              _metricTile(
                l: l,
                label: l.intel_avgSatiety,
                value: _avgSatisfaction == null
                    ? '—'
                    : _avgSatisfaction!.toStringAsFixed(1),
                color: TColors.primary,
                icon: Icons.restaurant,
              ),
              const VerticalDivider(width: 14),
              _metricTile(
                l: l,
                label: l.intel_avgBloating,
                value: _avgBloating == null
                    ? '—'
                    : _avgBloating!.toStringAsFixed(1),
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
    required AppLocalizations l,
    required String label,
    required String value,
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
                l.intel_outOf5,
                style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            l.intel_last30days,
            style: const TextStyle(
              color: TColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResponsesCard(AppLocalizations l) => CardContainer(
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: TColors.gold),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l.intel_empty,
                style: const TextStyle(
                    color: TColors.textSecondary, height: 1.55),
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
                            TFormat.dateTime(context, m.capturedAt),
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
                        color: accent.withValues(alpha: 0.10),
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

  Widget _buildSleepDistributionCard(AppLocalizations l) {
    final counts = _sleepCounts;
    final maxCount =
        counts.values.fold<int>(0, (a, b) => b > a ? b : a).clamp(1, 999);
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.nights_stay, color: TColors.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                l.intel_sleepTitle,
                style: const TextStyle(
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
                      sleepImpactLabel(l, entry.key),
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
                                color: TColors.textSecondary.withValues(alpha: 0.08),
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

  Widget _buildZoneDistributionCard(AppLocalizations l) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view, color: TColors.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                l.intel_zoneShareTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: TColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _zoneStackBar(
              l: l,
              title: l.intel_last7days,
              shares: _zoneShareSince(_sevenDaysAgo)),
          const SizedBox(height: 10),
          _zoneStackBar(
              l: l,
              title: l.intel_last30days,
              shares: _zoneShareSince(_thirtyDaysAgo)),
        ],
      ),
    );
  }

  Widget _zoneStackBar({
    required AppLocalizations l,
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
          Text(
            l.intel_noDataYet,
            style: const TextStyle(color: TColors.textSecondary, fontSize: 12),
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
                      l.intel_zonePercent(
                        entry.value.round(),
                        foodZoneLabel(l, entry.key),
                      ),
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

}

// ---------------------------------------------------------------------------
// Score-trend line chart — last 30 days, average daily score.
// ---------------------------------------------------------------------------

class _ScoreTrendChart extends StatelessWidget {
  final List<Meal> meals;
  const _ScoreTrendChart({required this.meals});

  static const int _days = 30;

  /// يبني قائمة بمتوسط درجة كل يوم من آخر ٣٠ يوماً. يبقى null لو ما في وجبة.
  List<double?> _series() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: _days - 1));
    final buckets = <DateTime, List<int>>{};
    for (final m in meals) {
      final l = m.capturedAt.toLocal();
      final day = DateTime(l.year, l.month, l.day);
      if (day.isBefore(start)) continue;
      buckets.putIfAbsent(day, () => []).add(m.overallScore);
    }
    return List<double?>.generate(_days, (i) {
      final d = start.add(Duration(days: i));
      final list = buckets[d];
      if (list == null || list.isEmpty) return null;
      final sum = list.fold<int>(0, (a, b) => a + b);
      return sum / list.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final series = _series();
    final spots = <FlSpot>[];
    for (var i = 0; i < series.length; i++) {
      final v = series[i];
      if (v != null) spots.add(FlSpot(i.toDouble(), v));
    }
    final hasData = spots.length >= 2;
    final avg = spots.isEmpty
        ? null
        : spots.map((s) => s.y).reduce((a, b) => a + b) / spots.length;
    final lineColor = avg == null ? TColors.primary : TColors.scoreColor(avg.round());

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart,
                  color: TColors.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                l.intel_trendTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: TColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (avg != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: lineColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Text(
                    l.intel_trendAvg(avg.round()),
                    style: TextStyle(
                      color: lineColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l.intel_trendSubtitle,
            style: const TextStyle(
              color: TColors.textSecondary,
              fontSize: 11,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: !hasData
                ? Center(
                    child: Text(
                      l.intel_trendNeedMore,
                      style: const TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (_days - 1).toDouble(),
                      minY: 0,
                      maxY: 100,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 25,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: TColors.textSecondary.withValues(alpha: 0.10),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 25,
                            getTitlesWidget: (v, _) {
                              if (v == 0 || v == 100) {
                                return Text(
                                  '${v.toInt()}',
                                  style: const TextStyle(
                                    color: TColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 10,
                            reservedSize: 22,
                            getTitlesWidget: (v, _) {
                              final daysAgo = (_days - 1 - v).toInt();
                              if (daysAgo == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    l.intel_trendToday,
                                    style: const TextStyle(
                                      color: TColors.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              }
                              if (daysAgo == 30) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    l.intel_trend30daysAgo,
                                    style: const TextStyle(
                                      color: TColors.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => TColors.textPrimary,
                          getTooltipItems: (touched) => touched
                              .map(
                                (s) => LineTooltipItem(
                                  l.intel_tooltipPercent(s.y.round()),
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.18,
                          color: lineColor,
                          barWidth: 2.4,
                          dotData: FlDotData(
                            show: spots.length <= 12,
                            getDotPainter: (s, _, __, ___) =>
                                FlDotCirclePainter(
                              radius: 3,
                              color: lineColor,
                              strokeWidth: 0,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                lineColor.withValues(alpha: 0.25),
                                lineColor.withValues(alpha: 0),
                              ],
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
}


/// وزن المستخدم من Apple Health — عرض فقط، بلا تفسير أو توصية (التزاماً
/// بقيود السلامة الطبية). يظهر فقط عند الربط ووجود قياس.
class _HealthWeightCard extends StatelessWidget {
  const _HealthWeightCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final weight = context.watch<HealthService>().weightKg;
    if (weight == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: TColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.monitor_weight_outlined,
                  color: TColors.primary, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.health_weightTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.health_weightSub,
                    style: const TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 11.5,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l.health_weightValue(weight.toStringAsFixed(1)),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: TColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
