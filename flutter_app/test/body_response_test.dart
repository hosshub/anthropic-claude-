import 'package:flutter_test/flutter_test.dart';
import 'package:tayyibat/models/body_response.dart';

/// Enum round-trips and map (de)serialization for the body-response model.
void main() {
  group('SleepImpact', () {
    test('fromRaw round-trips every value', () {
      for (final v in SleepImpact.values) {
        expect(SleepImpactX.fromRaw(v.raw), v);
      }
    });

    test('unknown / null raw falls back to unknown', () {
      expect(SleepImpactX.fromRaw('nope'), SleepImpact.unknown);
      expect(SleepImpactX.fromRaw(null), SleepImpact.unknown);
    });
  });

  group('WorthRepeating', () {
    test('fromRaw round-trips every value', () {
      for (final v in WorthRepeating.values) {
        expect(WorthRepeatingX.fromRaw(v.raw), v);
      }
    });

    test('unknown / null raw falls back to maybe', () {
      expect(WorthRepeatingX.fromRaw('nope'), WorthRepeating.maybe);
      expect(WorthRepeatingX.fromRaw(null), WorthRepeating.maybe);
    });

    test('every value exposes a non-empty emoji', () {
      for (final v in WorthRepeating.values) {
        expect(v.emoji, isNotEmpty);
      }
    });
  });

  group('BodyResponse map round-trip', () {
    test('toMap -> fromMap preserves all fields', () {
      final logged = DateTime.fromMillisecondsSinceEpoch(1700000000000);
      final original = BodyResponse(
        id: 'r1',
        mealId: 'm1',
        loggedAt: logged,
        hoursAfterMeal: 3,
        satisfyingFullness: 4,
        bloating: 1,
        energyLevel: 5,
        sleepImpact: SleepImpact.positive,
        worthRepeating: WorthRepeating.yes,
        notes: 'felt great',
      );

      final restored = BodyResponse.fromMap(original.toMap());
      expect(restored.id, 'r1');
      expect(restored.mealId, 'm1');
      expect(restored.loggedAt, logged);
      expect(restored.hoursAfterMeal, 3);
      expect(restored.satisfyingFullness, 4);
      expect(restored.bloating, 1);
      expect(restored.energyLevel, 5);
      expect(restored.sleepImpact, SleepImpact.positive);
      expect(restored.worthRepeating, WorthRepeating.yes);
      expect(restored.notes, 'felt great');
    });

    test('fromMap tolerates missing optional columns', () {
      final restored = BodyResponse.fromMap({
        'id': 'r2',
        'meal_id': 'm2',
        'logged_at': 1700000000000,
        // everything else missing
      });
      expect(restored.hoursAfterMeal, 0);
      expect(restored.satisfyingFullness, 3);
      expect(restored.bloating, 0);
      expect(restored.energyLevel, 3);
      expect(restored.sleepImpact, SleepImpact.unknown);
      expect(restored.worthRepeating, WorthRepeating.maybe);
      expect(restored.notes, isNull);
    });
  });
}
