import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/auth_screen.dart';
import 'features/onboarding/disclaimer_screen.dart';
import 'features/onboarding/welcome_flow.dart';
import 'services/auth_service.dart';
import 'services/onboarding_service.dart';
import 'services/profile_service.dart';
import 'shell/main_shell.dart';

/// وضع لقطات المتجر (تطوير فقط): يتخطى الدخول والتنبيه والترحيب مباشرةً إلى
/// الإطار الرئيسي لالتقاط الصور ببيانات تجريبية. مُقيَّد بـ kDebugMode
/// و‑dart-define معاً، فلا يمكن أن يمسّ إصدار الإنتاج (release) إطلاقاً.
const bool kScreenshotMode =
    kDebugMode && bool.fromEnvironment('SCREENSHOT');

/// نقطة التفرّع: دخول → تنبيه طبي (إن لم يُقبل) → جولة الترحيب (مرة واحدة،
/// قابلة للتخطي) → الإطار الرئيسي.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: dead_code
    if (kScreenshotMode) return const MainShell();

    final auth = context.watch<AuthService>();
    final onboarding = context.watch<OnboardingService>();
    final profile = context.watch<ProfileService>();

    if (auth.isRestoring || !onboarding.isReady || !profile.isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.isAuthenticated) return const AuthScreen();
    if (!onboarding.hasAcceptedDisclaimer) return const DisclaimerScreen();
    if (!profile.hasCompletedOnboarding) return const WelcomeFlow();
    return const MainShell();
  }
}
