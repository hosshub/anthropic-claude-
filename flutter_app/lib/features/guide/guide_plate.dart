import 'package:flutter/material.dart';

import '../../data/guide_data.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';

class GuidePlateScreen extends StatelessWidget {
  const GuidePlateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(l.guide_section_plate)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.adjust, color: TColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      l.guide_plate_baseFormula,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  l.guide_plate_formula,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _block(
            title: l.guide_plate_starch_title,
            body: l.guide_plate_starch_body,
            icon: Icons.eco,
          ),
          const SizedBox(height: 10),
          _block(
            title: l.guide_plate_protein_title,
            body: l.guide_plate_protein_body,
            icon: Icons.restaurant_menu,
          ),
          const SizedBox(height: 10),
          _block(
            title: l.guide_plate_fats_title,
            body: l.guide_plate_fats_body,
            icon: Icons.water_drop,
          ),
          const SizedBox(height: 12),
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: TColors.gold),
                    const SizedBox(width: 6),
                    Text(
                      l.guide_plate_goldenRule_title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: TColors.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  l.guide_plate_goldenRule_body,
                  style: const TextStyle(height: 1.55),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            GuideData.medicalDisclaimer(locale),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: TColors.textSecondary,
              fontSize: 11,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _block({
    required String title,
    required String body,
    required IconData icon,
  }) {
    return CardContainer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: TColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: TColors.primary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(height: 1.55)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
