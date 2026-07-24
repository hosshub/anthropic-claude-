import 'package:flutter/material.dart';

import '../../l10n/enum_labels.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/body_response.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';

class BodyResponseCard extends StatelessWidget {
  final BodyResponse response;
  final VoidCallback onEdit;
  const BodyResponseCard({
    super.key,
    required this.response,
    required this.onEdit,
  });

  String _satisfactionText(AppLocalizations l) {
    switch (response.satisfyingFullness) {
      case 1:
        return l.bodyResponseCard_satietyNone;
      case 2:
        return l.bodyResponseCard_satietyLight;
      case 3:
        return l.bodyResponseCard_satietyComfortable;
      case 4:
        return l.bodyResponseCard_satietyFull;
      default:
        return l.bodyResponseCard_satietyOverfull;
    }
  }

  String _bloatingText(AppLocalizations l) {
    switch (response.bloating) {
      case 0:
        return l.bodyResponseCard_bloatingComfortable;
      case 1:
      case 2:
        return l.bodyResponseCard_bloatingLight;
      case 3:
        return l.bodyResponseCard_bloatingNoticeable;
      case 4:
        return l.bodyResponseCard_bloatingClear;
      default:
        return l.bodyResponseCard_bloatingSevere;
    }
  }

  Color get _bloatingColor {
    if (response.bloating == 0) return TColors.primary;
    if (response.bloating <= 2) return TColors.gold;
    return TColors.khabith;
  }

  String _energyText(AppLocalizations l) {
    switch (response.energyLevel) {
      case 1:
        return l.bodyResponseCard_energySleepy;
      case 2:
        return l.bodyResponseCard_energySluggish;
      case 3:
        return l.bodyResponseCard_energyNormal;
      case 4:
        return l.bodyResponseCard_energyEnergetic;
      default:
        return l.bodyResponseCard_energyVeryEnergetic;
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
    final l = AppLocalizations.of(context)!;
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: TColors.primary),
              const SizedBox(width: 6),
              Text(
                l.bodyResponseCard_title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: TColors.primary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(foregroundColor: TColors.primary),
                child: Text(l.bodyResponseCard_edit),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _metric(
                icon: Icons.restaurant,
                label: l.bodyResponseCard_satietyLabel,
                value: _satisfactionText(l),
                color: TColors.primary,
              ),
              _metric(
                icon: Icons.air,
                label: l.bodyResponseCard_bloatingLabel,
                value: _bloatingText(l),
                color: _bloatingColor,
              ),
              _metric(
                icon: Icons.bolt,
                label: l.bodyResponseCard_energyLabel,
                value: _energyText(l),
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
                label: sleepImpactLabel(l, response.sleepImpact),
                color: TColors.primary,
              ),
              _pill(
                icon: _worthIcon,
                label: worthRepeatingLabel(l, response.worthRepeating),
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
            l.bodyResponseCard_loggedAfter(response.hoursAfterMeal),
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
        color: color.withValues(alpha: 0.10),
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
