import 'package:flutter_test/flutter_test.dart';
import 'package:tayyibat/services/health_math.dart';

DateTime t(int h, [int m = 0]) => DateTime(2026, 8, 1, h, m);

/// v1.3 Apple Health helpers. Pure so they can be tested without HealthKit.
void main() {
  group('sleepMinutesFromIntervals', () {
    test('no samples → 0', () {
      expect(sleepMinutesFromIntervals(const []), 0);
    });

    test('a single interval is its own duration', () {
      expect(
        sleepMinutesFromIntervals([(start: t(23), end: t(23, 45))]),
        45,
      );
    });

    test('adjacent intervals sum', () {
      expect(
        sleepMinutesFromIntervals([
          (start: t(1), end: t(2)),
          (start: t(3), end: t(3, 30)),
        ]),
        90,
      );
    });

    test('overlapping samples merge instead of double-counting', () {
      // The Watch and the phone both record the same night — naive summing
      // would report 120 minutes for a single 90-minute stretch.
      expect(
        sleepMinutesFromIntervals([
          (start: t(1), end: t(2)),
          (start: t(1, 30), end: t(2, 30)),
        ]),
        90,
      );
    });

    test('a fully contained sample adds nothing', () {
      expect(
        sleepMinutesFromIntervals([
          (start: t(1), end: t(4)),
          (start: t(2), end: t(3)),
        ]),
        180,
      );
    });

    test('unsorted input is handled', () {
      expect(
        sleepMinutesFromIntervals([
          (start: t(3), end: t(4)),
          (start: t(1), end: t(2)),
        ]),
        120,
      );
    });

    test('zero-length and inverted intervals are ignored', () {
      expect(
        sleepMinutesFromIntervals([
          (start: t(1), end: t(1)),
          (start: t(5), end: t(4)),
          (start: t(2), end: t(2, 20)),
        ]),
        20,
      );
    });
  });

  group('latestSampleValue', () {
    test('null when there are no samples', () {
      expect(latestSampleValue(const []), isNull);
    });

    test('picks the most recent sample, not the largest', () {
      expect(
        latestSampleValue([
          (at: t(9), value: 82.5),
          (at: t(18), value: 81.0),
          (at: t(12), value: 90.0),
        ]),
        81.0,
      );
    });
  });

  group('shouldWriteMealEnergy', () {
    test('writes only when connected, enabled, and there are calories', () {
      expect(
        shouldWriteMealEnergy(connected: true, writeEnabled: true, kcal: 500),
        isTrue,
      );
    });

    test('never writes when the user has not connected Health', () {
      expect(
        shouldWriteMealEnergy(connected: false, writeEnabled: true, kcal: 500),
        isFalse,
      );
    });

    test('never writes when the write toggle is off', () {
      expect(
        shouldWriteMealEnergy(connected: true, writeEnabled: false, kcal: 500),
        isFalse,
      );
    });

    test('skips meals with no calorie estimate', () {
      expect(
        shouldWriteMealEnergy(connected: true, writeEnabled: true, kcal: 0),
        isFalse,
      );
    });
  });
}
