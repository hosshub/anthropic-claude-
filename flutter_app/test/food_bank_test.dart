import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tayyibat/data/database.dart';
import 'package:tayyibat/data/food_bank_data.dart';
import 'package:tayyibat/data/meal_repository.dart';
import 'package:tayyibat/models/analysis_result.dart';

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

  group('food bank data integrity', () {
    test('has ~150 well-formed Egyptian/Arabic dishes', () {
      expect(foodBankItems.length, greaterThanOrEqualTo(145));
      final ids = <String>{};
      for (final it in foodBankItems) {
        expect(it.id, isNotEmpty);
        expect(ids.add(it.id), isTrue, reason: 'duplicate id ${it.id}');
        expect(it.nameAr.trim(), isNotEmpty, reason: '${it.id} nameAr');
        expect(it.nameEn.trim(), isNotEmpty, reason: '${it.id} nameEn');
        expect(it.caloriesKcal, greaterThanOrEqualTo(0), reason: '${it.id} kcal');
        expect(it.proteinG, greaterThanOrEqualTo(0));
        expect(it.carbsG, greaterThanOrEqualTo(0));
        expect(it.fatG, greaterThanOrEqualTo(0));
      }
    });

    test('covers every category', () {
      final cats = foodBankItems.map((i) => i.category).toSet();
      expect(cats.length, FoodBankCategory.values.length);
    });
  });

  group('searchFoodBank', () {
    test('matches Arabic names', () {
      final r = searchFoodBank('كشري');
      expect(r, isNotEmpty);
      expect(r.first.nameAr, contains('كشري'));
    });

    test('matches English names case-insensitively', () {
      final r = searchFoodBank('KOSHARI');
      expect(r.any((i) => i.nameEn.toLowerCase().contains('koshari')), isTrue);
    });

    test('empty query returns everything', () {
      expect(searchFoodBank('').length, foodBankItems.length);
    });

    test('can filter by category', () {
      final r = searchFoodBank('', category: FoodBankCategory.drink);
      expect(r, isNotEmpty);
      expect(r.every((i) => i.category == FoodBankCategory.drink), isTrue);
    });
  });

  group('MealRepository.logFromFoodBank', () {
    test('persists a food_bank meal with zone score and scaled nutrition',
        () async {
      final db = await freshDb();
      final repo = MealRepository(dbOpener: () async => db);

      final green = foodBankItems.firstWhere((i) => i.zone == FoodZone.green);
      final meal = await repo.logFromFoodBank(green, portions: 2);

      expect(meal.overallScore, 100); // all-green single item
      expect(meal.items, hasLength(1));
      expect(meal.items.single.nameAr, green.nameAr);
      expect(meal.items.single.zone, FoodZone.green);
      expect(meal.nutrition!.caloriesKcal, green.caloriesKcal * 2);

      final reloaded = await repo.load(meal.id);
      expect(reloaded, isNotNull);
      expect(reloaded!.source, 'food_bank');
      expect(reloaded.items.single.caloriesKcal, green.caloriesKcal * 2);
      await db.close();
    });

    test('re-logging a food_bank meal keeps its source', () async {
      final db = await freshDb();
      final repo = MealRepository(dbOpener: () async => db);
      final item = foodBankItems.firstWhere((i) => i.zone == FoodZone.green);
      final logged = await repo.logFromFoodBank(item);
      final clone = await repo.relogMeal(logged.id);
      final reloaded = await repo.load(clone!.id);
      expect(reloaded!.source, 'food_bank');
      await db.close();
    });

    test('a red dish scores 0', () async {
      final db = await freshDb();
      final repo = MealRepository(dbOpener: () async => db);
      final red = foodBankItems.firstWhere((i) => i.zone == FoodZone.red);
      final meal = await repo.logFromFoodBank(red);
      expect(meal.overallScore, 0);
      await db.close();
    });
  });

  test('saveFromAnalysis still defaults source to ai', () async {
    final db = await freshDb();
    final repo = MealRepository(dbOpener: () async => db);
    final saved = await repo.saveFromAnalysis(
      AnalysisResult.fromJson(const {
        'identified_items': [
          {'name_ar': 'أرز', 'zone': 'green'}
        ],
        'overall_score': 100,
        'score_label_ar': 'ممتاز',
        'score_explanation_ar': '',
      }),
      Uint8List(0),
      persistImage: false,
    );
    final reloaded = await repo.load(saved.id);
    expect(reloaded!.source, 'ai');
    await db.close();
  });
}
