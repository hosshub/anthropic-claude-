import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config.dart';
import 'data/meal_repository.dart';
import 'l10n/generated/app_localizations.dart';
import 'services/account_service.dart';
import 'services/auth_service.dart';
import 'services/fasting_repository.dart';
import 'services/locale_service.dart';
import 'services/notification_service.dart';
import 'services/nutrition_goal_service.dart';
import 'services/onboarding_service.dart';
import 'theme/theme.dart';

// Sentry was removed from v1.0.2's dependency tree because sentry_flutter
// 8.14.2's iOS Swift bridge no longer compiles against the current
// Sentry-Cocoa pod. Will be re-added in v1.0.3 with sentry_flutter 9.x.
// See pubspec.yaml for the commented-out dep line.

Future<void> main() async {
  await _bootstrap();
  runApp(const TayyibatApp());
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  // Edge-to-edge layout: required on Android 15+ (Play Store deprecation
  // warning otherwise) and lets the ivory background flow under the
  // translucent status / nav bars on both platforms.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // dark icons on ivory bg
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    // anonKey is the publishable key; newer supabase_flutter renames the
    // parameter to publishableKey, but anonKey still works across the
    // versions our floor (^2.5.6) resolves to. Keep it for compatibility.
    // ignore: deprecated_member_use
    anonKey: AppConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  _wireOAuthDeepLinks();
}

void _wireOAuthDeepLinks() {
  final appLinks = AppLinks();
  Future<void> handle(Uri uri) async {
    if (uri.scheme != 'tayyibat') return;
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
    } catch (_) {/* تجاهل: روابط ليست OAuth أو تبادل فاشل */}
  }

  appLinks.getInitialLink().then((uri) {
    if (uri != null) handle(uri);
  });
  appLinks.uriLinkStream.listen((uri) => handle(uri));
}

class TayyibatApp extends StatelessWidget {
  const TayyibatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => OnboardingService()),
        ChangeNotifierProvider(create: (_) => LocaleService()),
        ChangeNotifierProvider(create: (_) => NutritionGoalService()),
        ChangeNotifierProvider(create: (_) => MealRepository()),
        ChangeNotifierProvider(create: (_) => FastingRepository()),
        ChangeNotifierProvider(
          create: (_) => NotificationService()..initialize(),
        ),
        ProxyProvider<MealRepository, AccountService>(
          update: (_, repo, __) => AccountService(repo),
        ),
      ],
      child: Consumer<LocaleService>(
        builder: (context, locale, _) => MaterialApp(
          onGenerateTitle: (ctx) =>
              AppLocalizations.of(ctx)?.appTitle ?? 'الطيبات',
          debugShowCheckedModeBanner: false,
          theme: tayyibatTheme,
          locale: locale.locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // الاتجاه يتبع اللغة المختارة — RTL للعربية، LTR للإنجليزية.
          builder: (context, child) => Directionality(
            textDirection: locale.textDirection,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const AppRoot(),
        ),
      ),
    );
  }
}
