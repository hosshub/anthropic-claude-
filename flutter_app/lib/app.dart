import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/auth_screen.dart';
import 'features/onboarding/disclaimer_screen.dart';
import 'services/auth_service.dart';
import 'services/onboarding_service.dart';
import 'shell/main_shell.dart';

/// نقطة التفرّع: دخول → تنبيه طبي (إن لم يُقبل بعد) → الإطار الرئيسي.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final onboarding = context.watch<OnboardingService>();

    if (auth.isRestoring || !onboarding.isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.isAuthenticated) return const AuthScreen();
    if (!onboarding.hasAcceptedDisclaimer) return const DisclaimerScreen();
    return const MainShell();
  }
}
