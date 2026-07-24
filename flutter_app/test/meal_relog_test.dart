import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tayyibat/data/database.dart';
import 'package:tayyibat/data/meal_repository.dart';
import 'package:tayyibat/models/analysis_result.dart';
import 'package:tayyibat/models/body_response.dart';

/// v1.2.1 — "log again": clone a past meal as a fresh entry without
/// burning an AI analysis. Items/score/labels carry over; body response
/// does not; timestamps are new.
void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  Future<Database> freshDb() => databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 4,
          onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
          onCreate: TayyibatDatabase.createSchema,
          onUpgrade: TayyibatDatabase.upgradeSchema,
        ),
      );

  test('relogMeal clones items and score as a new meal, without body response',
      () async {
    final db = await freshDb();
    final repo = MealRepository(dbOpener: () async => db);

    final original = await repo.saveFromAnalysis(
      AnalysisResult.fromJson(const {
        'identified_items': [
          {'name_ar': 'أرز', 'zone': 'green', 'calories_kcal': 200},
          {'name_ar': 'سمك مشوي', 'zone': 'green', 'calories_kcal': 180},
        ],
        'overall_score': 95,
        'score_label_ar': 'ممتاز',
        'score_explanation_ar': 'وجبة خضراء.',
      }),
      Uint8List(0),
      persistImage: false,
    );
    await repo.upsertBodyResponse(
      mealId: original.id,
      satisfyingFullness: 4,
      bloating: 1,
      energyLevel: 4,
      sleepImpact: SleepImpact.positive,
      worthRepeating: WorthRepeating.yes,
    );

    final clone = await repo.relogMeal(original.id);
    expect(clone, isNotNull);
    expect(clone!.id, isNot(original.id));
    expect(clone.overallScore, 95);
    expect(clone.scoreLabelAr, 'ممتاز');
    expect(clone.items.map((i) => i.nameAr), ['أرز', 'سمك مشوي']);
    expect(
      clone.capturedAt.isAfter(original.capturedAt) ||
          clone.capturedAt.isAtSameMomentAs(original.capturedAt),
      isTrue,
    );

    final all = await repo.loadAll();
    expect(all, hasLength(2));
    final reloaded = await repo.load(clone.id);
    expect(reloaded!.bodyResponse, isNull, reason: 'body response not cloned');
    expect(reloaded.items, hasLength(2));
    await db.close();
  });

  test('recentCaptureTimes returns capture timestamps, newest first',
      () async {
    final db = await freshDb();
    final repo = MealRepository(dbOpener: () async => db);
    expect(await repo.recentCaptureTimes(), isEmpty);
    final saved = await repo.saveFromAnalysis(
      AnalysisResult.fromJson(const {
        'identified_items': [
          {'name_ar': 'أرز', 'zone': 'green'},
        ],
        'overall_score': 100,
        'score_label_ar': 'ممتاز',
        'score_explanation_ar': '',
      }),
      Uint8List(0),
      persistImage: false,
    );
    await repo.relogMeal(saved.id);
    final times = await repo.recentCaptureTimes();
    expect(times, hasLength(2));
    expect(
      times.first.isAfter(times.last) ||
          times.first.isAtSameMomentAs(times.last),
      isTrue,
    );
    await db.close();
  });

  test('relogMeal returns null for a missing meal', () async {
    final db = await freshDb();
    final repo = MealRepository(dbOpener: () async => db);
    expect(await repo.relogMeal('nope'), isNull);
    await db.close();
  });
}
