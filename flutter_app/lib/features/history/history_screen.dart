import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/meal_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/meal.dart';
import '../../theme/theme.dart';
import '../../util/format.dart';
import 'body_intelligence_section.dart';
import 'meal_detail_screen.dart';

enum _HistoryView { list, calendar }

/// تبويب السجل — يدعم عرضين: قائمة بكل الوجبات أو تقويم شهري ملوّن.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _HistoryView _view = _HistoryView.list;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MealRepository>();
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.tab_history),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: SegmentedButton<_HistoryView>(
              segments: [
                ButtonSegment(
                  value: _HistoryView.list,
                  icon: const Icon(Icons.view_list, size: 18),
                  label: Text(l.history_list),
                ),
                ButtonSegment(
                  value: _HistoryView.calendar,
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: Text(l.history_calendar),
                ),
              ],
              selected: {_view},
              onSelectionChanged: (s) => setState(() => _view = s.first),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Meal>>(
        key: ValueKey(repo.hashCode),
        future: repo.loadAll(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final meals = snap.data ?? const <Meal>[];
          if (meals.isEmpty) return _emptyState(context);
          return _view == _HistoryView.list
              ? _ListView(meals: meals)
              : _CalendarView(meals: meals);
        },
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.restaurant_menu,
                size: 64, color: TColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              l.history_empty_title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              l.history_empty_hint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: TColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List view (the old screen)
// ---------------------------------------------------------------------------

class _ListView extends StatelessWidget {
  final List<Meal> meals;
  const _ListView({required this.meals});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final m in meals) ...[
          _MealRow(meal: m),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 8),
        BodyIntelligenceSection(meals: meals),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Calendar view
// ---------------------------------------------------------------------------

class _CalendarView extends StatefulWidget {
  final List<Meal> meals;
  const _CalendarView({required this.meals});

  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView> {
  late DateTime _focused;
  DateTime? _selected;
  late Map<DateTime, List<Meal>> _byDay;

  @override
  void initState() {
    super.initState();
    _focused = DateTime.now();
    _selected = _normalize(_focused);
    _index();
  }

  @override
  void didUpdateWidget(covariant _CalendarView old) {
    super.didUpdateWidget(old);
    if (old.meals != widget.meals) _index();
  }

  void _index() {
    _byDay = <DateTime, List<Meal>>{};
    for (final m in widget.meals) {
      final d = _normalize(m.capturedAt.toLocal());
      _byDay.putIfAbsent(d, () => []).add(m);
    }
  }

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  List<Meal> _mealsOn(DateTime d) => _byDay[_normalize(d)] ?? const [];

  int? _avgScoreOn(DateTime d) {
    final list = _mealsOn(d);
    if (list.isEmpty) return null;
    final sum = list.fold<int>(0, (a, m) => a + m.overallScore);
    return (sum / list.length).round();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected ?? _normalize(_focused);
    final selectedMeals = _mealsOn(selected);
    final l = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: TColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: TableCalendar<Meal>(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focused,
            locale: localeCode,
            selectedDayPredicate: (d) =>
                _selected != null && isSameDay(_selected, d),
            availableCalendarFormats: {CalendarFormat.month: l.history_calendar_month},
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.saturday,
            eventLoader: _mealsOn,
            onDaySelected: (s, f) => setState(() {
              _selected = _normalize(s);
              _focused = f;
            }),
            onPageChanged: (f) => _focused = f,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
              ),
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: TColors.primary),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: TColors.primary),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: TColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              weekendStyle: TextStyle(
                color: TColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: const TextStyle(color: TColors.textPrimary),
              weekendTextStyle: const TextStyle(color: TColors.textPrimary),
              todayDecoration: BoxDecoration(
                color: TColors.primary.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: TColors.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              markersAlignment: Alignment.bottomCenter,
            ),
            calendarBuilders: CalendarBuilders<Meal>(
              markerBuilder: (context, day, _) {
                final score = _avgScoreOn(day);
                if (score == null) return null;
                final color = TColors.scoreColor(score);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        _DaySummary(date: selected, meals: selectedMeals),
        const SizedBox(height: 12),
        if (selectedMeals.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: TColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              AppLocalizations.of(context)!.history_noMealsThatDay,
              style: const TextStyle(color: TColors.textSecondary),
            ),
          )
        else
          for (final m in selectedMeals) ...[
            _MealRow(meal: m),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _DaySummary extends StatelessWidget {
  final DateTime date;
  final List<Meal> meals;
  const _DaySummary({required this.date, required this.meals});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    int? avg;
    if (meals.isNotEmpty) {
      final sum = meals.fold<int>(0, (a, m) => a + m.overallScore);
      avg = (sum / meals.length).round();
    }
    final color = avg == null ? TColors.textSecondary : TColors.scoreColor(avg);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              avg == null ? '—' : l.common_percentValue(avg),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TFormat.longDate(context, date),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                  ),
                ),
                Text(
                  meals.isEmpty
                      ? l.history_noMealsLabel
                      : l.history_mealsAvg(
                          meals.length,
                          meals.length == 1
                              ? l.history_mealsOne
                              : l.history_mealsMany,
                          avg ?? 0,
                        ),
                  style: const TextStyle(
                    color: TColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

// ---------------------------------------------------------------------------
// Meal row (shared between list and calendar views)
// ---------------------------------------------------------------------------

class _MealRow extends StatelessWidget {
  final Meal meal;
  const _MealRow({required this.meal});

  @override
  Widget build(BuildContext context) {
    final scoreColor = TColors.scoreColor(meal.overallScore);
    final l = AppLocalizations.of(context)!;
    return Material(
      color: TColors.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MealDetailScreen(mealId: meal.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _thumbnail(meal),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.primaryLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _relativeDate(context, meal.capturedAt),
                      style: const TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (meal.bodyResponse != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.favorite,
                              size: 12, color: TColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!
                                .history_bodyTrackingLogged,
                            style: TextStyle(
                              color: TColors.primary.withValues(alpha: 0.9),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  l.common_percentValue(meal.overallScore),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbnail(Meal meal) {
    if (meal.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(meal.imagePath!),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: TColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.image,
            color: TColors.textSecondary, size: 22),
      );

  String _relativeDate(BuildContext context, DateTime dt) {
    final l = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final local = dt.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final mealDay = DateTime(local.year, local.month, local.day);
    final time = TFormat.time(context, local);
    if (mealDay == today) return '${l.history_today} • $time';
    if (mealDay == today.subtract(const Duration(days: 1))) {
      return '${l.history_yesterday} • $time';
    }
    return TFormat.dateTime(context, local);
  }
}
