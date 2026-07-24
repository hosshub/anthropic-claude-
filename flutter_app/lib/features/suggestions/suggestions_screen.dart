import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/meal_repository.dart';
import '../../data/plan_repository.dart';
import '../../services/plan_adherence.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/suggestion.dart';
import '../../services/app_messages.dart';
import '../../services/suggestion_service.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';
import '../../widgets/primary_button.dart';

class SuggestionsScreen extends StatelessWidget {
  const SuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.suggestions_title),
          bottom: TabBar(
            indicatorColor: TColors.primary,
            labelColor: TColors.primary,
            unselectedLabelColor: TColors.textSecondary,
            tabs: [
              Tab(text: l.suggestions_tab_single),
              Tab(text: l.suggestions_tab_weekly),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SuggestionTab(),
            _PlanTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Suggestion tab — v1.2: three options at once
// ---------------------------------------------------------------------------

class _SuggestionTab extends StatefulWidget {
  const _SuggestionTab();
  @override
  State<_SuggestionTab> createState() => _SuggestionTabState();
}

class _SuggestionTabState extends State<_SuggestionTab>
    with AutomaticKeepAliveClientMixin {
  final SuggestionService _svc = SuggestionService();
  List<MealSuggestion>? _results;
  bool _loading = false;
  String? _error;
  String? _mealType; // null = any

  @override
  bool get wantKeepAlive => true;

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await _svc.suggestMeals(mealType: _mealType);
      if (!mounted) return;
      setState(() {
        _results = r;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = describeError(AppLocalizations.of(context)!, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l = AppLocalizations.of(context)!;
    final results = _results;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CardContainer(
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: TColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.suggestions_single_intro,
                  style: const TextStyle(height: 1.55),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _MealTypeChips(
          selected: _mealType,
          onSelected: (v) => setState(() => _mealType = v),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: results == null
              ? l.suggestions_single_button_first
              : l.suggestions_single_button_again,
          icon: Icons.lightbulb,
          loading: _loading,
          onPressed: _loading ? null : _fetch,
        ),
        if (_error != null) ...[
          const SizedBox(height: 14),
          _ErrorNote(message: _error!, onRetry: _fetch),
        ],
        if (results != null) ...[
          const SizedBox(height: 18),
          for (var i = 0; i < results.length; i++) ...[
            _ResultCard(index: i + 1, suggestion: results[i]),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class _MealTypeChips extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;
  const _MealTypeChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final options = <String?, String>{
      null: l.suggestions_anyTime,
      'breakfast': l.foodBank_cat_breakfast,
      'lunch': l.foodBank_cat_lunch,
      'dinner': l.foodBank_cat_dinner,
    };
    return Wrap(
      spacing: 8,
      children: [
        for (final e in options.entries)
          ChoiceChip(
            label: Text(e.value),
            selected: selected == e.key,
            onSelected: (_) => onSelected(e.key),
            selectedColor: TColors.primary.withValues(alpha: 0.15),
            labelStyle: TextStyle(
              color: selected == e.key ? TColors.primary : TColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final int index;
  final MealSuggestion suggestion;
  const _ResultCard({required this.index, required this.suggestion});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: TColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: TColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  suggestion.nameAr,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (suggestion.bestTimeAr.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: TColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                suggestion.bestTimeAr,
                style: const TextStyle(
                  color: TColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          if (suggestion.componentsAr.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              l.suggestions_components,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: TColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            for (final c in suggestion.componentsAr)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        color: TColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(c, style: const TextStyle(height: 1.55)),
                    ),
                  ],
                ),
              ),
          ],
          if (suggestion.reasoningAr.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              suggestion.reasoningAr,
              style: const TextStyle(
                color: TColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weekly plan tab — v1.2: persisted with per-meal progress tracking
// ---------------------------------------------------------------------------

class _PlanTab extends StatefulWidget {
  const _PlanTab();
  @override
  State<_PlanTab> createState() => _PlanTabState();
}

class _PlanTabState extends State<_PlanTab>
    with AutomaticKeepAliveClientMixin {
  final SuggestionService _svc = SuggestionService();
  bool _loading = false;
  String? _error;
  Future<SavedPlan?>? _planFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _planFuture = context.read<PlanRepository>().loadLatest();
  }

  Future<void> _generate({required bool hasExisting}) async {
    final l = AppLocalizations.of(context)!;
    final plans = context.read<PlanRepository>();
    if (hasExisting) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.plan_replaceTitle),
          content: Text(l.plan_replaceBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l.common_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l.plan_generate),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await _svc.generateWeeklyPlan();
      await plans.savePlan(p);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _planFuture = plans.loadLatest();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = describeError(AppLocalizations.of(context)!, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l = AppLocalizations.of(context)!;
    final plans = context.read<PlanRepository>();
    return FutureBuilder<SavedPlan?>(
      future: _planFuture ??= plans.loadLatest(),
      builder: (context, snap) {
        final plan = snap.data;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CardContainer(
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: TColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      plan == null ? l.suggestions_plan_intro : l.plan_savedAuto,
                      style: const TextStyle(height: 1.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: plan == null
                  ? l.suggestions_plan_button_first
                  : l.suggestions_plan_button_again,
              icon: Icons.event_note,
              loading: _loading,
              onPressed:
                  _loading ? null : () => _generate(hasExisting: plan != null),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              _ErrorNote(
                message: _error!,
                onRetry: () => _generate(hasExisting: plan != null),
              ),
            ],
            if (plan != null) ...[
              const SizedBox(height: 18),
              _PlanProgressCard(plan: plan),
              const SizedBox(height: 10),
              if (plan.startedAt == null)
                _CommitPlanCard(
                  onCommit: () async {
                    await plans.commitPlan(plan.id);
                    if (!mounted) return;
                    setState(() => _planFuture = plans.loadLatest());
                  },
                )
              else
                _AdherenceCard(plan: plan),
              const SizedBox(height: 10),
              if (plan.introAr.isNotEmpty) ...[
                CardContainer(
                  child: Text(
                    plan.introAr,
                    style: const TextStyle(
                      height: 1.6,
                      color: TColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              for (var d = 0; d < plan.days.length; d++) ...[
                _DayCard(
                  planId: plan.id,
                  dayOrder: d,
                  day: plan.days[d],
                  onToggle: (mealIndex, done) async {
                    await plans.setMealDone(
                      planId: plan.id,
                      dayOrder: d,
                      mealIndex: mealIndex,
                      done: done,
                    );
                    if (!mounted) return;
                    setState(() {
                      _planFuture = plans.loadLatest();
                    });
                  },
                ),
                const SizedBox(height: 10),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _CommitPlanCard extends StatelessWidget {
  final Future<void> Function() onCommit;
  const _CommitPlanCard({required this.onCommit});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.plan_notCommitted, style: const TextStyle(height: 1.55)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCommit,
              icon: const Icon(Icons.flag_outlined),
              label: Text(l.plan_commit),
              style: FilledButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(46),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة المخطط مقابل الفعلي: تحسب نسبة الالتزام من التأشير اليدوي وتسجيل
/// الوجبات الفعلي في تواريخ الخطة.
class _AdherenceCard extends StatelessWidget {
  final SavedPlan plan;
  const _AdherenceCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final repo = context.read<MealRepository>();
    return FutureBuilder<List<DateTime>>(
      future: repo.recentCaptureTimes(),
      builder: (context, snap) {
        final logged = <DateTime>{
          for (final t in (snap.data ?? const <DateTime>[]))
            DateTime(t.year, t.month, t.day),
        };
        final started = plan.startedAt!;
        final startDate = DateTime(started.year, started.month, started.day);
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final fractions = [
          for (final d in plan.days)
            d.mealsAr.isEmpty
                ? 0.0
                : d.done.where((x) => x).length / d.mealsAr.length,
        ];
        final score = planAdherenceScore(
          startedAt: started,
          dayManualFractions: fractions,
          loggedDates: logged,
          today: today,
        );
        final color = TColors.scoreColor(score);
        return CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights, color: TColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.plan_adherence_title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    l.common_percentValue(score),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l.plan_adherence_sub,
                style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var d = 0; d < plan.days.length; d++)
                    _dayChip(l, d, startDate, todayDate, fractions[d], logged),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dayChip(
    AppLocalizations l,
    int dayOrder,
    DateTime startDate,
    DateTime todayDate,
    double manualFraction,
    Set<DateTime> logged,
  ) {
    final date = DateTime(
      startDate.year,
      startDate.month,
      startDate.day + dayOrder,
    );
    final Color c;
    final String label;
    if (date.isAfter(todayDate)) {
      c = TColors.textSecondary;
      label = l.plan_day_upcoming;
    } else if (manualFraction > 0 || logged.contains(date)) {
      c = TColors.zoneGreen;
      label = l.plan_day_done;
    } else {
      c = TColors.khabith;
      label = l.plan_day_missed;
    }
    return Semantics(
      label: '${plan.days[dayOrder].dayAr}: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              plan.days[dayOrder].dayAr,
              style: TextStyle(
                  color: c, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanProgressCard extends StatelessWidget {
  final SavedPlan plan;
  const _PlanProgressCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final progress = plan.progress;
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, color: TColors.gold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.plan_progress(plan.doneMeals, plan.totalMeals),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                l.common_percentValue((progress * 100).round()),
                style: const TextStyle(
                  color: TColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: TColors.primary.withValues(alpha: 0.12),
              color: TColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final String planId;
  final int dayOrder;
  final SavedPlanDay day;
  final void Function(int mealIndex, bool done) onToggle;
  const _DayCard({
    required this.planId,
    required this.dayOrder,
    required this.day,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final allDone = day.done.isNotEmpty && day.done.every((d) => d);
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                allDone ? Icons.check_circle : Icons.today,
                color: allDone ? TColors.zoneGreen : TColors.primary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                day.dayAr,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: allDone ? TColors.zoneGreen : TColors.primary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < day.mealsAr.length; i++)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onToggle(i, !day.done[i]),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: Checkbox(
                        value: day.done[i],
                        activeColor: TColors.zoneGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        onChanged: (v) => onToggle(i, v ?? false),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          day.mealsAr[i],
                          style: TextStyle(
                            height: 1.5,
                            color: day.done[i]
                                ? TColors.textSecondary
                                : TColors.textPrimary,
                            decoration: day.done[i]
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (day.noteAr.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: TColors.gold.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: TColors.gold, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      day.noteAr,
                      style: const TextStyle(
                        color: TColors.gold,
                        fontSize: 12,
                        height: 1.5,
                      ),
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
}

// ---------------------------------------------------------------------------
// Shared error note with retry — friendlier than a bare red line.
// ---------------------------------------------------------------------------

class _ErrorNote extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorNote({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColors.khabith.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.khabith.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: TColors.khabith,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(l.common_retry),
            style: TextButton.styleFrom(foregroundColor: TColors.khabith),
          ),
        ],
      ),
    );
  }
}
