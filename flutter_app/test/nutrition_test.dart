import 'package:flutter_test/flutter_test.dart';
import 'package:tayyibat/models/analysis_result.dart';

/// v1.1 nutrition pipeline: parsing of the extended analyze schema and the
/// fallback/derivation rules that keep pre-nutrition (v1.0.x) meals working.
void main() {
  group('FoodItem nutrition parsing', () {
    test('parses calories, macros, and micros', () {
      final item = FoodItem.fromJson(const {
        'name_ar': 'أرز أبيض',
        'confidence': 0.9,
        'zone': 'green',
        'calories_kcal': 205,
        'protein_g': 4.2,
        'carbs_g': 44,
        'fat_g': 0.4,
        'micros_ar': ['منغنيز', 'سيلينيوم', '  '],
      });
      expect(item.caloriesKcal, 205);
      expect(item.proteinG, 4.2);
      expect(item.carbsG, 44.0);
      expect(item.fatG, 0.4);
      expect(item.micros, ['منغنيز', 'سيلينيوم']); // blank entries dropped
    });

    test('legacy payload without nutrition stays null', () {
      final item = FoodItem.fromJson(const {
        'name_ar': 'قهوة',
        'confidence': 0.8,
        'zone': 'yellow',
      });
      expect(item.caloriesKcal, isNull);
      expect(item.proteinG, isNull);
      expect(item.micros, isEmpty);
    });
  });

  group('MealNutrition', () {
    test('uses server total_nutrition when present', () {
      final result = AnalysisResult.fromJson(const {
        'identified_items': [
          {'name_ar': 'أرز', 'zone': 'green', 'calories_kcal': 200},
        ],
        'total_nutrition': {
          'calories_kcal': 210,
          'protein_g': 5,
          'carbs_g': 45,
          'fat_g': 1,
        },
        'overall_score': 90,
      });
      expect(result.nutrition, isNotNull);
      expect(result.nutrition!.caloriesKcal, 210);
      expect(result.nutrition!.proteinG, 5.0);
    });

    test('derives totals from items when server omits total_nutrition', () {
      final result = AnalysisResult.fromJson(const {
        'identified_items': [
          {
            'name_ar': 'أرز',
            'zone': 'green',
            'calories_kcal': 200,
            'protein_g': 4,
            'carbs_g': 44,
            'fat_g': 0.5,
          },
          {
            'name_ar': 'لحم',
            'zone': 'green',
            'calories_kcal': 250,
            'protein_g': 26,
            'carbs_g': 0,
            'fat_g': 16,
          },
        ],
        'overall_score': 95,
      });
      expect(result.nutrition!.caloriesKcal, 450);
      expect(result.nutrition!.proteinG, 30.0);
      expect(result.nutrition!.fatG, 16.5);
    });

    test('fully legacy response has null nutrition', () {
      final result = AnalysisResult.fromJson(const {
        'identified_items': [
          {'name_ar': 'قهوة', 'zone': 'yellow'},
        ],
        'overall_score': 70,
      });
      expect(result.nutrition, isNull);
    });

    test('fromItems ignores items without data but sums the rest', () {
      final n = MealNutrition.fromItems([
        FoodItem.fromJson(const {'name_ar': 'قديم', 'zone': 'green'}),
        FoodItem.fromJson(const {
          'name_ar': 'جديد',
          'zone': 'green',
          'calories_kcal': 100,
          'protein_g': 2,
          'carbs_g': 20,
          'fat_g': 1,
        }),
      ]);
      expect(n, isNotNull);
      expect(n!.caloriesKcal, 100);
    });
  });
}
