import 'package:flutter/material.dart';

import '../../models/body_response.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';

/// بطاقة موجزة لمتابعة الجسم — تُعرض داخل تفاصيل الوجبة.
class BodyResponseCard extends StatelessWidget {
  final BodyResponse response;
  final VoidCallback onEdit;
  const BodyResponseCard({
    super.key,
    required this.response,
    required this.onEdit,
  });

  String get _satisfactionText {
    switch (response.satisfyingFullness) {
      case 1:
        return 'لا شبع';
      case 2:
        return 'خفيف';
      case 3:
        return 'مريح';
      case 4:
        return 'كامل';
      default:
        return 'ممتلئ جداً';
    }
  }

  String get _bloatingText {
    switch (response.bloating) {
      case 0:
        return 'مرتاح';
      case 1:
      case 2:
        return 'خفيف';
      case 3:
        return 'ملحوظ';
      case 4:
        return 'واضح';
      default:
        return 'شديد';
    }
  }

  Color get _bloatingColor {
    if (response.bloating == 0) return TColors.primary;
    if (response.bloating <= 2) return TColors.gold;
    return TColors.khabith;
  }

  String get _energyText {
    switch (response.energyLevel) {
      case 1:
        return 'نعسان';
      case 2:
        return 'خامل';
      case 3:
        return 'عادي';
      case 4:
        return 'نشيط';
      default:
        return 'نشيط جداً';
    }
  }

  Color get _worthColor {
    switch (response.worthRepeating) {
      case WorthRepeating.yes:
        return TColors.primary;
      case WorthRepeating.maybe:
        return TColors.gold;
      case WorthRepeating.no:
        return TColors.khabith;
    }
  }

  IconData get _worthIcon {
    switch (response.worthRepeating) {
      case WorthRepeating.yes:
        return Icons.thumb_up;
      case WorthRepeating.maybe:
        return Icons.help_outline;
      case WorthRepeating.no:
        return Icons.thumb_down;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: TColors.primary),
              const SizedBox(width: 6),
              const Text(
                'متابعة الجسم',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: TColors.primary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(foregroundColor: TColors.primary),
                child: const Text('تعديل'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _metric(
                icon: Icons.restaurant,
                label: 'الشبع',
                value: _satisfactionText,
                color: TColors.primary,
              ),
              _metric(
                icon: Icons.air,
                label: 'الانتفاخ',
                value: _bloatingText,
                color: _bloatingColor,
              ),
              _metric(
                icon: Icons.bolt,
                label: 'الطاقة',
                value: _energyText,
                color: TColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              _pill(
                icon: Icons.nights_stay,
                label: response.sleepImpact.labelAr,
                color: TColors.primary,
              ),
              _pill(
                icon: _worthIcon,
                label: response.worthRepeating.labelAr,
                color: _worthColor,
              ),
            ],
          ),
          if (response.notes != null && response.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              response.notes!,
              style: const TextStyle(
                color: TColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            'سُجّلت بعد ${response.hoursAfterMeal} ساعة من الوجبة',
            style: const TextStyle(color: TColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _metric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                    color: TColors.textSecondary,
                    fontSize: 12,
                  )),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: TColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                fontSize: 12,
                color: TColors.textPrimary,
              )),
        ],
      ),
    );
  }
}
