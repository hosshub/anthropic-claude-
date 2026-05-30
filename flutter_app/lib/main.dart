import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'data/meal_repository.dart';
import 'services/account_service.dart';
import 'services/auth_service.dart';
import 'theme/theme.dart';

// نفس قيم AppConfig.swift في نسخة SwiftUI.
const String _supabaseUrl = 'https://cvznuwvwhnujdgfojmsb.supabase.co';
const String _supabaseAnonKey =
    'sb_publishable_LecfzCczF2tn3w_x7mtbyQ_Ug-Dee-X';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  runApp(const TayyibatApp());
}

class TayyibatApp extends StatelessWidget {
  const TayyibatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => MealRepository()),
        // AccountService يعتمد على MealRepository (لمسح البيانات المحلية بعد الحذف).
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
