import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../theme/theme.dart';
import '../onboarding/disclaimer_screen.dart';

/// Settings — account, provider link, notifications, privacy, disclaimer,
/// subscription, delete account. EPIC C7/C8 (docs/PRD.md §6).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text(auth.email ?? 'غير مسجّل'),
            ),
            const Divider(),
            // TODO: "ربط مقدّم رعاية" — enter invite code/QR + consent (EPIC C7).
            ListTile(
              leading: const Icon(Icons.qr_code_2, color: WColors.primary),
              title: const Text('ربط طبيب / أخصائي / مدرّب'),
              subtitle: const Text('أدخل رمز الدعوة (قريباً)'),
              onTap: null,
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined,
                  color: WColors.primary),
              title: const Text('الإشعارات'),
              onTap: null,
            ),
            ListTile(
              leading: const Icon(Icons.medical_information_outlined,
                  color: WColors.primary),
              title: const Text('إعادة قراءة التنبيه'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const DisclaimerScreen(readOnly: true)),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: WColors.primary),
              title: const Text('تسجيل الخروج'),
              onTap: () => context.read<AuthService>().signOut(),
            ),
            // TODO: in-app account + data deletion (EPIC C8 / FR-C8.1).
          ],
        ),
      ),
    );
  }
}
