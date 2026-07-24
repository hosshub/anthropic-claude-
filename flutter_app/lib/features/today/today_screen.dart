import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/meal_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/analysis_result.dart';
import '../../models/meal.dart';
import '../../services/nutrition_goal_service.dart';
import '../../services/profile_service.dart';
import '../../services/streak.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';
import '../../widgets/nutrition_summary.dart';
import '../../widgets/primary_button.dart';
import '../capture/capture_screen.dart';
import '../fasting/fasting_screen.dart';
import '../history/meal_detail_screen.dart';
import '../suggestions/suggestions_screen.dart';
import 'when_in_doubt_screen.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  // Cache the day's query per repository generation — rebuilds (greeting,
  // locale, calorie goal…) must not re-hit SQLite every frame.
  Future<List<Meal>>? _mealsFuture;
  Future<int>? _streakFuture;
  int _cachedRevision = -1;
  DateTime? _cachedDay;

  String _greeting(BuildContext context, ProfileService profile) {
    final l = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    final period =
        hour < 12 ? l.today_greetingMorning : l.today_greetingEvening;
    // v1.2: التحية بالاسم المعروض الذي اختاره المستخدم — لا مقطع البريد.
    final name = profile.displayName;
    if (name == null || name.isEmpty) return period;
    return l.today_greetingWithName(period, name);
  }

  DateTime get _dayStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileService>();
    final repo = context.watch<MealRepository>();
    final l = AppLocalizations.of(context)!;
    final dayStart = _dayStart;
    final dayEnd = dayStart.add(const Duration(days: 1));
    // notifyListeners bumps repo.revision — refresh the cached futures only
    // when data actually changed (or the calendar day rolled over).
    if (_cachedRevision != repo.revision ||
        _cachedDay != dayStart ||
        _mealsFuture == null) {
      _cachedRevision = repo.revision;
      _cachedDay = dayStart;
      _mealsFuture = repo.loadBetween(dayStart, dayEnd);
      _streakFuture = repo
          .recentCaptureTimes()
          .then((times) => loggedStreak(times));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tab_today),
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: l.today_whenInDoubtTooltip,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => const WhenInDoubtScreen(),
            ),
          );
        },
        icon: const Icon(Icons.help_outline),
        label: Text(l.today_whenInDoubtTooltip),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Meal>>(
          future: _mealsFuture,
          builder: (context, snap) {
            final meals = snap.data ?? const <Meal>[];
            final loading = snap.connectionState == ConnectionState.waiting;
            final score = _averageScore(meals);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _greeting(context, profile),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  CardContainer(
                    child: _scoreRing(
                      context: context,
                      score: score,
                      hasMeals: meals.isNotEmpty,
                      loading: loading,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _StreakCard(
                    streakFuture: _streakFuture,
                    loggedToday: meals.isNotEmpty,
                  ),
                  _DailyCaloriesCard(meals: meals),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: l.today_photoYourMeal,
                    icon: Icons.camera_alt,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CaptureScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SuggestionsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.auto_awesome, size: 18),
                          label: Text(l.today_suggestions),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const FastingScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.brightness_2, size: 18),
                          label: Text(l.today_fasting),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (meals.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      l.today_log,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 168,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, i) => _MealThumb(meal: meals[i]),
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemCount: meals.length,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  int _averageScore(List<Meal> meals) {
    if (meals.isEmpty) return 0;
    final sum = meals.fold<int>(0, (a, m) => a + m.overallScore);
    return (sum / meals.length).round();
  }

  Widget _scoreRing({
    required BuildContext context,
    required int score,
    required bool hasMeals,
    required bool loading,
  }) {
    final l = AppLocalizations.of(context)!;
    final color = TColors.scoreColor(score);
    return Column(
      children: [
        // Single Semantics node — screen readers announce "Today's score,
        // 78 percent" instead of "78%, Today's score, [progress bar at 78%]".
        Semantics(
          label: '${l.today_score}, ${l.common_percentValue(score)}',
          container: true,
          excludeSemantics: true,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 168,
                height: 168,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 11,
                  backgroundColor: color.withValues(alpha: 0.18),
                  color: color,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l.common_percentValue(score),
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.today_score,
                    style: const TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          loading
              ? '…'
              : (hasMeals
                  ? l.today_averageToday(score)
                  : l.today_noMealsYet),
          style: const TextStyle(
            color: TColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

/// عدّاد السعرات اليومي: مجموع سعرات وجبات اليوم مقابل الهدف القابل
/// للتعديل من الإعدادات، مع صف الماكروز. يظهر فقط عندما تحمل وجبة واحدة
/// على الأقل أرقام تغذية (وجبات v1.1+).
class _DailyCaloriesCard extends StatelessWidget {
  final List<Meal> meals;
  const _DailyCaloriesCard({required this.meals});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final goalService = context.watch<NutritionGoalService>();

    final totals = meals
        .map((m) => m.nutrition)
        .whereType<MealNutrition>()
        .toList();
    if (totals.isEmpty) return const SizedBox.shrink();

    final consumed = totals.fold<int>(0, (a, n) => a + n.caloriesKcal);
    final combined = MealNutrition(
      caloriesKcal: consumed,
      proteinG: totals.fold(0.0, (a, n) => a + n.proteinG),
      carbsG: totals.fold(0.0, (a, n) => a + n.carbsG),
      fatG: totals.fold(0.0, (a, n) => a + n.fatG),
    );
    final goal = goalService.goal;
    final remaining = goal - consumed;
    final progress = (consumed / goal).clamp(0.0, 1.0);
    final over = remaining < 0;
    final barColor = over ? TColors.khabith : TColors.gold;

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
                l.today_caloriesTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                l.today_caloriesOf(consumed, goal),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: TColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Semantics(
            label:
                '${l.today_caloriesTitle}: ${l.today_caloriesOf(consumed, goal)}',
            container: true,
            excludeSemantics: true,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: barColor.withValues(alpha: 0.15),
                color: barColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            over
                ? l.today_caloriesOver(-remaining)
                : l.today_caloriesRemaining(remaining),
            style: TextStyle(
              fontSize: 12,
              color: over ? TColors.khabith : TColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          MacroRow(nutrition: combined),
        ],
      ),
    );
  }
}

/// شريط سلسلة التسجيل — أيام متتالية بوجبة واحدة على الأقل. يظهر فقط
/// عندما توجد سلسلة (لا نعاتب مستخدماً جديداً بصفر).
class _StreakCard extends StatelessWidget {
  final Future<int>? streakFuture;
  final bool loggedToday;
  const _StreakCard({required this.streakFuture, required this.loggedToday});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return FutureBuilder<int>(
      future: streakFuture,
      builder: (context, snap) {
        final streak = snap.data ?? 0;
        if (streak <= 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: CardContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: TColors.gold.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: TColors.gold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l.today_streakTitle}: ${l.today_streakDays(streak)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                      if (!loggedToday)
                        Text(
                          l.today_streakKeepAlive,
                          style: const TextStyle(
                            color: TColors.textSecondary,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MealThumb extends StatelessWidget {
  final Meal meal;
  const _MealThumb({required this.meal});

  @override
  Widget build(BuildContext context) {
    final color = TColors.scoreColor(meal.overallScore);
    final l = AppLocalizations.of(context)!;
    return SizedBox(
      width: 140,
      child: Material(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MealDetailScreen(mealId: meal.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 84,
                    width: double.infinity,
                    child: meal.imagePath == null
                        ? Container(
                            color: TColors.background,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image,
                                color: TColors.textSecondary),
                          )
                        : Image.file(
                            File(meal.imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: TColors.background,
                              alignment: Alignment.center,
                              child: const Icon(Icons.broken_image,
                                  color: TColors.textSecondary),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  meal.primaryLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  l.common_percentValue(meal.overallScore),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
