import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';
import '../../widgets/primary_button.dart';
import '../capture/capture_screen.dart';

/// شاشة اليوم (F1: مبسّطة — تكتمل في مرحلة F2 مع السجل ومتابعة الجسم).
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  String _greetingFor(AuthService auth) {
    final hour = DateTime.now().hour;
    final period = hour < 12 ? 'صباح الخير' : 'مساء الخير';
    final email = auth.email;
    if (email == null || email.isEmpty) return period;
    final name = email.split('@').first;
    return '$period، $name';
  }

  Future<void> _signOut(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await context.read<AuthService>().signOut();
    messenger.showSnackBar(
      const SnackBar(content: Text('تم تسجيل الخروج.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('اليوم'),
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _greetingFor(auth),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              CardContainer(
                child: Column(
                  children: [
                    Container(
                      width: 168,
                      height: 168,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: TColors.khabith.withOpacity(0.28),
                          width: 11,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '0%',
                            style: TextStyle(
                              fontSize: 46,
                              fontWeight: FontWeight.w800,
                              color: TColors.khabith,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'طيب اليوم',
                            style: TextStyle(
                              color: TColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'لم تسجّل وجبات اليوم بعد',
                      style: TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'صوّر وجبتك',
                icon: Icons.camera_alt,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CaptureScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              const CardContainer(
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: TColors.gold),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'نسخة Flutter — Phase F1 (شريحة عمودية). '
                        'السجل والملاحظات والدليل والبرنامج تأتي في المراحل التالية.',
                        style: TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
