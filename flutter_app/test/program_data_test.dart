import 'package:flutter_test/flutter_test.dart';
import 'package:tayyibat/data/program_data.dart';

/// Tests for the 15-day program: status math, phase coverage, numerals.
void main() {
  // Midnight today, used to build deterministic relative start dates.
  DateTime startNDaysAgo(int n) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).subtract(Duration(days: n));
  }

  group('statusFor', () {
    test('null start => NotStarted', () {
      expect(ProgramData.statusFor(null), isA<NotStarted>());
    });

    test('started today => day 1', () {
      final status = ProgramData.statusFor(DateTime.now());
      expect(status, isA<InProgress>());
      expect((status as InProgress).day, 1);
    });

    test('a future start clamps to day 1', () {
      final status =
          ProgramData.statusFor(DateTime.now().add(const Duration(days: 5)));
      expect(status, isA<InProgress>());
      expect((status as InProgress).day, 1);
    });

    test('started ~5 days ago is in progress within 1..15', () {
      // Tolerant on the exact day (a DST boundary can shift inDays by one),
      // but the branch and bounds are deterministic.
      final status = ProgramData.statusFor(startNDaysAgo(5));
      expect(status, isA<InProgress>());
      expect((status as InProgress).day, inInclusiveRange(5, 6));
    });

    test('around the last day it is still in progress', () {
      // elapsed ~= 15 -> InProgress(15) (DST-tolerant: 14 or 15).
      final status = ProgramData.statusFor(startNDaysAgo(14));
      expect(status, isA<InProgress>());
      expect((status as InProgress).day, inInclusiveRange(14, 15));
    });

    test('well past the program => Completed', () {
      // 25 days ago is safely past 15 even with any DST jitter.
      expect(ProgramData.statusFor(startNDaysAgo(25)), isA<Completed>());
    });
  });

  group('phaseFor / phases', () {
    test('there are exactly 4 phases covering days 1..15 contiguously', () {
      expect(ProgramData.phases, hasLength(4));
      for (var day = 1; day <= 15; day++) {
        final owning =
            ProgramData.phases.where((p) => p.contains(day)).toList();
        expect(owning, hasLength(1),
            reason: 'day $day must belong to exactly one phase');
      }
    });

    test('phaseFor maps representative days to the right phase number', () {
      expect(ProgramData.phaseFor(1).number, 1);
      expect(ProgramData.phaseFor(3).number, 1);
      expect(ProgramData.phaseFor(4).number, 2);
      expect(ProgramData.phaseFor(7).number, 2);
      expect(ProgramData.phaseFor(8).number, 3);
      expect(ProgramData.phaseFor(11).number, 3);
      expect(ProgramData.phaseFor(12).number, 4);
      expect(ProgramData.phaseFor(15).number, 4);
    });
  });

  group('days', () {
    test('has 15 entries numbered 1..15 in order', () {
      expect(ProgramData.days, hasLength(15));
      for (var i = 0; i < 15; i++) {
        expect(ProgramData.days[i].day, i + 1);
      }
    });

    test('day(n) returns the right entry, null when out of range', () {
      expect(ProgramData.day(1)!.day, 1);
      expect(ProgramData.day(15)!.day, 15);
      expect(ProgramData.day(0), isNull);
      expect(ProgramData.day(16), isNull);
    });
  });

  group('numerals', () {
    test('arabicNumeral maps every digit', () {
      expect(arabicNumeral(0), '٠');
      expect(arabicNumeral(15), '١٥');
      expect(arabicNumeral(2026), '٢٠٢٦');
    });

    test('localizedNumeral keeps Latin for en, Arabic-Indic for ar', () {
      expect(localizedNumeral(15, 'en'), '15');
      expect(localizedNumeral(15, 'ar'), '١٥');
    });
  });
}
