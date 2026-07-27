import 'package:flutter_test/flutter_test.dart';
import 'package:tayyibat/services/plan_adherence.dart';

DateTime d(int day) => DateTime(2026, 8, day);

/// v1.3.0 — plan adherence blends manual check-off with an auto check that
/// a meal was logged that calendar day. Only days up to `today` count.
void main() {
  group('planAdherenceScore', () {
    test('no elapsed days (plan starts today, nothing done) → 0', () {
      expect(
        planAdherenceScore(
          startedAt: d(10),
          dayManualFractions: const [0, 0, 0],
          loggedDates: const {},
          today: d(10),
        ),
        0,
      );
    });

    test('all planned days ticked → 100', () {
      expect(
        planAdherenceScore(
          startedAt: d(1),
          dayManualFractions: const [1, 1, 1],
          loggedDates: const {},
          today: d(3),
        ),
        100,
      );
    });

    test('logged that day counts even if not ticked', () {
      // day 0 logged (auto=1), day 1 nothing → (1 + 0)/2 = 50
      expect(
        planAdherenceScore(
          startedAt: d(1),
          dayManualFractions: const [0, 0],
          loggedDates: {d(1)},
          today: d(2),
        ),
        50,
      );
    });

    test('per-day takes the better of manual fraction and auto', () {
      // day0: manual 0.5, not logged → 0.5 ; day1: manual 0, logged → 1.0
      // (0.5 + 1.0) / 2 = 75
      expect(
        planAdherenceScore(
          startedAt: d(1),
          dayManualFractions: const [0.5, 0.0],
          loggedDates: {d(2)},
          today: d(2),
        ),
        75,
      );
    });

    test('future days are excluded from the denominator', () {
      // 7-day plan, only 2 days elapsed, both done → 100 (not 2/7)
      expect(
        planAdherenceScore(
          startedAt: d(1),
          dayManualFractions: const [1, 1, 0, 0, 0, 0, 0],
          loggedDates: const {},
          today: d(2),
        ),
        100,
      );
    });

    test('mixed real week', () {
      // days elapsed: 3. d1 logged, d2 half-ticked, d3 nothing.
      // (1.0 + 0.5 + 0.0)/3 = 50
      expect(
        planAdherenceScore(
          startedAt: d(1),
          dayManualFractions: const [0.0, 0.5, 0.0, 0.0],
          loggedDates: {d(1)},
          today: d(3),
        ),
        50,
      );
    });
  });
}
