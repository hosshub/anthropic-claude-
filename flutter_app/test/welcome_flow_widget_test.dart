import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayyibat/features/onboarding/welcome_flow.dart';
import 'package:tayyibat/l10n/generated/app_localizations.dart';
import 'package:tayyibat/services/profile_service.dart';

/// v1.2.1 review recommendation — the welcome flow must never gate the app:
/// skipping on step 0 completes onboarding without any profile data.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProfileService> pumpFlow(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final profile = ProfileService();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: profile,
        child: const MaterialApp(
          locale: Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WelcomeFlow(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return profile;
  }

  testWidgets('skip on the first step completes onboarding with no name',
      (tester) async {
    final profile = await pumpFlow(tester);
    expect(profile.hasCompletedOnboarding, isFalse);

    await tester.tap(find.text('تخطّي'));
    await tester.pumpAndSettle();

    expect(profile.hasCompletedOnboarding, isTrue);
    expect(profile.displayName, isNull);
    expect(profile.age, isNull);
  });

  testWidgets('completing all steps saves the entered name', (tester) async {
    final profile = await pumpFlow(tester);

    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'حسام');
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ابدأ الآن'));
    await tester.pumpAndSettle();

    expect(profile.hasCompletedOnboarding, isTrue);
    expect(profile.displayName, 'حسام');
  });
}
