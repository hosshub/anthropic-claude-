import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/suggestion.dart';
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
// Suggestion tab
// ---------------------------------------------------------------------------

class _SuggestionTab extends StatefulWidget {
  const _SuggestionTab();
  @override
  State<_SuggestionTab> createState() => _SuggestionTabState();
}

class _SuggestionTabState extends State<_SuggestionTab>
    with AutomaticKeepAliveClientMixin {
  final SuggestionService _svc = SuggestionService();
  MealSuggestion? _result;
  bool _loading = false;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await _svc.suggestMeal();
      setState(() {
        _result = r;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e is SuggestionException ? e.message : e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l = AppLocalizations.of(context)!;
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
        const SizedBox(height: 14),
        PrimaryButton(
          label: _result == null
              ? l.suggestions_single_button_first
              : l.suggestions_single_button_again,
          icon: Icons.lightbulb,
          loading: _loading,
          onPressed: _loading ? null : _fetch,
        ),
        if (_error != null) ...[
          const SizedBox(height: 14),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: TColors.khabith, fontSize: 13),
          ),
        ],
        if (_result != null) ...[
          const SizedBox(height: 18),
          _ResultCard(suggestion: _result!),
        ],
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final MealSuggestion suggestion;
  const _ResultCard({required this.suggestion});

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
              const Icon(Icons.restaurant, color: TColors.primary, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  suggestion.nameAr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (suggestion.bestTimeAr.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.10),
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
// Weekly plan tab
// ---------------------------------------------------------------------------

class _PlanTab extends StatefulWidget {
  const _PlanTab();
  @override
  State<_PlanTab> createState() => _PlanTabState();
}

class _PlanTabState extends State<_PlanTab>
    with AutomaticKeepAliveClientMixin {
  final SuggestionService _svc = SuggestionService();
  WeeklyPlan? _plan;
  bool _loading = false;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await _svc.generateWeeklyPlan();
      setState(() {
        _plan = p;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e is SuggestionException ? e.message : e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l = AppLocalizations.of(context)!;
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
                  l.suggestions_plan_intro,
                  style: const TextStyle(height: 1.55),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PrimaryButton(
          label: _plan == null
              ? l.suggestions_plan_button_first
              : l.suggestions_plan_button_again,
          icon: Icons.event_note,
          loading: _loading,
          onPressed: _loading ? null : _fetch,
        ),
        if (_error != null) ...[
          const SizedBox(height: 14),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: TColors.khabith, fontSize: 13),
          ),
        ],
        if (_plan != null) ...[
          const SizedBox(height: 18),
          if (_plan!.introAr.isNotEmpty)
            CardContainer(
              child: Text(
                _plan!.introAr,
                style: const TextStyle(
                  height: 1.6,
                  color: TColors.textPrimary,
                ),
              ),
            ),
          const SizedBox(height: 10),
          for (final day in _plan!.days) ...[
            _DayCard(day: day),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  final DayPlan day;
  const _DayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.today, color: TColors.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                day.dayAr,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: TColors.primary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final m in day.mealsAr)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: TColors.primary.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(m, style: const TextStyle(height: 1.55)),
                  ),
                ],
              ),
            ),
          if (day.noteAr.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: TColors.gold.withOpacity(0.10),
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
