import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/auth_screen.dart';
import 'features/onboarding/disclaimer_screen.dart';
import 'services/auth_service.dart';
import 'services/onboarding_service.dart';
import 'shell/main_shell.dart';

/// Routing: auth → scroll-gated medical disclaimer → main shell.
///
/// NOTE: provider vs consumer role routing (PRD §3) is decided after auth.
/// v0 routes everyone to the consumer shell; add a RoleGate when the provider
/// surface lands (docs/PRD.md §7).
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final onboarding = context.watch<OnboardingService>();

    if (auth.isRestoring || !onboarding.isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!auth.isAuthenticated) return const AuthScreen();
    if (!onboarding.hasAcceptedDisclaimer) return const DisclaimerScreen();
    return const MainShell();
  }
}
