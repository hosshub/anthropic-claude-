import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/analysis_result.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';
import '../../widgets/zone_badge.dart';

/// عرض نتيجة التحليل: النسبة + التفسير + قائمة العناصر بالإشارات.
class ResultScreen extends StatelessWidget {
  final AnalysisResult result;
  final Uint8List imageBytes;

  const ResultScreen({
    super.key,
    required this.result,
    required this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    final score = result.overallScore;
    final scoreColor = TColors.scoreColor(score);

    return Scaffold(
      appBar: AppBar(title: const Text('النتيجة')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.memory(
                  imageBytes,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 18),
              CardContainer(
                child: Column(
                  children: [
                    Text(
                      '$score%',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w800,
                        color: scoreColor,
                      ),
                    ),
                    if (result.scoreLabelAr.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        result.scoreLabelAr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: scoreColor,
                        ),
                      ),
                    ],
                    if (result.scoreExplanationAr.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        result.scoreExplanationAr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: TColors.textSecondary,
                          height: 1.6,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'العناصر المحدَّدة',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              ...result.items.map(_itemCard),
              if (result.suggestions.isNotEmpty) ...[
                const SizedBox(height: 14),
                CardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb, color: TColors.primary),
                          SizedBox(width: 6),
                          Text(
                            'اقتراحات للتحسين',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: TColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...result.suggestions.map(
                        (s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text('• $s'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (result.warnings.isNotEmpty) ...[
                const SizedBox(height: 14),
                CardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber, color: TColors.gold),
                          SizedBox(width: 6),
                          Text(
                            'تنبيهات',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: TColors.gold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...result.warnings.map(
                        (w) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text('• $w'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              const Text(
                'هذا التطبيق لا يقدّم استشارة طبية. النتائج لأغراض المتابعة فقط.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemCard(FoodItem item) {
    final hasCaution =
        item.zone == FoodZone.yellow && (item.cautionAr ?? '').isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nameAr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: TColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.category} • ${item.estimatedPortion}',
                        style: const TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ZoneBadge(zone: item.zone),
              ],
            ),
            if (hasCaution) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.visibility, color: TColors.gold, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.cautionAr!,
                      style: const TextStyle(
                        color: TColors.gold,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (item.reasoningAr.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.reasoningAr,
                style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
