import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
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
import 'services/onboarding_service.dart';
import 'theme/theme.dart';

Future<void> main() async {
  if (!AppConfig.crashReportingEnabled) {
    await _bootstrap();
    runApp(const TayyibatApp());
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfig.sentryDsn;
      // Privacy-first defaults: ship crashes + Dart errors, nothing else.
      // We never attach a user manually, so sendDefaultPii=false is enough
      // — no need for a beforeSend scrubber.
      options.sendDefaultPii = false;
      options.attachScreenshot = false;
      options.attachViewHierarchy = false;
      options.tracesSampleRate = 0.0;
      options.profilesSampleRate = 0.0;
      options.enableUserInteractionTracing = false;
      options.enableUserInteractionBreadcrumbs = false;
      options.enableAutoSessionTracking = true;
      options.environment = kReleaseMode ? 'production' : 'debug';
    },
    appRunner: () async {
      await _bootstrap();
      runApp(const TayyibatApp());
    },
  );
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
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
