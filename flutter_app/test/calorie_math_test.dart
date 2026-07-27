import 'package:flutter_test/flutter_test.dart';
import 'package:tayyibat/services/calorie_math.dart';

/// v1.3.0 — Apple Health offsets the daily budget: calories burned are
/// added to the goal before subtracting what was consumed.
void main() {
  group('calorieRemaining', () {
    test('no burned calories behaves like the plain budget', () {
      expect(calorieRemaining(goal: 2000, consumed: 500), 1500);
    });

    test('burned calories raise the remaining budget', () {
      expect(calorieRemaining(goal: 2000, consumed: 500, burned: 300), 1800);
    });

    test('going over the (offset) budget is negative', () {
      expect(calorieRemaining(goal: 2000, consumed: 2500, burned: 200), -300);
    });

    test('adjustedGoal is goal plus burned', () {
      expect(adjustedGoal(goal: 2000, burned: 350), 2350);
    });
  });
}
