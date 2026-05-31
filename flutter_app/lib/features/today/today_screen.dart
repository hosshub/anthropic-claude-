import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/meal_repository.dart';
import '../../models/meal.dart';
import '../../services/auth_service.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';
import '../../widgets/primary_button.dart';
import '../capture/capture_screen.dart';
import '../history/meal_detail_screen.dart';
import '../suggestions/suggestions_screen.dart';
import 'when_in_doubt_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  String _greeting(AuthService auth) {
    final hour = DateTime.now().hour;
    final period = hour < 12 ? 'صباح الخير' : 'مساء الخير';
    final email = auth.email;
    if (email == null || email.isEmpty) return period;
    return '$period، ${email.split('@').first}';
  }

  DateTime get _dayStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final repo = context.watch<MealRepository>();
    final dayStart = _dayStart;
    final dayEnd = dayStart.add(const Duration(days: 1));

    return Scaffold(
      appBar: AppBar(
        title: const Text('اليوم'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
        tooltip: 'عندما تحتار',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => const WhenInDoubtScreen(),
            ),
          );
        },
        child: const Text('🤔', style: TextStyle(fontSize: 24)),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Meal>>(
          key: ValueKey(repo.hashCode),
          future: repo.loadBetween(dayStart, dayEnd),
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
                    _greeting(auth),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  CardContainer(
                    child: _scoreRing(
                      score: score,
                      hasMeals: meals.isNotEmpty,
                      loading: loading,
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'صوّر وجبتك',
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
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SuggestionsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('اقتراحات ذكية'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TColors.primary,
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: TColors.primary, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  if (meals.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'سجل اليوم',
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
    required int score,
    required bool hasMeals,
    required bool loading,
  }) {
    final color = TColors.scoreColor(score);
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 168,
              height: 168,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 11,
                backgroundColor: color.withOpacity(0.18),
                color: color,
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$score%',
                  style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'طيب اليوم',
                  style: TextStyle(
                    color: TColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          loading
              ? '…'
              : (hasMeals ? '${_pluralMeals(score)} اليوم' : 'لم تسجّل وجبات اليوم بعد'),
          style: const TextStyle(
            color: TColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  String _pluralMeals(int avg) => 'متوسط $avg٪';
}

class _MealThumb extends StatelessWidget {
  final Meal meal;
  const _MealThumb({required this.meal});

  @override
  Widget build(BuildContext context) {
    final color = TColors.scoreColor(meal.overallScore);
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
                  '${meal.overallScore}%',
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
