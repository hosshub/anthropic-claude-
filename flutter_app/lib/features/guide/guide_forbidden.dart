import 'package:flutter/material.dart';

import '../../data/guide_data.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';

class GuideForbiddenScreen extends StatelessWidget {
  const GuideForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final red = GuideData.redZone;
    return Scaffold(
      appBar: AppBar(title: Text(l.guide_section_forbidden)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CardContainer(
            child: Row(
              children: [
                const Icon(Icons.block, color: TColors.khabith),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    red.subtitle(locale),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: TColors.khabith,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final group in red.groups) ...[
            if (group.category(locale) != null &&
                group.items(locale) != null) ...[
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.category(locale)!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: TColors.khabith,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final item in group.items(locale)!)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Icon(
                              Icons.close,
                              size: 14,
                              color: TColors.khabith.withOpacity(0.7),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }
}
