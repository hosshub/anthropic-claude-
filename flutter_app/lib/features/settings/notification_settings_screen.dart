import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/notification_service.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<NotificationService>();
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
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
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          'أنواع التذكيرات',
                          style: TextStyle(
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
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (svc.permissionGranted)
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.read<NotificationService>().showTest(),
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('أرسل إشعار اختباري'),
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'النصائح تختلف يومياً — التطبيق يتجنّب إعادة آخر ١٠ نصائح '
                    'لكل وقت حتى لا تشعر بالتكرار.',
                    style: TextStyle(
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
    if (svc.permissionGranted) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: TColors.zoneGreen.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified, color: TColors.zoneGreen),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'الإشعارات مفعّلة من النظام.',
                style: TextStyle(
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
        color: TColors.gold.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.gold.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications_off, color: TColors.gold),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'الإشعارات لم تُفعّل بعد من النظام.',
                  style: TextStyle(
                    color: TColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'لتصلك التذكيرات، نحتاج إذن النظام مرة واحدة.',
            style: TextStyle(
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
            child: const Text('السماح بالإشعارات'),
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

  String get _timeAr {
    final (h, m) = kind.defaultTime;
    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    if (kind == NotifKind.weeklyPrep) {
      return 'كل سبت $hh:$mm';
    }
    return 'يومياً $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.12),
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
                  kind.labelAr,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _timeAr,
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
            activeColor: TColors.primary,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}
