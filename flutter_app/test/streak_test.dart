import 'package:flutter_test/flutter_test.dart';
import 'package:tayyibat/services/streak.dart';

/// v1.2.1 — logging streak: consecutive days with at least one logged meal.
/// A streak survives until a full day is skipped: if today has no log yet
/// but yesterday does, the streak is still alive.
void main() {
  final now = DateTime(2026, 7, 24, 15, 30);
  DateTime day(int daysAgo, [int hour = 12]) =>
      DateTime(2026, 7, 24 - daysAgo, hour);

  group('loggedStreak', () {
    test('no meals → 0', () {
      expect(loggedStreak(const [], now: now), 0);
    });

    test('only today → 1', () {
      expect(loggedStreak([day(0, 9)], now: now), 1);
    });

    test('three consecutive days ending today → 3', () {
      expect(
        loggedStreak([day(0), day(1), day(2)], now: now),
        3,
      );
    });

    test('yesterday logged but today not yet → streak still alive', () {
      expect(loggedStreak([day(1), day(2)], now: now), 2);
    });

    test('gap two days ago breaks the streak', () {
      // logged today and yesterday, skipped day 2, logged day 3
      expect(
        loggedStreak([day(0), day(1), day(3)], now: now),
        2,
      );
    });

    test('last log two days ago → streak dead → 0', () {
      expect(loggedStreak([day(2), day(3)], now: now), 0);
    });

    test('multiple meals in one day count as one day', () {
      expect(
        loggedStreak([day(0, 8), day(0, 13), day(0, 20), day(1)], now: now),
        2,
      );
    });

    test('unsorted input is handled', () {
      expect(
        loggedStreak([day(2), day(0), day(1)], now: now),
        3,
      );
    });
  });
}
