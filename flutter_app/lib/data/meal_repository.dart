import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/analysis_result.dart';
import '../models/body_response.dart';
import '../models/meal.dart';
import 'database.dart';

/// مستودع الوجبات: حفظ/قراءة/حذف للوجبات وعناصرها ومتابعات الجسم.
class MealRepository extends ChangeNotifier {
  final _uuid = const Uuid();

  Future<Database> get _db => TayyibatDatabase.open();

  Future<Directory> _mealsDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'meals'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // -------------------------------------------------------------------------
  // الحفظ
  // -------------------------------------------------------------------------

  /// يحفظ نتيجة تحليل كوجبة جديدة. يكتب الصورة على القرص ويُعيد الوجبة المُخزّنة.
  Future<Meal> saveFromAnalysis(
    AnalysisResult result,
    Uint8List imageBytes,
  ) async {
    final id = _uuid.v4();
    final capturedAt = DateTime.now();
    final dir = await _mealsDir();
    final imagePath = p.join(dir.path, '$id.jpg');
    try {
      await File(imagePath).writeAsBytes(imageBytes, flush: true);
    } catch (_) {
      // إن فشلت الكتابة لأي سبب، نواصل ونحفظ الصف بدون صورة.
    }

    final db = await _db;
    await db.transaction((tx) async {
      await tx.insert('meals', {
        'id': id,
        'captured_at': capturedAt.millisecondsSinceEpoch,
        'image_path': await File(imagePath).exists() ? imagePath : null,
        'overall_score': result.overallScore,
        'score_label_ar': result.scoreLabelAr,
        'score_explanation_ar': result.scoreExplanationAr,
        'suggestions': jsonEncode(result.suggestions),
        'warnings': jsonEncode(result.warnings),
      });
      for (var i = 0; i < result.items.length; i++) {
        final item = result.items[i];
        await tx.insert('food_items', {
          'id': _uuid.v4(),
          'meal_id': id,
          'name_ar': item.nameAr,
          'verdict': item.verdict,
          'zone': item.zoneRaw,
          'caution_ar': item.cautionAr,
          'category': item.category,
          'reasoning': item.reasoningAr,
          'confidence': item.confidence,
          'estimated_portion': item.estimatedPortion,
          'rule_violated': item.ruleViolated,
          'item_order': i,
        });
      }
    });

    notifyListeners();
    return Meal(
      id: id,
      capturedAt: capturedAt,
      imagePath: await File(imagePath).exists() ? imagePath : null,
      overallScore: result.overallScore,
      scoreLabelAr: result.scoreLabelAr,
      scoreExplanationAr: result.scoreExplanationAr,
      suggestions: result.suggestions,
      warnings: result.warnings,
      items: result.items,
    );
  }

  // -------------------------------------------------------------------------
  // القراءة
  // -------------------------------------------------------------------------

  Future<List<Meal>> loadAll({int limit = 100}) async {
    final db = await _db;
    final rows = await db.query(
      'meals',
      orderBy: 'captured_at DESC',
      limit: limit,
    );
    return _hydrate(rows);
  }

  Future<List<Meal>> loadBetween(DateTime start, DateTime end) async {
    final db = await _db;
    final rows = await db.query(
      'meals',
      where: 'captured_at >= ? AND captured_at < ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'captured_at DESC',
    );
    return _hydrate(rows);
  }

  Future<Meal?> load(String id) async {
    final db = await _db;
    final rows = await db.query('meals', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final list = await _hydrate(rows);
    return list.isEmpty ? null : list.first;
  }

  Future<List<Meal>> _hydrate(List<Map<String, Object?>> mealRows) async {
    if (mealRows.isEmpty) return const [];
    final db = await _db;
    final ids = mealRows.map((m) => m['id'] as String).toList();
    final placeholders = List.filled(ids.length, '?').join(',');

    final itemRows = await db.query(
      'food_items',
      where: 'meal_id IN ($placeholders)',
      whereArgs: ids,
      orderBy: 'meal_id, item_order',
    );
    final itemsByMeal = <String, List<FoodItem>>{};
    for (final r in itemRows) {
      final mealId = r['meal_id'] as String;
      (itemsByMeal[mealId] ??= []).add(_foodItemFromRow(r));
    }

    final responseRows = await db.query(
      'body_responses',
      where: 'meal_id IN ($placeholders)',
      whereArgs: ids,
    );
    final responsesByMeal = <String, BodyResponse>{
      for (final r in responseRows) r['meal_id'] as String: BodyResponse.fromMap(r),
    };

    return mealRows.map((r) {
      final id = r['id'] as String;
      return Meal(
        id: id,
        capturedAt:
            DateTime.fromMillisecondsSinceEpoch(r['captured_at'] as int),
        imagePath: r['image_path'] as String?,
        overallScore: (r['overall_score'] as int?) ?? 0,
        scoreLabelAr: (r['score_label_ar'] as String?) ?? '',
        scoreExplanationAr: (r['score_explanation_ar'] as String?) ?? '',
        suggestions: _decodeStringList(r['suggestions']),
        warnings: _decodeStringList(r['warnings']),
        items: itemsByMeal[id] ?? const [],
        bodyResponse: responsesByMeal[id],
      );
    }).toList();
  }

  FoodItem _foodItemFromRow(Map<String, Object?> r) => FoodItem(
        nameAr: (r['name_ar'] as String?) ?? 'غير معروف',
        confidence: (r['confidence'] as num?)?.toDouble() ?? 0.5,
        estimatedPortion: (r['estimated_portion'] as String?) ?? 'متوسطة',
        verdict: (r['verdict'] as String?) ?? 'conditional',
        zoneRaw: r['zone'] as String?,
        cautionAr: r['caution_ar'] as String?,
        category: (r['category'] as String?) ?? 'عام',
        reasoningAr: (r['reasoning'] as String?) ?? '',
        ruleViolated: r['rule_violated'] as String?,
      );

  List<String> _decodeStringList(Object? raw) {
    if (raw is! String || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw);
      if (list is List) return list.whereType<String>().toList();
    } catch (_) {}
    return const [];
  }

  // -------------------------------------------------------------------------
  // متابعة الجسم
  // -------------------------------------------------------------------------

  /// يحفظ أو يحدّث متابعة الجسم لوجبة. يعيد الكائن المُخزَّن.
  Future<BodyResponse> upsertBodyResponse({
    required String mealId,
    required int satisfyingFullness,
    required int bloating,
    required int energyLevel,
    required SleepImpact sleepImpact,
    required WorthRepeating worthRepeating,
    String? notes,
  }) async {
    final db = await _db;
    final existing = await db.query(
      'body_responses',
      where: 'meal_id = ?',
      whereArgs: [mealId],
      limit: 1,
    );

    final mealRow = await db.query(
      'meals',
      columns: ['captured_at'],
      where: 'id = ?',
      whereArgs: [mealId],
      limit: 1,
    );
    final capturedAt = mealRow.isEmpty
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(
            mealRow.first['captured_at'] as int,
          );
    final hoursAfter =
        DateTime.now().difference(capturedAt).inHours.clamp(0, 999);

    final id = existing.isEmpty ? _uuid.v4() : existing.first['id'] as String;
    final response = BodyResponse(
      id: id,
      mealId: mealId,
      loggedAt: DateTime.now(),
      hoursAfterMeal: hoursAfter,
      satisfyingFullness: satisfyingFullness.clamp(1, 5),
      bloating: bloating.clamp(0, 5),
      energyLevel: energyLevel.clamp(1, 5),
      sleepImpact: sleepImpact,
      worthRepeating: worthRepeating,
      notes: (notes ?? '').trim().isEmpty ? null : notes!.trim(),
    );

    await db.insert(
      'body_responses',
      response.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners();
    return response;
  }

  // -------------------------------------------------------------------------
  // الحذف
  // -------------------------------------------------------------------------

  Future<void> delete(String mealId) async {
    final db = await _db;
    final row = await db.query(
      'meals',
      columns: ['image_path'],
      where: 'id = ?',
      whereArgs: [mealId],
      limit: 1,
    );
    if (row.isNotEmpty && row.first['image_path'] is String) {
      try {
        await File(row.first['image_path'] as String).delete();
      } catch (_) {}
    }
    await db.delete('meals', where: 'id = ?', whereArgs: [mealId]);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    final db = await _db;
    final rows = await db.query('meals', columns: ['image_path']);
    for (final r in rows) {
      final pth = r['image_path'] as String?;
      if (pth != null) {
        try {
          await File(pth).delete();
        } catch (_) {}
      }
    }
    await db.delete('food_items');
    await db.delete('body_responses');
    await db.delete('meals');
    // امسح كذلك يوميات الصيام (تنظيف شامل عند حذف الحساب).
    try {
      await db.delete('fasting_days');
    } catch (_) {/* الجدول قد لا يكون موجوداً في تثبيت أقدم */}
    notifyListeners();
  }
}
