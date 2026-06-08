import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/meal_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/account_service.dart';
import '../../services/auth_service.dart';
import '../../services/locale_service.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';
import '../onboarding/disclaimer_screen.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _deleting = false;

  Future<void> _signOut() async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    await context.read<AuthService>().signOut();
    messenger.showSnackBar(SnackBar(content: Text(l.settings_signedOut)));
  }

  Future<void> _deleteAccount() async {
    final l = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settings_deleteAccount_confirmTitle),
        content: Text(l.settings_deleteAccount_confirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.common_cancel),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(foregroundColor: TColors.khabith),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.settings_deleteAccount),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _deleting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<AccountService>().deleteAccount();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(l.settings_deleteAccount_successTitle),
          content: Text(
            l.settings_deleteAccount_successBody,
            style: const TextStyle(height: 1.7),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.common_ok),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: Text(
            l.settings_deleteAccount_failed(
              e is AccountException ? e.message : e.toString(),
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final locale = context.watch<LocaleService>();
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.settings_title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // -- Account ---------------------------------------------------
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.settings_account,
                      style: const TextStyle(
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
                      label: Text(l.settings_signOut),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TColors.primary,
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(
                            color: TColors.primary, width: 1.2),
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
                                strokeWidth: 2, color: TColors.khabith),
                            )
                          : const Icon(Icons.delete_forever),
                      label: Text(l.settings_deleteAccount),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TColors.khabith,
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(
                            color: TColors.khabith, width: 1.2),
                      ),
                    ),
                  ],
                ),
              ),

              // -- Language --------------------------------------------------
              const SizedBox(height: 18),
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.settings_language,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: TColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'ar',
                          label: Text(l.settings_language_arabic),
                        ),
                        ButtonSegment(
                          value: 'en',
                          label: Text(l.settings_language_english),
                        ),
                      ],
                      selected: {locale.locale.languageCode},
                      onSelectionChanged: (s) => locale.setLocale(
                        Locale(s.first),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.settings_partialEnglishNote,
                      style: const TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 11.5,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              // -- Reminders -------------------------------------------------
              const SizedBox(height: 18),
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.settings_reminders,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: TColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationSettingsScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.notifications_outlined),
                      label: Text(l.settings_notificationSettings),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TColors.primary,
                        alignment: AlignmentDirectional.centerStart,
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(
                            color: TColors.primary, width: 1.2),
                      ),
                    ),
                  ],
                ),
              ),

              // -- Safety & legal --------------------------------------------
              const SizedBox(height: 18),
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.settings_safetyLegal,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: TColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const DisclaimerScreen(readOnly: true),
                        ),
                      ),
                      icon: const Icon(Icons.medical_information_outlined),
                      label: Text(l.settings_reReadDisclaimer),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TColors.primary,
                        alignment: AlignmentDirectional.centerStart,
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(
                            color: TColors.primary, width: 1.2),
                      ),
                    ),
                  ],
                ),
              ),

              // -- About -----------------------------------------------------
              const SizedBox(height: 18),
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.settings_about,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: TColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.settings_about_body,
                      style: const TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              // -- Dev tools (debug only) ------------------------------------
              if (kDebugMode) ...[
                const SizedBox(height: 18),
                CardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dev — App Store screenshots',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: TColors.gold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Seeds 11 synthetic meals across the last 14 days '
                        'with varied body responses. Visible in debug builds '
                        'only.',
                        style: TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 11.5,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final repo = context.read<MealRepository>();
                          final messenger = ScaffoldMessenger.of(context);
                          final n = await repo.seedDemoData();
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Seeded $n demo meals.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.science_outlined),
                        label: const Text('Seed demo data'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: TColors.gold,
                          alignment: AlignmentDirectional.centerStart,
                          minimumSize: const Size.fromHeight(46),
                          side: const BorderSide(
                              color: TColors.gold, width: 1.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
