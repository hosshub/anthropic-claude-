import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/analysis_result.dart';
import '../models/body_response.dart';
import '../models/meal.dart';
import '../services/score_engine.dart';
import 'database.dart';
import 'food_bank_data.dart';

/// مستودع الوجبات: حفظ/قراءة/حذف للوجبات وعناصرها ومتابعات الجسم.
class MealRepository extends ChangeNotifier {
  final _uuid = const Uuid();

  /// حاقن لقاعدة البيانات — يسمح للاختبارات بتمرير قاعدة في الذاكرة.
  final Future<Database> Function() _opener;

  MealRepository({Future<Database> Function()? dbOpener})
      : _opener = dbOpener ?? TayyibatDatabase.open;

  Future<Database> get _db => _opener();

  /// عدّاد تغييرات — يزيد مع كل notifyListeners حتى تستطيع الشاشات
  /// إبطال نتائج FutureBuilder المخزّنة عند تغيّر البيانات فقط.
  int _revision = 0;
  int get revision => _revision;

  @override
  void notifyListeners() {
    _revision++;
    super.notifyListeners();
  }

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
  /// [persistImage] تتيح للاختبارات تخطي path_provider والقرص.
  Future<Meal> saveFromAnalysis(
    AnalysisResult result,
    Uint8List imageBytes, {
    bool persistImage = true,
  }) async {
    final id = _uuid.v4();
    final capturedAt = DateTime.now();
    String? imagePath;
    if (persistImage) {
      final dir = await _mealsDir();
      imagePath = p.join(dir.path, '$id.jpg');
      try {
        await File(imagePath).writeAsBytes(imageBytes, flush: true);
      } catch (_) {
        // إن فشلت الكتابة لأي سبب، نواصل ونحفظ الصف بدون صورة.
      }
    }
    final storedPath =
        imagePath != null && await File(imagePath).exists() ? imagePath : null;

    final db = await _db;
    await db.transaction((tx) async {
      await tx.insert('meals', {
        'id': id,
        'captured_at': capturedAt.millisecondsSinceEpoch,
        'image_path': storedPath,
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
          'calories_kcal': item.caloriesKcal,
          'protein_g': item.proteinG,
          'carbs_g': item.carbsG,
          'fat_g': item.fatG,
          'micros': item.micros.isEmpty ? null : jsonEncode(item.micros),
        });
      }
    });

    notifyListeners();
    return Meal(
      id: id,
      capturedAt: capturedAt,
      imagePath: storedPath,
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

  /// أوقات التقاط الوجبات الأخيرة (الأحدث أولاً) — تكفي لحساب سلسلة
  /// التسجيل بلا تحميل الوجبات كاملة.
  Future<List<DateTime>> recentCaptureTimes({int limit = 400}) async {
    final db = await _db;
    final rows = await db.query(
      'meals',
      columns: ['captured_at'],
      orderBy: 'captured_at DESC',
      limit: limit,
    );
    return [
      for (final r in rows)
        DateTime.fromMillisecondsSinceEpoch(r['captured_at'] as int),
    ];
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
        wasEdited: (r['was_edited'] as int? ?? 0) != 0,
        source: (r['source'] as String?) ?? 'ai',
      );
    }).toList();
  }

  // -------------------------------------------------------------------------
  // التسجيل من بنك الطعام (v1.3)
  // -------------------------------------------------------------------------

  /// يسجّل صنفاً من بنك الطعام كوجبة الآن — بلا صورة ولا تحليل ذكاء اصطناعي.
  /// النتيجة تُحسب من منطقة الصنف عبر محرّك النقاط، والتغذية تُضرب في [portions].
  Future<Meal> logFromFoodBank(FoodBankItem item, {int portions = 1}) async {
    final p = portions.clamp(1, 10);
    final foodItem = FoodItem(
      nameAr: item.nameAr,
      confidence: 1.0,
      estimatedPortion: item.portionAr,
      verdict: switch (item.zone) {
        FoodZone.green => 'tayyib',
        FoodZone.yellow => 'conditional',
        FoodZone.red => 'khabith',
      },
      zoneRaw: item.zone.name,
      category: item.categoryLabelAr,
      reasoningAr: item.noteAr ?? '',
      caloriesKcal: item.caloriesKcal * p,
      proteinG: item.proteinG * p,
      carbsG: item.carbsG * p,
      fatG: item.fatG * p,
    );
    final score = recomputeScore([foodItem]);
    final id = _uuid.v4();
    final capturedAt = DateTime.now();
    final db = await _db;
    await db.transaction((tx) async {
      await tx.insert('meals', {
        'id': id,
        'captured_at': capturedAt.millisecondsSinceEpoch,
        'image_path': null,
        'overall_score': score,
        'score_label_ar': item.nameAr,
        'score_explanation_ar': '',
        'suggestions': jsonEncode(<String>[]),
        'warnings': jsonEncode(<String>[]),
        'was_edited': 0,
        'source': 'food_bank',
      });
      await tx.insert('food_items', {
        'id': _uuid.v4(),
        'meal_id': id,
        'name_ar': foodItem.nameAr,
        'verdict': foodItem.verdict,
        'zone': foodItem.zoneRaw,
        'caution_ar': null,
        'category': foodItem.category,
        'reasoning': foodItem.reasoningAr,
        'confidence': 1.0,
        'estimated_portion': foodItem.estimatedPortion,
        'rule_violated': null,
        'item_order': 0,
        'calories_kcal': foodItem.caloriesKcal,
        'protein_g': foodItem.proteinG,
        'carbs_g': foodItem.carbsG,
        'fat_g': foodItem.fatG,
        'micros': null,
      });
    });
    notifyListeners();
    return Meal(
      id: id,
      capturedAt: capturedAt,
      imagePath: null,
      overallScore: score,
      scoreLabelAr: item.nameAr,
      scoreExplanationAr: '',
      suggestions: const [],
      warnings: const [],
      items: [foodItem],
      source: 'food_bank',
    );
  }

  // -------------------------------------------------------------------------
  // إعادة تسجيل وجبة (v1.2.1)
  // -------------------------------------------------------------------------

  /// يسجّل وجبة سابقة من جديد الآن — نسخة كاملة للعناصر والنتيجة بلا
  /// استهلاك تحليل ذكاء اصطناعي. متابعة الجسم لا تُنسخ (شعور جديد لوجبة
  /// جديدة)، والصورة تُنسخ ملفاً مستقلاً حتى لا يكسرها حذف الأصل.
  /// قرار منتج مقصود: لا يُجدول تذكير "كيف شعرت؟" لإعادة التسجيل —
  /// المستخدم يعرف هذه الوجبة أصلاً، والتذكير يخص التحليلات الجديدة.
  Future<Meal?> relogMeal(String mealId) async {
    final original = await load(mealId);
    if (original == null) return null;

    final id = _uuid.v4();
    final capturedAt = DateTime.now();
    String? imagePath;
    final sourcePath = original.imagePath;
    if (sourcePath != null) {
      try {
        final dir = await _mealsDir();
        final target = p.join(dir.path, '$id.jpg');
        await File(sourcePath).copy(target);
        imagePath = target;
      } catch (_) {
        // بلا صورة أفضل من فشل التسجيل كله.
      }
    }

    final db = await _db;
    await db.transaction((tx) async {
      await tx.insert('meals', {
        'id': id,
        'captured_at': capturedAt.millisecondsSinceEpoch,
        'image_path': imagePath,
        'overall_score': original.overallScore,
        'score_label_ar': original.scoreLabelAr,
        'score_explanation_ar': original.scoreExplanationAr,
        'suggestions': jsonEncode(original.suggestions),
        'warnings': jsonEncode(original.warnings),
        'was_edited': original.wasEdited ? 1 : 0,
        'source': original.source,
      });
      for (var i = 0; i < original.items.length; i++) {
        final item = original.items[i];
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
          'calories_kcal': item.caloriesKcal,
          'protein_g': item.proteinG,
          'carbs_g': item.carbsG,
          'fat_g': item.fatG,
          'micros': item.micros.isEmpty ? null : jsonEncode(item.micros),
        });
      }
    });

    notifyListeners();
    return Meal(
      id: id,
      capturedAt: capturedAt,
      imagePath: imagePath,
      overallScore: original.overallScore,
      scoreLabelAr: original.scoreLabelAr,
      scoreExplanationAr: original.scoreExplanationAr,
      suggestions: original.suggestions,
      warnings: original.warnings,
      items: original.items,
      wasEdited: original.wasEdited,
      source: original.source,
    );
  }

  // -------------------------------------------------------------------------
  // تعديل العناصر (v1.2)
  // -------------------------------------------------------------------------

  /// يستبدل عناصر الوجبة بعد تعديل المستخدم، ويحدّث النتيجة والتسمية،
  /// ويعلّم الوجبة كمُعدَّلة. الشرح القديم يُمسح لأنه قد يشير لعناصر أُزيلت.
  Future<void> updateMealItems(
    String mealId,
    List<FoodItem> items, {
    required int score,
    required String label,
  }) async {
    final db = await _db;
    await db.transaction((tx) async {
      await tx.delete('food_items', where: 'meal_id = ?', whereArgs: [mealId]);
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        await tx.insert('food_items', {
          'id': _uuid.v4(),
          'meal_id': mealId,
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
          'calories_kcal': item.caloriesKcal,
          'protein_g': item.proteinG,
          'carbs_g': item.carbsG,
          'fat_g': item.fatG,
          'micros': item.micros.isEmpty ? null : jsonEncode(item.micros),
        });
      }
      await tx.update(
        'meals',
        {
          'overall_score': score,
          'score_label_ar': label,
          'score_explanation_ar': '',
          'was_edited': 1,
        },
        where: 'id = ?',
        whereArgs: [mealId],
      );
    });
    notifyListeners();
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
        caloriesKcal: (r['calories_kcal'] as num?)?.round(),
        proteinG: (r['protein_g'] as num?)?.toDouble(),
        carbsG: (r['carbs_g'] as num?)?.toDouble(),
        fatG: (r['fat_g'] as num?)?.toDouble(),
        micros: _decodeStringList(r['micros']),
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

  // -------------------------------------------------------------------------
  // بيانات تجريبية (للقطات شاشة المتجر فقط — تُستخدم في وضع التطوير)
  // -------------------------------------------------------------------------

  /// يزرع وجبات وهمية موزّعة على آخر ١٤ يوماً مع تنويع المنطقة والدرجات
  /// ومتابعات الجسم — حتى تظهر شاشتا التقويم وBody Intelligence بمحتوى
  /// حقيقي عند التقاط الصور للمتجر. أزل البيانات لاحقاً بـ "حذف الحساب".
  /// [locale] == 'en' يترجم أسماء العناصر والتسميات إلى الإنجليزية حتى
  /// تُلتقط لقطات المتجر الإنجليزية بمحتوى إنجليزي متّسق مع الواجهة.
  Future<int> seedDemoData({String locale = 'ar'}) async {
    const enNames = <String, String>{
      'بطاطس مسلوقة': 'Boiled potatoes',
      'بطاطس مشوية': 'Roasted potatoes',
      'سمن بلدي': 'Ghee',
      'زبدة طبيعية': 'Natural butter',
      'زيت زيتون': 'Olive oil',
      'زيتون': 'Olives',
      'قهوة': 'Coffee',
      'شاي': 'Tea',
      'تمر': 'Dates',
      'أرز بسمتي': 'Basmati rice',
      'أرز أبيض': 'White rice',
      'سمك مشوي': 'Grilled fish',
      'كبدة بلدي': 'Liver',
      'لحم أحمر': 'Red meat',
      'ماء': 'Water',
      'بسكوت مصنّع': 'Processed biscuits',
    };
    const enLabels = <String, String>{
      'ممتاز': 'Excellent',
      'جيد': 'Good',
      'متوسط': 'Average',
      'بعيدة عن نظام الطيبات': 'Off the Tayyibat system',
    };
    final en = locale == 'en';
    String nm(String ar) => en ? (enNames[ar] ?? ar) : ar;
    String lbl(String ar) => en ? (enLabels[ar] ?? ar) : ar;
    return _seedDemoData(en: en, nm: nm, lbl: lbl);
  }

  Future<int> _seedDemoData({
    required bool en,
    required String Function(String) nm,
    required String Function(String) lbl,
  }) async {
    final db = await _db;
    final now = DateTime.now();
    DateTime daysAgo(int d, int hour, int minute) {
      final base = now.subtract(Duration(days: d));
      return DateTime(base.year, base.month, base.day, hour, minute);
    }

    // وجبة → (وقت، درجة، تسمية، عناصر، اقتراحات، متابعة جسم اختيارية)
    final samples = <_DemoMeal>[
      _DemoMeal(
        capturedAt: daysAgo(13, 8, 30),
        score: 92,
        label: 'ممتاز',
        explanation: 'تركيب بسيط ومتوازن.',
        items: [
          _DemoItem('بطاطس مسلوقة', 'green', 'starch', 'نشوي بسيط مقبول.'),
          _DemoItem('سمن بلدي', 'green', 'fat', 'دهن طبيعي.'),
          _DemoItem('قهوة', 'yellow', 'beverage',
              'باعتدال؛ راقب النوم والتوتر.'),
        ],
        bodyResponse: _DemoResponse(
          satisfaction: 4, bloating: 1, energy: 4,
          sleep: 'positive', worth: 'yes',
        ),
      ),
      _DemoMeal(
        capturedAt: daysAgo(12, 13, 10),
        score: 88,
        label: 'جيد',
        explanation: 'وجبة طيبة في مجملها.',
        items: [
          _DemoItem('أرز بسمتي', 'green', 'starch', 'أساس مقبول.'),
          _DemoItem('سمك مشوي', 'green', 'protein', 'بروتين خفيف ومُحبب.'),
          _DemoItem('زيت زيتون', 'green', 'fat', 'دهن طبيعي.'),
        ],
      ),
      _DemoMeal(
        capturedAt: daysAgo(11, 9, 0),
        score: 65,
        label: 'متوسط',
        explanation: 'كميات السكر مرتفعة قليلاً.',
        items: [
          _DemoItem('شاي', 'yellow', 'beverage', 'بسيط وبسكر خفيف.'),
          _DemoItem('تمر', 'yellow', 'sweets', 'كمية محسوبة.'),
        ],
      ),
      _DemoMeal(
        capturedAt: daysAgo(10, 13, 30),
        score: 95,
        label: 'ممتاز',
        explanation: 'وجبة طيبة بنقاء كامل.',
        items: [
          _DemoItem('كبدة بلدي', 'green', 'protein', 'بروتين قوي ومناسب.'),
          _DemoItem('بطاطس مشوية', 'green', 'starch', 'نشوي بسيط.'),
          _DemoItem('زبدة طبيعية', 'green', 'fat', 'دهن طبيعي.'),
        ],
        bodyResponse: _DemoResponse(
          satisfaction: 5, bloating: 0, energy: 5,
          sleep: 'positive', worth: 'yes',
        ),
      ),
      _DemoMeal(
        capturedAt: daysAgo(8, 19, 0),
        score: 78,
        label: 'جيد',
        explanation: 'منطقة صفراء بحساب.',
        items: [
          _DemoItem('قهوة', 'yellow', 'beverage', 'باعتدال.'),
          _DemoItem('تمر', 'yellow', 'sweets', 'كمية محسوبة.'),
        ],
        bodyResponse: _DemoResponse(
          satisfaction: 3, bloating: 2, energy: 3,
          sleep: 'neutral', worth: 'maybe',
        ),
      ),
      _DemoMeal(
        capturedAt: daysAgo(6, 13, 0),
        score: 90,
        label: 'ممتاز',
        explanation: 'تركيب متّزن ومُشبع.',
        items: [
          _DemoItem('أرز أبيض', 'green', 'starch', 'أساس بسيط.'),
          _DemoItem('لحم أحمر', 'green', 'protein', 'بروتين طيب.'),
          _DemoItem('زيت زيتون', 'green', 'fat', 'دهن طبيعي.'),
        ],
        bodyResponse: _DemoResponse(
          satisfaction: 5, bloating: 0, energy: 4,
          sleep: 'positive', worth: 'yes',
        ),
      ),
      _DemoMeal(
        capturedAt: daysAgo(5, 17, 30),
        score: 55,
        label: 'بعيدة عن نظام الطيبات',
        explanation: 'وجود عنصر من المنطقة الحمراء.',
        items: [
          _DemoItem('شاي', 'yellow', 'beverage', 'بسيط.'),
          _DemoItem('بسكوت مصنّع', 'red', 'snack',
              'منتج فائق التصنيع — يُتجنّب.'),
        ],
        bodyResponse: _DemoResponse(
          satisfaction: 2, bloating: 4, energy: 2,
          sleep: 'negative', worth: 'no',
        ),
      ),
      _DemoMeal(
        capturedAt: daysAgo(3, 14, 0),
        score: 95,
        label: 'ممتاز',
        explanation: 'بساطة ووضوح.',
        items: [
          _DemoItem('بطاطس مشوية', 'green', 'starch', 'نشوي بسيط.'),
          _DemoItem('سمن بلدي', 'green', 'fat', 'دهن طبيعي.'),
        ],
        bodyResponse: _DemoResponse(
          satisfaction: 5, bloating: 0, energy: 5,
          sleep: 'positive', worth: 'yes',
        ),
      ),
      _DemoMeal(
        capturedAt: daysAgo(2, 13, 15),
        score: 92,
        label: 'ممتاز',
        explanation: 'وجبة طيبة بطعم بسيط.',
        items: [
          _DemoItem('لحم أحمر', 'green', 'protein', 'بروتين أساسي.'),
          _DemoItem('أرز بسمتي', 'green', 'starch', 'نشوي مقبول.'),
          _DemoItem('زيت زيتون', 'green', 'fat', 'دهن طبيعي.'),
        ],
        bodyResponse: _DemoResponse(
          satisfaction: 4, bloating: 1, energy: 4,
          sleep: 'positive', worth: 'yes',
        ),
      ),
      _DemoMeal(
        capturedAt: daysAgo(1, 9, 30),
        score: 80,
        label: 'جيد',
        explanation: 'بساطة مع لمسة صفراء.',
        items: [
          _DemoItem('قهوة', 'yellow', 'beverage', 'باعتدال.'),
          _DemoItem('تمر', 'yellow', 'sweets', 'كمية محسوبة.'),
          _DemoItem('ماء', 'green', 'beverage', 'أساس.'),
        ],
      ),
      _DemoMeal(
        capturedAt: daysAgo(0, 13, 0),
        score: 88,
        label: 'جيد',
        explanation: 'تركيب متوازن.',
        items: [
          _DemoItem('أرز أبيض', 'green', 'starch', 'أساس مقبول.'),
          _DemoItem('سمك مشوي', 'green', 'protein', 'بروتين خفيف.'),
          _DemoItem('زيتون', 'green', 'fat', 'إضافة طبيعية.'),
        ],
      ),
    ];

    // تقديرات تغذية للبيانات التجريبية حتى تعرض شاشة اليوم عدّاد السعرات
    // في لقطات المتجر. (kcal، بروتين، كارب، دهون)
    const demoNutrition = <String, List<num>>{
      'بطاطس مسلوقة': [140, 3, 31, 0.2],
      'بطاطس مشوية': [160, 3.5, 33, 1],
      'سمن بلدي': [110, 0, 0, 12],
      'زبدة طبيعية': [100, 0.1, 0, 11],
      'زيت زيتون': [120, 0, 0, 13.5],
      'زيتون': [45, 0.3, 1.5, 4.5],
      'قهوة': [5, 0.3, 0.5, 0],
      'شاي': [30, 0, 7.5, 0],
      'تمر': [90, 0.7, 24, 0.1],
      'أرز بسمتي': [210, 4.5, 45, 0.5],
      'أرز أبيض': [205, 4.2, 44, 0.4],
      'سمك مشوي': [180, 26, 0, 8],
      'كبدة بلدي': [190, 27, 4, 6],
      'لحم أحمر': [250, 26, 0, 16],
      'ماء': [0, 0, 0, 0],
      'بسكوت مصنّع': [240, 3, 32, 11],
    };

    var inserted = 0;
    await db.transaction((tx) async {
      for (final meal in samples) {
        final mealId = _uuid.v4();
        await tx.insert('meals', {
          'id': mealId,
          'captured_at': meal.capturedAt.millisecondsSinceEpoch,
          'image_path': null,
          'overall_score': meal.score,
          'score_label_ar': lbl(meal.label),
          'score_explanation_ar': en ? '' : meal.explanation,
          'suggestions': jsonEncode(<String>[]),
          'warnings': jsonEncode(<String>[]),
        });
        for (var i = 0; i < meal.items.length; i++) {
          final item = meal.items[i];
          final n = demoNutrition[item.nameAr];
          await tx.insert('food_items', {
            'id': _uuid.v4(),
            'meal_id': mealId,
            'name_ar': nm(item.nameAr),
            'verdict': item.zoneRaw == 'green'
                ? 'tayyib'
                : item.zoneRaw == 'red'
                    ? 'khabith'
                    : 'conditional',
            'zone': item.zoneRaw,
            'caution_ar':
                (!en && item.zoneRaw == 'yellow') ? item.reasoning : null,
            'category': item.category,
            'reasoning': en ? '' : item.reasoning,
            'confidence': 0.92,
            'estimated_portion': en ? 'medium portion' : 'متوسطة',
            'rule_violated': null,
            'item_order': i,
            'calories_kcal': n?[0].round(),
            'protein_g': n?[1].toDouble(),
            'carbs_g': n?[2].toDouble(),
            'fat_g': n?[3].toDouble(),
            'micros': null,
          });
        }
        final br = meal.bodyResponse;
        if (br != null) {
          await tx.insert('body_responses', {
            'id': _uuid.v4(),
            'meal_id': mealId,
            'logged_at': meal.capturedAt
                .add(const Duration(hours: 3))
                .millisecondsSinceEpoch,
            'hours_after_meal': 3,
            'satisfying_fullness': br.satisfaction,
            'bloating': br.bloating,
            'energy_level': br.energy,
            'sleep_impact': br.sleep,
            'worth_repeating': br.worth,
            'notes': null,
          });
        }
        inserted++;
      }
    });
    notifyListeners();
    return inserted;
  }
}

class _DemoItem {
  final String nameAr;
  final String zoneRaw;
  final String category;
  final String reasoning;
  _DemoItem(this.nameAr, this.zoneRaw, this.category, this.reasoning);
}

class _DemoResponse {
  final int satisfaction;
  final int bloating;
  final int energy;
  final String sleep;
  final String worth;
  _DemoResponse({
    required this.satisfaction,
    required this.bloating,
    required this.energy,
    required this.sleep,
    required this.worth,
  });
}

class _DemoMeal {
  final DateTime capturedAt;
  final int score;
  final String label;
  final String explanation;
  final List<_DemoItem> items;
  final _DemoResponse? bodyResponse;
  _DemoMeal({
    required this.capturedAt,
    required this.score,
    required this.label,
    required this.explanation,
    required this.items,
    this.bodyResponse,
  });
}
