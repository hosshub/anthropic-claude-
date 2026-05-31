import 'package:flutter/material.dart';

import '../../data/guide_data.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';

/// ٠٤ — الممنوعات الصريحة (المنطقة الحمراء).
class GuideForbiddenScreen extends StatelessWidget {
  const GuideForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final red = GuideData.redZone;
    return Scaffold(
      appBar: AppBar(title: const Text('الممنوعات الصريحة')),
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
                    red.subtitleAr,
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
            if (group.categoryAr != null && group.items != null) ...[
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.categoryAr!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: TColors.khabith,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final item in group.items!)
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
