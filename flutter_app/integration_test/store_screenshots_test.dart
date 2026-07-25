import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayyibat/data/database.dart';
import 'package:tayyibat/data/meal_repository.dart';
import 'package:tayyibat/l10n/generated/app_localizations.dart';
import 'package:tayyibat/main.dart' as app;

/// Captures App Store screenshots by driving the real app on a booted
/// simulator. Run per locale:
///   flutter drive \
///     --driver=test_driver/store_screenshots_driver.dart \
///     --target=integration_test/store_screenshots_test.dart \
///     -d <sim-udid> \
///     --dart-define=SCREENSHOT=true --dart-define=SHOT_LOCALE=ar
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const locale = String.fromEnvironment('SHOT_LOCALE', defaultValue: 'ar');

  testWidgets('capture store screenshots ($locale)', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', locale);
    await TayyibatDatabase.close();
    final repo = MealRepository();
    await repo.deleteAll();
    await repo.seedDemoData(locale: locale);

    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final l = AppLocalizations.of(
      tester.element(find.byType(Navigator).first),
    )!;

    Future<void> shot(String file) async {
      await tester.pumpAndSettle();
      if (!Platform.isIOS) {
        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
      }
      await binding.takeScreenshot('$locale/$file');
    }

    // Pop every pushed route via the root Navigator until MainShell (the
    // home route, which can't be popped) is showing. Route-offstage finders
    // proved unreliable on iOS, so drive the NavigatorState directly.
    Future<void> ensureShell() async {
      try {
        final nav =
            tester.state<NavigatorState>(find.byType(Navigator).first);
        var guard = 0;
        while (nav.canPop() && guard++ < 8) {
          nav.pop();
          await tester.pumpAndSettle();
        }
      } catch (_) {}
    }

    // Pump (not settle) until a finder appears — waits out async DB loads
    // that pumpAndSettle ignores.
    Future<bool> waitFor(Finder f, {int tries = 25}) async {
      for (var i = 0; i < tries; i++) {
        if (f.evaluate().isNotEmpty) return true;
        await tester.pump(const Duration(milliseconds: 150));
      }
      return false;
    }

    Future<void> gotoTab(String label) async {
      await ensureShell();
      final f = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      );
      if (f.evaluate().isEmpty) return;
      await tester.tap(f.first);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
    }

    // Scroll a title into view (guide sections below the fold), then tap it.
    Future<void> openByText(String title) async {
      final f = find.text(title);
      if (f.evaluate().isEmpty) {
        try {
          await tester.scrollUntilVisible(
            f,
            300,
            scrollable: find.byType(Scrollable).first,
            maxScrolls: 20,
          );
        } catch (_) {}
      }
      await tester.ensureVisible(f.first);
      await tester.pumpAndSettle();
      await tester.tap(f.first);
      await tester.pumpAndSettle(const Duration(milliseconds: 800));
    }

    Future<void> screen(String file, Future<void> Function() body) async {
      try {
        await body();
        await shot(file);
      } catch (e) {
        debugPrint('SHOT $file failed: $e');
      }
      await ensureShell();
    }

    // 1) Today.
    await shot('01_today');

    // 2) Guide → eating map.
    await gotoTab(l.tab_guide);
    await screen('02_eating_map', () => openByText(l.guide_section_eatingMap));

    // 3) History list — the meal log with colour-coded scores (own screen).
    await gotoTab(l.tab_history);
    await waitFor(find.byType(ListView));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    await shot('03_history');

    // 4) Meal detail (the AI-analysis hero) — tap the first history row.
    await screen('04_meal', () async {
      final rows = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(InkWell),
      );
      if (!await waitFor(rows)) {
        throw StateError('no meal rows');
      }
      await tester.tap(rows.first);
      await tester.pumpAndSettle(const Duration(milliseconds: 900));
    });

    // 5) History → Body Intelligence (scroll the list down).
    await gotoTab(l.tab_history);
    try {
      await waitFor(find.byType(ListView));
      await tester.drag(find.byType(ListView).first, const Offset(0, -1300));
      await tester.pumpAndSettle();
      await shot('05_intelligence');
    } catch (e) {
      debugPrint('SHOT 05_intelligence failed: $e');
    }

    // 6) Food bank — the v1.3 headline: log without a photo.
    await gotoTab(l.tab_today);
    await screen('06_food_bank', () => openByText(l.today_logFromBank));
  });
}
