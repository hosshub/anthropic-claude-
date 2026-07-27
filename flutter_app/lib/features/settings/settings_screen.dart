import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/meal_repository.dart';
import '../../data/plan_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/account_service.dart';
import '../../services/app_messages.dart';
import '../../services/auth_service.dart';
import '../../services/entitlement.dart';
import '../../services/locale_service.dart';
import '../../services/health_service.dart';
import '../../services/notification_service.dart';
import '../../services/nutrition_goal_service.dart';
import '../../services/profile_service.dart';
import '../../services/subscription_service.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';
import '../onboarding/disclaimer_screen.dart';
import '../paywall/paywall_screen.dart';
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
    // Capture providers before the first await so we don't reach for
    // BuildContext across an async gap.
    final notifications = context.read<NotificationService>();
    final account = context.read<AccountService>();
    final profile = context.read<ProfileService>();
    final plans = context.read<PlanRepository>();
    final messenger = ScaffoldMessenger.of(context);
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
    try {
      // Tear down any pending body-followup notifications before the
      // server-side delete; we won't have meal IDs after deleteAll().
      await notifications.cancelAllBodyFollowups();
      if (!mounted) return;
      await account.deleteAccount();
      // الخطة الأسبوعية والملف الشخصي محليان — يُمسحان مع الحساب حتى لا
      // تظهر بيانات المستخدم السابق لمن يسجّل بعده على نفس الجهاز.
      await plans.deleteAll();
      await profile.reset();
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
      final detail = e is AccountException && e.serverMessage != null
          ? '${e.serverMessage} (${e.statusCode ?? ''})'
          : describeError(l, e);
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: Text(
            l.settings_deleteAccount_failed(detail),
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
                    const SizedBox(height: 10),
                    const _DisplayNameRow(),
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

              // -- Subscription ----------------------------------------------
              const SizedBox(height: 18),
              const _SubscriptionCard(),

              // -- Nutrition -------------------------------------------------
              const SizedBox(height: 18),
              const _CalorieGoalCard(),

              // -- Apple Health ----------------------------------------------
              const SizedBox(height: 18),
              const _HealthCard(),

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
                          side:
                              const BorderSide(color: TColors.gold, width: 1.2),
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

/// صف الاسم داخل بطاقة الحساب — يفتح حوار تعديل الاسم الأول والأخير واللقب.
/// الاسم يغذّي تحية شاشة اليوم ويبقى على الجهاز.
class _DisplayNameRow extends StatelessWidget {
  const _DisplayNameRow();

  Future<void> _edit(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final profile = context.read<ProfileService>();
    final first = TextEditingController(text: profile.firstName ?? '');
    final last = TextEditingController(text: profile.lastName ?? '');
    final nickname = TextEditingController(text: profile.nickname ?? '');
    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.settings_name_dialogTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: first,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: l.settings_firstName),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: last,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: l.settings_lastName),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nickname,
                  decoration: InputDecoration(labelText: l.settings_nickname),
                ),
                const SizedBox(height: 8),
                Text(
                  l.settings_displayName_note,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: TColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l.common_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l.common_save),
            ),
          ],
        ),
      );
      if (saved == true) {
        await profile.setFirstName(first.text);
        await profile.setLastName(last.text);
        await profile.setNickname(nickname.text);
      }
    } finally {
      first.dispose();
      last.dispose();
      nickname.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final name = context.watch<ProfileService>().displayName;
    return OutlinedButton.icon(
      onPressed: () => _edit(context),
      icon: const Icon(Icons.badge_outlined),
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l.settings_name),
          Flexible(
            child: Text(
              name ?? l.settings_displayName_empty,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: name == null ? TColors.textSecondary : null,
              ),
            ),
          ),
        ],
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: TColors.primary,
        alignment: AlignmentDirectional.centerStart,
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: TColors.primary, width: 1.2),
      ),
    );
  }
}

/// بطاقة الاشتراك: حالة المستخدم، وشكر خاص للمشترين الأوائل، وزر الترقية
/// أو إدارة الاشتراك من إعدادات Apple.
class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final subs = context.watch<SubscriptionService>();
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l.settings_subscription,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: TColors.primary,
                ),
              ),
              const Spacer(),
              if (subs.isPremium)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: TColors.gold.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Text(
                    l.premium_badge,
                    style: const TextStyle(
                      color: TColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (subs.isGrandfatheredUser)
            Text(
              l.settings_grandfathered,
              style: const TextStyle(
                color: TColors.textSecondary,
                fontSize: 12,
                height: 1.6,
              ),
            )
          else if (subs.isPremium)
            OutlinedButton.icon(
              onPressed: () => launchUrl(
                Uri.parse('https://apps.apple.com/account/subscriptions'),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.manage_accounts_outlined),
              label: Text(l.settings_manageSubscription),
              style: OutlinedButton.styleFrom(
                foregroundColor: TColors.primary,
                alignment: AlignmentDirectional.centerStart,
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: TColors.primary, width: 1.2),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: () => showPaywall(context),
              icon: const Icon(Icons.workspace_premium_outlined),
              label: Text(l.gate_upgrade),
              style: OutlinedButton.styleFrom(
                foregroundColor: TColors.primary,
                alignment: AlignmentDirectional.centerStart,
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: TColors.primary, width: 1.2),
              ),
            ),

          // Gated on a --dart-define rather than kDebugMode: the free tier has
          // to be walked on a real device, and device testing runs a release
          // build where kDebugMode is false. Without the flag this whole
          // branch — and the override itself — is compiled out.
          if (subs.canOverrideTier) ...[
            const Divider(height: 28),
            const Text(
              'Dev — force tier',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: TColors.gold,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Every account is grandfathered until the cutoff passes, so the '
              'free gates are otherwise unreachable. Masks the real '
              'entitlement; never present in a production build.',
              style: TextStyle(
                color: TColors.textSecondary,
                fontSize: 11,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'auto', label: Text('Real')),
                ButtonSegment(value: 'free', label: Text('Free')),
                ButtonSegment(value: 'premium', label: Text('Premium')),
              ],
              selected: {subs.tierOverride?.name ?? 'auto'},
              onSelectionChanged: (sel) => subs.setTierOverride(
                switch (sel.first) {
                  'free' => Tier.free,
                  'premium' => Tier.premium,
                  _ => null,
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subs.tierOverride == null
                  ? 'Following the real entitlement: '
                      '${subs.isPremium ? 'premium' : 'free'}'
                      '${subs.isGrandfatheredUser ? ' (grandfathered)' : ''}'
                  : 'Forced to ${subs.tierOverride!.name}. The server still '
                      'enforces the real tier, so an AI scan can succeed even '
                      'when the UI says the quota is spent.',
              style: const TextStyle(
                color: TColors.textSecondary,
                fontSize: 10.5,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// بطاقة ربط Apple Health — قراءة الخطوات والسعرات المحروقة (اختياري).
class _HealthCard extends StatefulWidget {
  const _HealthCard();

  @override
  State<_HealthCard> createState() => _HealthCardState();
}

class _HealthCardState extends State<_HealthCard> {
  bool _busy = false;

  Future<void> _connect() async {
    final l = AppLocalizations.of(context)!;
    final health = context.read<HealthService>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    final ok = await health.connect();
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.settings_health_denied)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final health = context.watch<HealthService>();
    final connected = health.authorized;
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l.settings_health,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: TColors.primary,
                ),
              ),
              const Spacer(),
              if (connected)
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: TColors.zoneGreen, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      l.settings_health_connected,
                      style: const TextStyle(
                        color: TColors.zoneGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.settings_health_note,
            style: const TextStyle(
              color: TColors.textSecondary,
              fontSize: 11.5,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          if (connected) ...[
            SwitchListTile.adaptive(
              value: health.writeMealsEnabled,
              onChanged: (v) async {
                final messenger = ScaffoldMessenger.of(context);
                final ok =
                    await context.read<HealthService>().setWriteMeals(v);
                if (!context.mounted) return;
                if (v && !ok) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(l.settings_health_denied)),
                  );
                }
              },
              contentPadding: EdgeInsets.zero,
              activeThumbColor: TColors.primary,
              title: Text(
                l.settings_health_writeMeals,
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                l.settings_health_writeMeals_note,
                style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            OutlinedButton.icon(
              onPressed: () => context.read<HealthService>().disconnect(),
              icon: const Icon(Icons.link_off),
              label: Text(l.settings_health_disconnect),
              style: OutlinedButton.styleFrom(
                foregroundColor: TColors.textSecondary,
                minimumSize: const Size.fromHeight(46),
                side: BorderSide(
                    color: TColors.textSecondary.withValues(alpha: 0.4)),
              ),
            ),
          ] else
            OutlinedButton.icon(
              onPressed: _busy ? null : _connect,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: TColors.primary),
                    )
                  : const Icon(Icons.favorite_border),
              label: Text(l.settings_health_connect),
              style: OutlinedButton.styleFrom(
                foregroundColor: TColors.primary,
                minimumSize: const Size.fromHeight(46),
                side: const BorderSide(color: TColors.primary, width: 1.2),
              ),
            ),
        ],
      ),
    );
  }
}

/// بطاقة هدف السعرات اليومي: تعرض القيمة الحالية وتفتح حوار تعديل بحقل
/// رقمي. القيمة إرشادية يضبطها المستخدم بنفسه — لا حساب تلقائي ولا توصية.
class _CalorieGoalCard extends StatelessWidget {
  const _CalorieGoalCard();

  Future<void> _edit(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final service = context.read<NutritionGoalService>();
    final controller = TextEditingController(text: service.goal.toString());
    try {
      final result = await showDialog<int>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.settings_calorieGoal_dialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixText: l.nutrition_kcalUnit,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.settings_calorieGoal_note,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: TColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.common_cancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(int.tryParse(controller.text.trim())),
              child: Text(l.common_save),
            ),
          ],
        ),
      );
      if (result != null) await service.setGoal(result);
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final goal = context.watch<NutritionGoalService>().goal;
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.settings_nutrition,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: TColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _edit(context),
            icon: const Icon(Icons.local_fire_department_outlined),
            label: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.settings_calorieGoal),
                Text(
                  l.nutrition_kcalValue(goal),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: TColors.primary,
              alignment: AlignmentDirectional.centerStart,
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: TColors.primary, width: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}
