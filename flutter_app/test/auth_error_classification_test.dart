import 'package:flutter_test/flutter_test.dart';
import 'package:tayyibat/services/app_messages.dart';
import 'package:tayyibat/services/auth_service.dart';

/// Supabase wraps transport failures (DNS, socket, timeout) in
/// `AuthRetryableFetchException`, which **extends AuthException** and carries
/// the raw Dart text as its message (gotrue fetch.dart:
/// `throw AuthRetryableFetchException(message: error.toString())`).
///
/// Because our catch order puts `on AuthException` before the generic `catch`,
/// that raw text — e.g. "ClientException with SocketException: Failed host
/// lookup: 'xyz.supabase.co'" — reached the sign-in screen verbatim. Apple
/// rejected 1.0.2 under Guideline 2.1(a) for exactly this class of leakage, so
/// transport noise must map to the friendly network message instead.
void main() {
  group('codeForAuthExceptionMessage — transport noise is never shown raw', () {
    const transportMessages = [
      // The exact string a paused/unreachable project produces.
      "ClientException with SocketException: Failed host lookup: "
          "'cvznuwvwhnujdgfojmsb.supabase.co' (OS Error: nodename nor servname "
          "provided, or not known, errno = 8)",
      'SocketException: Connection refused',
      'Failed host lookup: example.supabase.co',
      'TimeoutException after 0:00:30.000000',
      'Connection closed before full header was received',
      'ClientException: Connection reset by peer',
      'Network is unreachable',
    ];

    for (final m in transportMessages) {
      test('maps: ${m.substring(0, m.length > 42 ? 42 : m.length)}…', () {
        expect(
          AuthService.codeForAuthExceptionMessage(m),
          AppMessage.authNetworkError,
          reason: 'raw transport text must not reach the UI',
        );
      });
    }
  });

  group('codeForAuthExceptionMessage — genuine auth errors stay visible', () {
    const realAuthMessages = [
      'Invalid login credentials',
      'Email not confirmed',
      'User already registered',
      'Password should be at least 6 characters',
      'Email rate limit exceeded',
    ];

    for (final m in realAuthMessages) {
      test('passes through: $m', () {
        expect(
          AuthService.codeForAuthExceptionMessage(m),
          isNull,
          reason: 'actionable auth errors should still be shown to the user',
        );
      });
    }
  });

  test('classification is case-insensitive', () {
    expect(
      AuthService.codeForAuthExceptionMessage('FAILED HOST LOOKUP: x'),
      AppMessage.authNetworkError,
    );
  });

  test('empty message is treated as an unexpected error, not raw', () {
    expect(
      AuthService.codeForAuthExceptionMessage(''),
      AppMessage.authUnexpectedError,
    );
  });
}
