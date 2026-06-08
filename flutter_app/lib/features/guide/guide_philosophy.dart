import 'package:flutter/material.dart';

import '../../data/guide_data.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';

class GuidePhilosophyScreen extends StatelessWidget {
  const GuidePhilosophyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(l.guide_section_philosophy)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final card in GuideData.philosophyCards) ...[
            CardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title(locale),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: TColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.body(locale),
                    style: const TextStyle(
                      color: TColors.textPrimary,
                      height: 1.65,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 6),
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
}
