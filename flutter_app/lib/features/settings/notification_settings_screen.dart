import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/enum_labels.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/notification_service.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final svc = context.watch<NotificationService>();
    return Scaffold(
      appBar: AppBar(title: Text(l.notif_title)),
      body: !svc.isReady
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _PermissionBanner(svc: svc),
                const SizedBox(height: 14),
                CardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          l.notif_kinds_title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: TColors.primary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      for (final kind in NotifKind.values)
                        _ToggleRow(
                          kind: kind,
                          enabled: svc.enabled(kind),
                          onToggle: (v) async {
                            await context
                                .read<NotificationService>()
                                .setEnabled(kind, v);
                          },
                        ),
                      _BodyFollowupRow(
                        enabled: svc.bodyFollowupEnabled,
                        onToggle: (v) => context
                            .read<NotificationService>()
                            .setBodyFollowupEnabled(v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (svc.permissionGranted)
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.read<NotificationService>().showTest(
                              l.appTitle,
                              l.notif_testBody,
                            ),
                    icon: const Icon(Icons.notifications_active),
                    label: Text(l.notif_testButton),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    l.notif_antiRepeatNote,
                    style: const TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  final NotificationService svc;
  const _PermissionBanner({required this.svc});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (svc.permissionGranted) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: TColors.zoneGreen.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified, color: TColors.zoneGreen),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l.notif_grantedBanner,
                style: const TextStyle(
                  color: TColors.zoneGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_off, color: TColors.gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.notif_notGrantedTitle,
                  style: const TextStyle(
                    color: TColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.notif_notGrantedBody,
            style: const TextStyle(
              color: TColors.textSecondary,
              fontSize: 13,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () async {
              await context.read<NotificationService>().requestPermission();
            },
            style: FilledButton.styleFrom(
              backgroundColor: TColors.gold,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(44),
            ),
            child: Text(l.notif_allowButton),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final NotifKind kind;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  const _ToggleRow({
    required this.kind,
    required this.enabled,
    required this.onToggle,
  });

  IconData get _icon {
    switch (kind) {
      case NotifKind.morningTip:
        return Icons.wb_sunny;
      case NotifKind.lunchReminder:
        return Icons.restaurant;
      case NotifKind.eveningTip:
        return Icons.nightlight_round;
      case NotifKind.endOfDayLog:
        return Icons.edit_note;
      case NotifKind.weeklyPrep:
        return Icons.event_available;
    }
  }

  String _time(AppLocalizations l) {
    final (h, m) = kind.defaultTime;
    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    final formatted = '$hh:$mm';
    if (kind == NotifKind.weeklyPrep) {
      return l.notif_everySaturdayAt(formatted);
    }
    return l.notif_dailyAt(formatted);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(_icon, color: TColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notifKindLabel(l, kind),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _time(l),
                  style: const TextStyle(
                    color: TColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: enabled,
            activeThumbColor: TColors.primary,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}

class _BodyFollowupRow extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onToggle;
  const _BodyFollowupRow({required this.enabled, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.favorite, color: TColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.notif_bodyFollowup_title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l.notif_bodyFollowup_subtitle,
                  style: const TextStyle(
                    color: TColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: enabled,
            activeThumbColor: TColors.primary,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}
