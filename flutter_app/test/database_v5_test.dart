import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tayyibat/data/database.dart';

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
}
