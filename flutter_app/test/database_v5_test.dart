import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tayyibat/data/database.dart';
import 'package:tayyibat/data/plan_repository.dart';
import 'package:tayyibat/models/suggestion.dart';

/// v1.3.0 schema (v5): meals.source + meal_plans.started_at.
void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  Future<Database> freshDb() => databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 5,
          onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
          onCreate: TayyibatDatabase.createSchema,
          onUpgrade: TayyibatDatabase.upgradeSchema,
        ),
      );

  test('fresh create has meals.source and meal_plans.started_at', () async {
    final db = await freshDb();
    final mealCols = await db.rawQuery('PRAGMA table_info(meals)');
    expect(mealCols.map((c) => c['name']), contains('source'));
    final planCols = await db.rawQuery('PRAGMA table_info(meal_plans)');
    expect(planCols.map((c) => c['name']), contains('started_at'));
    await db.close();
  });

  test('upgrade v4 → v5 adds the new columns', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    // Minimal v4 shape.
    await db.execute('''
      CREATE TABLE meals (
        id TEXT PRIMARY KEY, captured_at INTEGER NOT NULL, image_path TEXT,
        overall_score INTEGER NOT NULL, score_label_ar TEXT NOT NULL,
        score_explanation_ar TEXT NOT NULL, suggestions TEXT NOT NULL,
        warnings TEXT NOT NULL, was_edited INTEGER NOT NULL DEFAULT 0
      );
    ''');
    await db.execute('''
      CREATE TABLE meal_plans (
        id TEXT PRIMARY KEY, created_at INTEGER NOT NULL, intro TEXT NOT NULL
      );
    ''');
    await TayyibatDatabase.upgradeSchema(db, 4, 5);
    final mealCols = await db.rawQuery('PRAGMA table_info(meals)');
    expect(mealCols.map((c) => c['name']), contains('source'));
    final planCols = await db.rawQuery('PRAGMA table_info(meal_plans)');
    expect(planCols.map((c) => c['name']), contains('started_at'));
    await db.close();
  });

  test('upgrade v3 → v5 in one step is duplicate-free and adds all columns',
      () async {
    // The riskiest path: a v1.1 user jumping straight to v1.3. v4 creates the
    // plan tables (without started_at) and v5 must ALTER it in without a
    // duplicate-column error.
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    // Minimal v3 shape: meals (no was_edited/source), no plan tables.
    await db.execute('''
      CREATE TABLE meals (
        id TEXT PRIMARY KEY, captured_at INTEGER NOT NULL, image_path TEXT,
        overall_score INTEGER NOT NULL, score_label_ar TEXT NOT NULL,
        score_explanation_ar TEXT NOT NULL, suggestions TEXT NOT NULL,
        warnings TEXT NOT NULL
      );
    ''');
    await TayyibatDatabase.upgradeSchema(db, 3, 5);
    final mealCols =
        (await db.rawQuery('PRAGMA table_info(meals)')).map((c) => c['name']);
    expect(mealCols, containsAll(['was_edited', 'source']));
    final planCols = (await db.rawQuery('PRAGMA table_info(meal_plans)'))
        .map((c) => c['name'])
        .toList();
    expect(planCols, contains('started_at'));
    // exactly one started_at (no duplicate)
    expect(planCols.where((c) => c == 'started_at').length, 1);
    await db.close();
  });

  test('PlanRepository.commitPlan sets started_at; loadLatest returns it',
      () async {
    final db = await freshDb();
    final repo = PlanRepository(dbOpener: () async => db);
    final plan = WeeklyPlan.fromJson(const {
      'intro_ar': 'خطة',
      'days': [
        {'day_ar': 'السبت', 'meals_ar': ['فطور', 'غداء'], 'note_ar': ''},
      ],
    });
    final saved = await repo.savePlan(plan);
    expect(saved.startedAt, isNull);
    expect((await repo.loadLatest())!.startedAt, isNull);

    await repo.commitPlan(saved.id);
    final after = await repo.loadLatest();
    expect(after!.startedAt, isNotNull);
    await db.close();
  });
}
