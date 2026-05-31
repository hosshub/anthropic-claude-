import 'package:flutter/material.dart';

import '../../data/guide_data.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';

/// ٠١ — فلسفة النظام: ٣ بطاقات.
class GuidePhilosophyScreen extends StatelessWidget {
  const GuidePhilosophyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فلسفة النظام')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final card in GuideData.philosophyCards) ...[
            CardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.titleAr,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: TColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.bodyAr,
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
            GuideData.medicalDisclaimer,
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
