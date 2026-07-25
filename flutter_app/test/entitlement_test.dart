import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tayyibat/services/entitlement.dart';

/// v1.4 — free download + premium. The pure decisions live here so they can be
/// tested without StoreKit: who counts as premium, who was grandfathered, and
/// whether a free user has scans left this week.
void main() {
  test('the client and server grandfathering cutoffs are the same instant', () {
    // The client decides what to show; the server decides what to allow. If
    // these two dates ever drift apart a paying customer sees premium in the
    // app and gets refused by analyze() — a silent failure that only surfaces
    // as a support email. Cheap to assert, expensive to discover.
    final sql = File('../supabase/sql/entitlements.sql').readAsStringSync();
    final literal =
        RegExp(r"select\s+'([^']+)'::timestamptz").firstMatch(sql)?.group(1);
    expect(
      literal,
      isNotNull,
      reason: 'paid_era_cutoff() no longer returns a plain timestamptz literal '
          '— update this test to match how the SQL now spells the date',
    );
    expect(
      DateTime.parse(literal!).toUtc(),
      paidEraCutoffDefault,
      reason: 'entitlement.dart and entitlements.sql must agree',
    );
  });

  group('isGrandfathered', () {
    // Anyone who created an account while the app was paid-only necessarily
    // paid for it, so account age is a sound proxy for "existing buyer".
    final cutoff = DateTime.utc(2026, 8, 1);

    test('an account created before the switch is grandfathered', () {
      expect(
        isGrandfathered(
          accountCreatedAt: DateTime.utc(2026, 7, 20),
          paidEraCutoff: cutoff,
        ),
        isTrue,
      );
    });

    test('an account created after the switch is not', () {
      expect(
        isGrandfathered(
          accountCreatedAt: DateTime.utc(2026, 8, 2),
          paidEraCutoff: cutoff,
        ),
        isFalse,
      );
    });

    test('exactly at the cutoff is not grandfathered (switch is inclusive)',
        () {
      expect(
        isGrandfathered(accountCreatedAt: cutoff, paidEraCutoff: cutoff),
        isFalse,
      );
    });

    test('unknown account date is not grandfathered', () {
      expect(
        isGrandfathered(accountCreatedAt: null, paidEraCutoff: cutoff),
        isFalse,
      );
    });
  });

  group('Entitlement.tier', () {
    test('an active purchase is premium', () {
      expect(
        resolveTier(hasActivePurchase: true, grandfathered: false),
        Tier.premium,
      );
    });

    test('a grandfathered user is premium without any purchase', () {
      expect(
        resolveTier(hasActivePurchase: false, grandfathered: true),
        Tier.premium,
      );
    });

    test('everyone else is free', () {
      expect(
        resolveTier(hasActivePurchase: false, grandfathered: false),
        Tier.free,
      );
    });
  });

  group('scansRemainingThisWeek', () {
    final monday = DateTime(2026, 8, 3); // a Monday
    DateTime day(int offset, [int hour = 12]) =>
        DateTime(monday.year, monday.month, monday.day + offset, hour);

    test('premium is never limited', () {
      expect(
        scansRemainingThisWeek(
          tier: Tier.premium,
          scanTimes: List.generate(50, (i) => day(0, i % 24)),
          now: day(3),
        ),
        isNull, // null = unlimited
      );
    });

    test('a fresh free user has the full weekly allowance', () {
      expect(
        scansRemainingThisWeek(
          tier: Tier.free,
          scanTimes: const [],
          now: day(2),
        ),
        freeScansPerWeek,
      );
    });

    test('scans inside the current week count against the allowance', () {
      expect(
        scansRemainingThisWeek(
          tier: Tier.free,
          scanTimes: [day(0), day(1)],
          now: day(2),
        ),
        freeScansPerWeek - 2,
      );
    });

    test('the allowance never goes negative', () {
      expect(
        scansRemainingThisWeek(
          tier: Tier.free,
          scanTimes: [day(0), day(0), day(1), day(2), day(2)],
          now: day(3),
        ),
        0,
      );
    });

    test('scans from a previous week do not count', () {
      expect(
        scansRemainingThisWeek(
          tier: Tier.free,
          scanTimes: [day(-3), day(-5), day(-7)],
          now: day(1),
        ),
        freeScansPerWeek,
      );
    });

    test('the week resets on Saturday, matching the app calendar', () {
      // The app's calendar and weekly prep both run Saturday → Friday.
      final saturday = DateTime(2026, 8, 1); // a Saturday
      final fridayBefore = DateTime(2026, 7, 31, 20);
      expect(
        scansRemainingThisWeek(
          tier: Tier.free,
          scanTimes: [fridayBefore, fridayBefore, fridayBefore],
          now: saturday,
        ),
        freeScansPerWeek,
        reason: 'a new Saturday starts a fresh allowance',
      );
    });
  });

  group('hasWeeklyAllowance — the free suggestion allowance', () {
    final saturday = DateTime(2026, 8, 1); // week start
    final wednesday = DateTime(2026, 8, 5);

    test('never used → allowed', () {
      expect(
        hasWeeklyAllowance(lastUsedAt: null, now: wednesday),
        isTrue,
      );
    });

    test('used earlier this week → not allowed', () {
      expect(
        hasWeeklyAllowance(
          lastUsedAt: DateTime(2026, 8, 2),
          now: wednesday,
        ),
        isFalse,
      );
    });

    test('used last week → allowed again', () {
      expect(
        hasWeeklyAllowance(
          lastUsedAt: DateTime(2026, 7, 30),
          now: wednesday,
        ),
        isTrue,
      );
    });

    test('used exactly at the week start counts as used', () {
      expect(
        hasWeeklyAllowance(lastUsedAt: saturday, now: wednesday),
        isFalse,
      );
    });
  });

  group('canScan', () {
    test('free user with scans left may scan', () {
      expect(canScan(remaining: 2), isTrue);
    });

    test('free user out of scans may not', () {
      expect(canScan(remaining: 0), isFalse);
    });

    test('premium (null remaining) may always scan', () {
      expect(canScan(remaining: null), isTrue);
    });
  });
}
