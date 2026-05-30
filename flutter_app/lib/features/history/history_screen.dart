import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/meal_repository.dart';
import '../../models/meal.dart';
import '../../theme/theme.dart';
import 'meal_detail_screen.dart';

/// تبويب السجل — قائمة كل الوجبات المحفوظة.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MealRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('السجل')),
      body: FutureBuilder<List<Meal>>(
        // مفتاح يستند إلى عدد الإشعارات حتى نُعيد الاستعلام بعد كل إضافة/حذف.
        key: ValueKey(repo.hashCode),
        future: repo.loadAll(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final meals = snap.data ?? const <Meal>[];
          if (meals.isEmpty) {
            return _emptyState(context);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, i) => _MealRow(meal: meals[i]),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: meals.length,
          );
        },
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
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
              'لا سجلّات بعد',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              'صوّر أول وجبة من تبويب اليوم لتبدأ المتابعة.',
              textAlign: TextAlign.center,
              style: TextStyle(color: TColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  final Meal meal;
  const _MealRow({required this.meal});

  @override
  Widget build(BuildContext context) {
    final scoreColor = TColors.scoreColor(meal.overallScore);
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
                      _relativeDate(meal.capturedAt),
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
                            'متابعة جسم مسجّلة',
                            style: TextStyle(
                              color: TColors.primary.withOpacity(0.9),
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
                  color: scoreColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  '${meal.overallScore}%',
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

  String _relativeDate(DateTime dt) {
    final now = DateTime.now();
    final local = dt.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final mealDay = DateTime(local.year, local.month, local.day);
    String two(int n) => n.toString().padLeft(2, '0');
    final time = '${two(local.hour)}:${two(local.minute)}';
    if (mealDay == today) return 'اليوم • $time';
    if (mealDay == today.subtract(const Duration(days: 1))) {
      return 'أمس • $time';
    }
    return '${local.year}/${two(local.month)}/${two(local.day)} • $time';
  }
}
