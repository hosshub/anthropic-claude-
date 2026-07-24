import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../services/profile_service.dart';
import '../../theme/theme.dart';
import '../../widgets/primary_button.dart';

/// جولة ترحيب قصيرة بعد قبول التنبيه الطبي: قيمة التطبيق → عنّي (اسم/عمر
/// اختياريان) → جاهز. قابلة للتخطي في أي لحظة ولا تحجب الاستخدام أبداً.
class WelcomeFlow extends StatefulWidget {
  const WelcomeFlow({super.key});

  @override
  State<WelcomeFlow> createState() => _WelcomeFlowState();
}

class _WelcomeFlowState extends State<WelcomeFlow> {
  final PageController _pages = PageController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _age = TextEditingController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    _name.dispose();
    _age.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final profile = context.read<ProfileService>();
    final name = _name.text.trim();
    final age = int.tryParse(_age.text.trim());
    if (name.isNotEmpty) await profile.setDisplayName(name);
    if (age != null) await profile.setAge(age);
    await profile.completeOnboarding();
  }

  void _next() {
    if (_index >= 2) {
      _finish();
      return;
    }
    _pages.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: TColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _index < 2
                    ? TextButton(
                        onPressed: _finish,
                        child: Text(
                          l.common_skip,
                          style: const TextStyle(
                            color: TColors.textSecondary,
                          ),
                        ),
                      )
                    : const SizedBox(height: 48),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _WelcomePage(l: l),
                  _AboutYouPage(l: l, name: _name, age: _age),
                  _DonePage(l: l),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < 3; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _index ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _index
                                ? TColors.primary
                                : TColors.primary.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: _index >= 2 ? l.onboarding_start : l.common_next,
                    icon: _index >= 2 ? Icons.check_circle : null,
                    onPressed: _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final AppLocalizations l;
  const _WelcomePage({required this.l});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: TColors.primary,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: TColors.primary.withOpacity(0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 42),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l.onboarding_welcome_title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l.onboarding_welcome_body,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: TColors.textSecondary,
            fontSize: 15,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 26),
        _FeatureCard(
          icon: Icons.camera_alt,
          color: TColors.primary,
          title: l.onboarding_feature_capture_title,
          body: l.onboarding_feature_capture_body,
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.traffic,
          color: TColors.gold,
          title: l.onboarding_feature_zones_title,
          body: l.onboarding_feature_zones_body,
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.favorite,
          color: TColors.zoneGreen,
          title: l.onboarding_feature_listen_title,
          body: l.onboarding_feature_listen_body,
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    color: TColors.textSecondary,
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutYouPage extends StatelessWidget {
  final AppLocalizations l;
  final TextEditingController name;
  final TextEditingController age;
  const _AboutYouPage({
    required this.l,
    required this.name,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        const SizedBox(height: 20),
        const Center(
          child: Icon(Icons.person_outline, size: 64, color: TColors.primary),
        ),
        const SizedBox(height: 16),
        Text(
          l.onboarding_about_title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l.onboarding_about_body,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: TColors.textSecondary,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: name,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l.onboarding_name_hint,
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: age,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l.onboarding_age_hint,
            prefixIcon: const Icon(Icons.cake_outlined),
          ),
        ),
      ],
    );
  }
}

class _DonePage extends StatelessWidget {
  final AppLocalizations l;
  const _DonePage({required this.l});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: TColors.zoneGreen.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: TColors.zoneGreen,
                size: 54,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.onboarding_done_title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l.onboarding_done_body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: TColors.textSecondary,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
