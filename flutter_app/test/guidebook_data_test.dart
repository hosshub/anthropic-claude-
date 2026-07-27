import 'package:flutter_test/flutter_test.dart';
import 'package:tayyibat/data/guidebook_data.dart';
import 'package:tayyibat/models/analysis_result.dart';

/// Integrity of the full meal guidebook: bilingual completeness, category
/// coverage, and — critically — system compliance: the guidebook must never
/// contain a red-zone meal.
void main() {
  test('guidebook has meaningful coverage in every category', () {
    expect(GuidebookData.meals.length, greaterThanOrEqualTo(24));
    for (final cat in GuidebookCategory.values) {
      expect(
        GuidebookData.byCategory(cat),
        isNotEmpty,
        reason: 'category $cat must not be empty',
      );
    }
    expect(GuidebookData.byCategory(null).length, GuidebookData.meals.length);
  });

  test('every meal is fully bilingual', () {
    for (final m in GuidebookData.meals) {
      expect(m.nameAr.trim(), isNotEmpty);
      expect(m.nameEn.trim(), isNotEmpty);
      expect(m.componentsAr, isNotEmpty);
      expect(m.componentsEn, isNotEmpty);
      expect(m.componentsAr.length, m.componentsEn.length,
          reason: '${m.nameEn}: component lists must be parallel');
      expect(m.prepAr.trim(), isNotEmpty);
      expect(m.prepEn.trim(), isNotEmpty);
    }
  });

  test('no red-zone meals — the guidebook teaches the system', () {
    for (final m in GuidebookData.meals) {
      expect(m.zone, isNot(FoodZone.red), reason: m.nameEn);
    }
  });

  test('nutrition numbers are plausible', () {
    for (final m in GuidebookData.meals) {
      expect(m.kcal, inInclusiveRange(30, 1200), reason: m.nameEn);
      expect(m.proteinG, greaterThanOrEqualTo(0));
      expect(m.carbsG, greaterThanOrEqualTo(0));
      expect(m.fatG, greaterThanOrEqualTo(0));
      // Macro energy should not wildly exceed stated calories (4/4/9 rule,
      // generous 40% tolerance for rounding of visual estimates).
      final macroKcal = m.proteinG * 4 + m.carbsG * 4 + m.fatG * 9;
      expect(macroKcal, lessThanOrEqualTo(m.kcal * 1.4), reason: m.nameEn);
    }
  });

  test('locale accessors resolve', () {
    final m = GuidebookData.meals.first;
    expect(m.name('ar'), m.nameAr);
    expect(m.name('en'), m.nameEn);
    expect(m.components('en'), m.componentsEn);
    expect(m.prep('ar'), m.prepAr);
    expect(m.nutrition.caloriesKcal, m.kcal);
  });
}
