import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/account_service.dart';
import '../../services/auth_service.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';
import '../onboarding/disclaimer_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _deleting = false;

  Future<void> _signOut() async {
    final messenger = ScaffoldMessenger.of(context);
    await context.read<AuthService>().signOut();
    messenger.showSnackBar(const SnackBar(content: Text('تم تسجيل الخروج.')));
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحساب نهائياً؟'),
        content: const Text(
          'سيُحذف حسابك وبياناته من الخادم، وكذلك كل بيانات المتابعة على هذا الجهاز. لا يمكن التراجع.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(foregroundColor: TColors.khabith),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('حذف الحساب'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _deleting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<AccountService>().deleteAccount();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('تعذّر حذف الحساب: ${e is AccountException ? e.message : e}'),
        ),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الحساب',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: TColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (auth.email != null)
                      Row(
                        children: [
                          const Icon(Icons.email,
                              color: TColors.textSecondary, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              auth.email!,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _deleting ? null : _signOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('تسجيل الخروج'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TColors.primary,
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(
                          color: TColors.primary,
                          width: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _deleting ? null : _deleteAccount,
                      icon: _deleting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: TColors.khabith,
                              ),
                            )
                          : const Icon(Icons.delete_forever),
                      label: const Text('حذف الحساب'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TColors.khabith,
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(
                          color: TColors.khabith,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الأمان والقانون',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: TColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const DisclaimerScreen(readOnly: true),
                          ),
                        );
                      },
                      icon: const Icon(Icons.medical_information_outlined),
                      label: const Text('إعادة قراءة التنبيه الطبي'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TColors.primary,
                        alignment: AlignmentDirectional.centerStart,
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(
                          color: TColors.primary,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حول',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: TColors.primary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'الطيبات — تطبيق وعي غذائي. يستخدم نموذج Gemini للتحليل عبر '
                      'خادم آمن. لا يقدّم استشارة طبية ولا يحلّ محل الطبيب أو '
                      'أخصائي التغذية.',
                      style: TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 12,
                        height: 1.6,
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
