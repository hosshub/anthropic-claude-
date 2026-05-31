import 'package:flutter/material.dart';

import '../../data/guide_data.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';

/// ٠٨ — التحضير الأسبوعي (٦ مهام).
class GuideWeeklyPrepScreen extends StatelessWidget {
  const GuideWeeklyPrepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التحضير الأسبوعي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CardContainer(
            child: Row(
              children: const [
                Icon(Icons.checklist, color: TColors.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'قائمة تحضير الأسبوع — أعدّها مرة واحدة وارتح أكثر.',
                    style: TextStyle(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          for (final task in GuideData.weeklyPrep) ...[
            CardContainer(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.radio_button_unchecked,
                    color: TColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.titleAr,
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (task.estimatedMinutes != null)
                              _meta(
                                Icons.timer_outlined,
                                '${task.estimatedMinutes} د',
                              ),
                            _meta(
                              Icons.ac_unit,
                              'صالح ${task.validDays} يوم',
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: TColors.primary.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Text(
                                weeklyCategoryLabel(task.category),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: TColors.primary,
                                ),
                              ),
                            ),
                          ],
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
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: TColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: TColors.textSecondary,
            ),
          ),
        ],
      );
}
