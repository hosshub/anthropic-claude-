import 'package:flutter/material.dart';

import '../l10n/enum_labels.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/analysis_result.dart';
import '../theme/theme.dart';

/// نقطة ملوّنة + اسم المنطقة (تطابق VerdictBadge في SwiftUI v2).
class ZoneBadge extends StatelessWidget {
  final FoodZone zone;

  const ZoneBadge({super.key, required this.zone});

  Color _color() {
    switch (zone) {
      case FoodZone.green:
        return TColors.zoneGreen;
      case FoodZone.yellow:
        return TColors.zoneYellow;
      case FoodZone.red:
        return TColors.zoneRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color();
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            foodZoneLabel(l, zone),
            style: TextStyle(
              color: c,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
