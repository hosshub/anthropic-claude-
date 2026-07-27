import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tayyibat/data/database.dart';
import 'package:tayyibat/data/meal_repository.dart';
import 'package:tayyibat/data/plan_repository.dart';
import 'package:tayyibat/models/analysis_result.dart';
import 'package:tayyibat/models/suggestion.dart';

/// v1.2 schema (v4): meals.was_edited flag + meal_plans/plan_days tables,
/// item-edit persistence, and weekly-plan tracking.
void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  Future<Database> freshDb() async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 4,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: TayyibatDatabase.createSchema,
        onUpgrade: TayyibatDatabase.upgradeSchema,
      ),
    );
    return db;
  }

  group('schema v4', () {
    test('fresh create has was_edited column and plan tables', () async {
      final db = await freshDb();
      final mealCols = await db.rawQuery('PRAGMA table_info(meals)');
      expect(
        mealCols.map((c) => c['name']),
        contains('was_edited'),
      );
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      final names = tables.map((t) => t['name']).toList();
      expect(names, containsAll(['meal_plans', 'plan_days']));
      await db.close();
    });

    test('upgrade from v3 adds was_edited and plan tables', () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      // Minimal v3 shape: meals exists without was_edited, no plan tables.
      await db.execute('''
        CREATE TABLE meals (
          id TEXT PRIMARY KEY,
          captured_at INTEGER NOT NULL,
          image_path TEXT,
          overall_score INTEGER NOT NULL,
          score_label_ar TEXT NOT NULL,
          score_explanation_ar TEXT NOT NULL,
          suggestions TEXT NOT NULL,
          warnings TEXT NOT NULL
        );
      ''');
      await TayyibatDatabase.upgradeSchema(db, 3, 4);
      final cols = await db.rawQuery('PRAGMA table_info(meals)');
      expect(cols.map((c) => c['name']), contains('was_edited'));
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      expect(
        tables.map((t) => t['name']).toList(),
        containsAll(['meal_plans', 'plan_days']),
      );
      await db.close();
    });
  });

  group('MealRepository.updateMealItems', () {
    test('replaces items, updates score/label, and flags was_edited',
        () async {
      final db = await freshDb();
      final repo = MealRepository(dbOpener: () async => db);

      final saved = await repo.saveFromAnalysis(
        AnalysisResult.fromJson(const {
          'identified_items': [
            {'name_ar': 'أرز', 'zone': 'green', 'calories_kcal': 200},
            {'name_ar': 'فراخ', 'zone': 'red', 'calories_kcal': 300},
          ],
          'overall_score': 50,
          'score_label_ar': 'متوسط',
          'score_explanation_ar': 'يوجد عنصر أحمر.',
        }),
        Uint8List(0),
        persistImage: false,
      );
      expect(saved.wasEdited, isFalse);

      // User removes the wrongly-identified red item.
      final kept = [saved.items.first];
      await repo.updateMealItems(
        saved.id,
        kept,
        score: 100,
        label: 'ممتاز',
      );

      final reloaded = await repo.load(saved.id);
      expect(reloaded, isNotNull);
      expect(reloaded!.items, hasLength(1));
      expect(reloaded.items.single.nameAr, 'أرز');
      expect(reloaded.overallScore, 100);
      expect(reloaded.scoreLabelAr, 'ممتاز');
      expect(reloaded.wasEdited, isTrue);
      // Nutrition totals derive from surviving items only.
      expect(reloaded.nutrition!.caloriesKcal, 200);
      await db.close();
    });
  });

  group('PlanRepository', () {
    WeeklyPlan plan() => WeeklyPlan.fromJson(const {
          'intro_ar': 'خطة الأسبوع',
          'days': [
            {
              'day_ar': 'السبت',
              'meals_ar': ['فطور: بطاطس', 'غداء: لحم', 'عشاء: سمك'],
              'note_ar': '',
            },
            {
              'day_ar': 'الأحد',
              'meals_ar': ['فطور: كبدة', 'غداء: أرز', 'عشاء: خفيف'],
              'note_ar': 'يوم بسيط',
            },
          ],
        });

    test('savePlan persists and loadLatest round-trips', () async {
      final db = await freshDb();
      final repo = PlanRepository(dbOpener: () async => db);

      expect(await repo.loadLatest(), isNull);
      final saved = await repo.savePlan(plan());
      final loaded = await repo.loadLatest();
      expect(loaded, isNotNull);
      expect(loaded!.id, saved.id);
      expect(loaded.introAr, 'خطة الأسبوع');
      expect(loaded.days, hasLength(2));
      expect(loaded.days.first.mealsAr, hasLength(3));
      expect(loaded.days.first.done, [false, false, false]);
      expect(loaded.days.last.noteAr, 'يوم بسيط');
      await db.close();
    });

    test('saving a new plan replaces the previous one', () async {
      final db = await freshDb();
      final repo = PlanRepository(dbOpener: () async => db);
      final first = await repo.savePlan(plan());
      final second = await repo.savePlan(plan());
      expect(second.id, isNot(first.id));
      final rows = await db.query('meal_plans');
      expect(rows, hasLength(1));
      await db.close();
    });

    test('deleteAll wipes the saved plan (account-deletion teardown)',
        () async {
      final db = await freshDb();
      final repo = PlanRepository(dbOpener: () async => db);
      await repo.savePlan(plan());
      await repo.deleteAll();
      expect(await repo.loadLatest(), isNull);
      expect(await db.query('plan_days'), isEmpty);
      await db.close();
    });

    test('setMealDone toggles one meal and survives reload', () async {
      final db = await freshDb();
      final repo = PlanRepository(dbOpener: () async => db);
      final saved = await repo.savePlan(plan());

      await repo.setMealDone(
        planId: saved.id,
        dayOrder: 1,
        mealIndex: 2,
        done: true,
      );
      final loaded = await repo.loadLatest();
      expect(loaded!.days[1].done, [false, false, true]);
      expect(loaded.days[0].done, [false, false, false]);

      await repo.setMealDone(
        planId: saved.id,
        dayOrder: 1,
        mealIndex: 2,
        done: false,
      );
      final again = await repo.loadLatest();
      expect(again!.days[1].done, [false, false, false]);
      await db.close();
    });
  });
}
