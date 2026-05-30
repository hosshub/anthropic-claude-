import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/auth_screen.dart';
import 'services/auth_service.dart';
import 'shell/main_shell.dart';

/// نقطة التفرّع: شاشة الدخول أو الإطار الرئيسي حسب حالة المصادقة.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (auth.isRestoring) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.isAuthenticated) return const AuthScreen();
    return const MainShell();
  }
}
