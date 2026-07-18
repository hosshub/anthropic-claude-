import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tayyibat/l10n/generated/app_localizations.dart';
import 'package:tayyibat/services/app_messages.dart';

/// Guards for the error-sanitization layer added after Apple's 2.1(a)
/// rejection of 1.0.2(5): Gemini's raw billing message ("Your prepayment
/// credits are depleted. Please go to AI Studio at https://...") reached the
/// UI. These tests pin the contract: provider/internal text never survives
/// sanitization, and every caught error resolves to a clean localized string.
void main() {
  group('sanitizeServerMessage', () {
    test('passes through our own short localized messages', () {
      expect(
        sanitizeServerMessage('بلغت الحد اليومي للتحليلات (7). جرّب مجدداً غداً.'),
        isNotNull,
      );
      expect(
        sanitizeServerMessage('The service is busy right now. Please try again in a little while.'),
        isNotNull,
      );
      expect(
        sanitizeServerMessage('تعذّر تحليل هذه الصورة. جرّب زاوية أو إضاءة مختلفة.'),
        isNotNull,
      );
    });

    test('rejects the exact Gemini billing message Apple saw', () {
      expect(
        sanitizeServerMessage(
          'Your prepayment credits are depleted. Please go to AI Studio at '
          'https://ai.studio/projects to manage your project and billing. '
          'Learn more at https://ai.google.dev/gemini-api/docs/billing#prepay',
        ),
        isNull,
      );
    });

    test('rejects URLs, provider markers, and oversized messages', () {
      expect(sanitizeServerMessage('See https://example.com for details'), isNull);
      expect(sanitizeServerMessage('Invalid API key provided'), isNull);
      expect(sanitizeServerMessage('Quota exceeded for quota metric'), isNull);
      expect(sanitizeServerMessage('Check your billing account'), isNull);
      expect(sanitizeServerMessage('a' * 200), isNull);
      expect(sanitizeServerMessage('   '), isNull);
      expect(sanitizeServerMessage(null), isNull);
    });
  });

  group('describeError', () {
    Future<AppLocalizations> load(WidgetTester tester, Locale locale) async {
      late AppLocalizations l;
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              l = AppLocalizations.of(context)!;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      return l;
    }

    testWidgets('AppException with server message renders it', (tester) async {
      final l = await load(tester, const Locale('ar'));
      final e = AppException(
        AppMessage.analyzeBadResponse,
        serverMessage: 'رسالة من الخادم',
      );
      expect(describeError(l, e), 'رسالة من الخادم');
    });

    testWidgets('AppException without server message localizes the code',
        (tester) async {
      final l = await load(tester, const Locale('en'));
      final e = AppException(AppMessage.analyzeDailyCapReached);
      expect(describeError(l, e), l.analyze_dailyCapReached);
    });

    testWidgets('timeouts and socket errors map to the network message',
        (tester) async {
      final l = await load(tester, const Locale('en'));
      expect(
        describeError(l, Exception('TimeoutException after 0:00:30')),
        l.error_network,
      );
      expect(
        describeError(l, Exception('SocketException: Failed host lookup')),
        l.error_network,
      );
    });

    testWidgets('anything else maps to the generic unexpected message',
        (tester) async {
      final l = await load(tester, const Locale('ar'));
      expect(describeError(l, StateError('boom')), l.error_unexpected);
      // Raw text must never leak through.
      expect(describeError(l, StateError('boom')).contains('boom'), isFalse);
    });
  });
}
