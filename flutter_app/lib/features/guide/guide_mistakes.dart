import 'package:flutter/material.dart';

import '../../data/guide_data.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';

/// ٠٩ — الأخطاء الشائعة وتصحيحها.
class GuideMistakesScreen extends StatelessWidget {
  const GuideMistakesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأخطاء الشائعة')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: GuideData.commonMistakes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final m = GuideData.commonMistakes[i];
          return CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, color: TColors.khabith),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        m.mistakeAr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: TColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, color: TColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        m.correctionAr,
                        style: const TextStyle(
                          fontSize: 15,
                          color: TColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
