import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tayyibat/l10n/generated/app_localizations.dart';

/// End-to-end check of the gen-l10n wiring: both .arb files generate, the
/// delegate loads, and representative keys (including ones added in v1.0.1)
/// resolve in both languages.
///
/// Note: requires `flutter gen-l10n` to have run first (the CI workflow does
/// this before `flutter test`).
void main() {
  Future<void> pumpWithLocale(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l = AppLocalizations.of(context)!;
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                children: [
                  Text(l.appTitle),
                  Text(l.tab_today),
                  Text(l.guide_index_title),
                  Text(l.program_start),
                  Text(l.mealBanks_capture),
                ],
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('English locale resolves UI + content keys', (tester) async {
    await pumpWithLocale(tester, const Locale('en'));
    expect(find.text('Tayyibat'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Smart index'), findsOneWidget);
    expect(find.text('Start the program today'), findsOneWidget);
    expect(find.text('Photograph this meal'), findsOneWidget);
  });

  testWidgets('Arabic locale resolves UI + content keys', (tester) async {
    await pumpWithLocale(tester, const Locale('ar'));
    expect(find.text('الطيبات'), findsOneWidget);
    expect(find.text('اليوم'), findsOneWidget);
    expect(find.text('الفهرس الذكي'), findsOneWidget);
    expect(find.text('ابدأ البرنامج اليوم'), findsOneWidget);
    expect(find.text('صوّر هذه الوجبة'), findsOneWidget);
  });

  test('supports exactly Arabic and English', () {
    final codes =
        AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
    expect(codes, {'ar', 'en'});
  });
}
