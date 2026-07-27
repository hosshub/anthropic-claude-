import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/suggestion.dart';
import 'database.dart';

/// خطة أسبوعية محفوظة محلياً مع تتبّع إنجاز كل وجبة.
class SavedPlan {
  final String id;
  final DateTime createdAt;
  final String introAr;
  final List<SavedPlanDay> days;

  /// v1.3 — تاريخ الالتزام بالخطة (يوم 0). null قبل الالتزام.
  final DateTime? startedAt;

  const SavedPlan({
    required this.id,
    required this.createdAt,
    required this.introAr,
    required this.days,
    this.startedAt,
  });

  int get totalMeals => days.fold(0, (a, d) => a + d.mealsAr.length);
  int get doneMeals =>
      days.fold(0, (a, d) => a + d.done.where((x) => x).length);
  double get progress => totalMeals == 0 ? 0 : doneMeals / totalMeals;
}

class SavedPlanDay {
  final String dayAr;
  final List<String> mealsAr;
  final String noteAr;
  final List<bool> done;

  const SavedPlanDay({
    required this.dayAr,
    required this.mealsAr,
    required this.noteAr,
    required this.done,
  });
}

/// مستودع الخطط الأسبوعية: خطة واحدة نشطة — حفظ خطة جديدة يستبدل السابقة.
class PlanRepository extends ChangeNotifier {
  final _uuid = const Uuid();
  final Future<Database> Function() _opener;

  PlanRepository({Future<Database> Function()? dbOpener})
      : _opener = dbOpener ?? TayyibatDatabase.open;

  Future<Database> get _db => _opener();

  Future<SavedPlan> savePlan(WeeklyPlan plan) async {
    final db = await _db;
    final id = _uuid.v4();
    final createdAt = DateTime.now();
    await db.transaction((tx) async {
      await tx.delete('meal_plans');
      await tx.delete('plan_days');
      await tx.insert('meal_plans', {
        'id': id,
        'created_at': createdAt.millisecondsSinceEpoch,
        'intro': plan.introAr,
      });
      for (var i = 0; i < plan.days.length; i++) {
        final day = plan.days[i];
        await tx.insert('plan_days', {
          'id': _uuid.v4(),
          'plan_id': id,
          'day_order': i,
          'day_label': day.dayAr,
          'note': day.noteAr,
          'meals': jsonEncode(day.mealsAr),
          'done_flags':
              jsonEncode(List<bool>.filled(day.mealsAr.length, false)),
        });
      }
    });
    notifyListeners();
    return SavedPlan(
      id: id,
      createdAt: createdAt,
      introAr: plan.introAr,
      days: [
        for (final d in plan.days)
          SavedPlanDay(
            dayAr: d.dayAr,
            mealsAr: d.mealsAr,
            noteAr: d.noteAr,
            done: List<bool>.filled(d.mealsAr.length, false),
          ),
      ],
    );
  }

  Future<SavedPlan?> loadLatest() async {
    final db = await _db;
    final plans = await db.query(
      'meal_plans',
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (plans.isEmpty) return null;
    final plan = plans.first;
    final planId = plan['id'] as String;
    final dayRows = await db.query(
      'plan_days',
      where: 'plan_id = ?',
      whereArgs: [planId],
      orderBy: 'day_order',
    );
    final startedMs = plan['started_at'] as int?;
    return SavedPlan(
      id: planId,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(plan['created_at'] as int),
      introAr: (plan['intro'] as String?) ?? '',
      startedAt: startedMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(startedMs),
      days: [
        for (final r in dayRows)
          SavedPlanDay(
            dayAr: (r['day_label'] as String?) ?? '',
            mealsAr: _decodeStrings(r['meals']),
            noteAr: (r['note'] as String?) ?? '',
            done: _decodeBools(r['done_flags'], _decodeStrings(r['meals']).length),
          ),
      ],
    );
  }

  /// يثبّت بداية الخطة (يوم 0 = اليوم) عند التزام المستخدم بها.
  Future<void> commitPlan(String planId) async {
    final db = await _db;
    await db.update(
      'meal_plans',
      {'started_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [planId],
    );
    notifyListeners();
  }

  Future<void> setMealDone({
    required String planId,
    required int dayOrder,
    required int mealIndex,
    required bool done,
  }) async {
    final db = await _db;
    final rows = await db.query(
      'plan_days',
      where: 'plan_id = ? AND day_order = ?',
      whereArgs: [planId, dayOrder],
      limit: 1,
    );
    if (rows.isEmpty) return;
    final row = rows.first;
    final meals = _decodeStrings(row['meals']);
    final flags = _decodeBools(row['done_flags'], meals.length);
    if (mealIndex < 0 || mealIndex >= flags.length) return;
    flags[mealIndex] = done;
    await db.update(
      'plan_days',
      {'done_flags': jsonEncode(flags)},
      where: 'id = ?',
      whereArgs: [row['id']],
    );
    notifyListeners();
  }

  Future<void> deleteAll() async {
    final db = await _db;
    await db.delete('plan_days');
    await db.delete('meal_plans');
    notifyListeners();
  }

  List<String> _decodeStrings(Object? raw) {
    if (raw is! String || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw);
      if (list is List) return list.whereType<String>().toList();
    } catch (_) {}
    return const [];
  }

  List<bool> _decodeBools(Object? raw, int length) {
    var flags = <bool>[];
    if (raw is String && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw);
        if (list is List) flags = list.whereType<bool>().toList();
      } catch (_) {}
    }
    // اضبط الطول دفاعياً حتى لا يكسر عدم التطابق واجهة التأشير.
    if (flags.length < length) {
      flags = [...flags, ...List<bool>.filled(length - flags.length, false)];
    } else if (flags.length > length) {
      flags = flags.sublist(0, length);
    }
    return flags;
  }
}
