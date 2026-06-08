import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config.dart';
import 'services/auth_service.dart';
import 'services/onboarding_service.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  _wireOAuthDeepLinks();

  runApp(const WellnessApp());
}

/// Captures returning OAuth links (wellnessai://login-callback?code=…).
void _wireOAuthDeepLinks() {
  final appLinks = AppLinks();
  Future<void> handle(Uri uri) async {
    if (uri.scheme != 'wellnessai') return;
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
    } catch (_) {/* ignore non-OAuth links */}
  }

  appLinks.getInitialLink().then((uri) {
    if (uri != null) handle(uri);
  });
  appLinks.uriLinkStream.listen(handle);
}

class WellnessApp extends StatelessWidget {
  const WellnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => OnboardingService()),
        // TODO: register MealRepository, PlanService, LinkService,
        //       NotificationService, WearableService (see docs/PRD.md §6–§9).
      ],
      child: MaterialApp(
        title: 'Wellness AI',
        debugShowCheckedModeBanner: false,
        theme: wellnessTheme,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const AppRoot(),
      ),
    );
  }
}
