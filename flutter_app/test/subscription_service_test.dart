import 'package:flutter_test/flutter_test.dart';
import 'package:tayyibat/services/entitlement.dart';
import 'package:tayyibat/services/subscription_service.dart';

/// v1.4 — entitlement must follow the *current* session, not the session that
/// happened to be open when the app launched.
///
/// SubscriptionService is created once at the root of the widget tree and
/// outlives every sign-in and sign-out. Anything it caches at startup is a
/// claim about a user who may since have signed out, deleted their account, or
/// been replaced by somebody else on the same phone.
void main() {
  group('grandfathering follows the current session', () {
    test('signing out drops premium that came from account age', () {
      // A pre-cutoff account: grandfathered, so premium without any purchase.
      DateTime? createdAt = DateTime.utc(2026, 7, 1);
      final subs = SubscriptionService(accountCreatedAt: () => createdAt);
      expect(subs.isPremium, isTrue);

      createdAt = null; // signed out — there is no account to grandfather
      expect(
        subs.isPremium,
        isFalse,
        reason: 'a signed-out app must not keep the previous user\'s premium',
      );
    });

    test('a different user signing in afterwards gets their own answer', () {
      // The phone is handed over: the first account predates the switch, the
      // second was created after it and must land on the free tier.
      DateTime? createdAt = DateTime.utc(2026, 7, 1);
      final subs = SubscriptionService(accountCreatedAt: () => createdAt);
      expect(subs.isPremium, isTrue);

      createdAt = paidEraCutoffDefault.add(const Duration(days: 30));
      expect(
        subs.isPremium,
        isFalse,
        reason: 'an account created after the cutoff never paid for the app',
      );
    });

    test('an account created before the cutoff is premium for life', () {
      final subs = SubscriptionService(
        accountCreatedAt: () =>
            paidEraCutoffDefault.subtract(const Duration(days: 1)),
      );
      expect(subs.isGrandfatheredUser, isTrue);
      expect(subs.tier, Tier.premium);
    });
  });
}
