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
import 'services/account_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/onboarding_service.dart';
import 'theme/theme.dart';

Future<void> main() async {
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

  // يلتقط روابط OAuth العائدة (tayyibat://login-callback?code=…) ويسلّمها لـ Supabase.
  _wireOAuthDeepLinks();

  runApp(const TayyibatApp());
}

void _wireOAuthDeepLinks() {
  final appLinks = AppLinks();

  Future<void> handle(Uri uri) async {
    if (uri.scheme != 'tayyibat') return;
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
    } catch (_) {
      // تجاهل: إن لم يكن للرابط علاقة بـ OAuth أو فشل التبادل، يبقى المستخدم على الشاشة الحالية.
    }
  }

  // إقلاع بارد — لو فُتح التطبيق بسبب رابط.
  appLinks.getInitialLink().then((uri) {
    if (uri != null) handle(uri);
  });

  // إقلاع دافئ — لو وصل الرابط والتطبيق يعمل.
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
        ChangeNotifierProvider(create: (_) => MealRepository()),
        ChangeNotifierProvider(
          create: (_) => NotificationService()..initialize(),
        ),
        ProxyProvider<MealRepository, AccountService>(
          update: (_, repo, __) => AccountService(repo),
        ),
      ],
      child: MaterialApp(
        title: 'الطيبات',
        debugShowCheckedModeBanner: false,
        theme: tayyibatTheme,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const AppRoot(),
      ),
    );
  }
}
