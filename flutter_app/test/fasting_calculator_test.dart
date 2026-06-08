import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:tayyibat/services/fasting_calculator.dart';

/// Pure-logic tests for the fasting day calculator. No platform binding needed.
void main() {
  group('dateKey', () {
    test('formats as zero-padded yyyy-MM-dd (Gregorian)', () {
      expect(FastingCalculator.dateKey(DateTime(2025, 3, 7)), '2025-03-07');
      expect(FastingCalculator.dateKey(DateTime(2025, 12, 31)), '2025-12-31');
      expect(FastingCalculator.dateKey(DateTime(2026, 1, 1)), '2026-01-01');
    });

    test('ignores the time component', () {
      final a = FastingCalculator.dateKey(DateTime(2025, 5, 9, 0, 0));
      final b = FastingCalculator.dateKey(DateTime(2025, 5, 9, 23, 59));
      expect(a, b);
    });
  });

  group('kindsFor', () {
    // Property test: over a 400-day window, the kinds the calculator returns
    // must agree with an independent oracle (DateTime.weekday for Mon/Thu, and
    // the hijri package for the white days 13/14/15).
    test('matches an independent oracle across 400 days', () {
      for (var i = 0; i < 400; i++) {
        final d = DateTime(2025, 1, 1).add(Duration(days: i));
        final kinds = FastingCalculator.kindsFor(d);

        expect(
          kinds.contains(FastingKind.monday),
          d.weekday == DateTime.monday,
          reason: 'monday mismatch on $d',
        );
        expect(
          kinds.contains(FastingKind.thursday),
          d.weekday == DateTime.thursday,
          reason: 'thursday mismatch on $d',
        );

        final hDay = HijriCalendar.fromDate(d).hDay;
        expect(kinds.contains(FastingKind.whiteDay13), hDay == 13,
            reason: 'white13 mismatch on $d (hDay=$hDay)');
        expect(kinds.contains(FastingKind.whiteDay14), hDay == 14,
            reason: 'white14 mismatch on $d (hDay=$hDay)');
        expect(kinds.contains(FastingKind.whiteDay15), hDay == 15,
            reason: 'white15 mismatch on $d (hDay=$hDay)');

        // `general` is only ever logged manually, never auto-derived.
        expect(kinds.contains(FastingKind.general), isFalse);
      }
    });

    test('orders Gregorian (Mon/Thu) before the white days', () {
      // Scan until we hit a day that is both a weekday-kind and a white day.
      var found = false;
      for (var i = 0; i < 400 && !found; i++) {
        final d = DateTime(2025, 1, 1).add(Duration(days: i));
        final kinds = FastingCalculator.kindsFor(d);
        final hasWeekday = kinds.contains(FastingKind.monday) ||
            kinds.contains(FastingKind.thursday);
        final whiteIndex = kinds.indexWhere((k) =>
            k == FastingKind.whiteDay13 ||
            k == FastingKind.whiteDay14 ||
            k == FastingKind.whiteDay15);
        if (hasWeekday && whiteIndex != -1) {
          found = true;
          final weekdayIndex = kinds.indexWhere((k) =>
              k == FastingKind.monday || k == FastingKind.thursday);
          expect(weekdayIndex, lessThan(whiteIndex));
        }
      }
      expect(found, isTrue,
          reason: 'expected at least one overlapping weekday+white day');
    });

    test('returns no kinds for an ordinary, non-white weekday', () {
      // Find a date that is neither Mon/Thu nor a white day and assert empty.
      DateTime? plain;
      for (var i = 0; i < 60 && plain == null; i++) {
        final d = DateTime(2025, 1, 1).add(Duration(days: i));
        if (FastingCalculator.kindsFor(d).isEmpty) plain = d;
      }
      expect(plain, isNotNull);
      expect(FastingCalculator.kindsFor(plain!), isEmpty);
    });
  });

  group('nextRecommended', () {
    test('returns the earliest upcoming day with kinds', () {
      final from = DateTime(2025, 6, 1);
      final next = FastingCalculator.nextRecommended(from);
      expect(next, isNotNull);
      expect(next!.kinds, isNotEmpty);

      // No day in [from, next.date) should itself be recommended.
      for (var d = from;
          d.isBefore(DateTime(next.date.year, next.date.month, next.date.day));
          d = d.add(const Duration(days: 1))) {
        expect(FastingCalculator.kindsFor(d), isEmpty,
            reason: '$d should have been the earlier recommendation');
      }
    });

    test('returns the start date itself when it is already recommended', () {
      // Walk to the next Monday and confirm nextRecommended(thatMonday) == it.
      var monday = DateTime(2025, 6, 1);
      while (monday.weekday != DateTime.monday) {
        monday = monday.add(const Duration(days: 1));
      }
      final next = FastingCalculator.nextRecommended(monday)!;
      expect(next.date.year, monday.year);
      expect(next.date.month, monday.month);
      expect(next.date.day, monday.day);
      expect(next.kinds, contains(FastingKind.monday));
    });
  });

  group('hijriShort', () {
    test('renders a non-empty hijri label ending in the hijri marker', () {
      final s = FastingCalculator.hijriShort(DateTime(2025, 6, 8));
      expect(s, isNotEmpty);
      expect(s.contains('هـ'), isTrue);
    });
  });
}
