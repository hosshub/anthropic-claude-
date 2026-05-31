import 'package:flutter/material.dart';

import '../../data/guide_data.dart';
import '../../models/analysis_result.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';

/// ٠٣ — خريطة الأكل: المناطق الثلاث بكل مجموعاتها.
class GuideEatingMapScreen extends StatelessWidget {
  const GuideEatingMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خريطة الأكل')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _zoneCard(FoodZone.green, GuideData.greenZone),
          const SizedBox(height: 14),
          _zoneCard(FoodZone.yellow, GuideData.yellowZone),
          const SizedBox(height: 14),
          _zoneCard(FoodZone.red, GuideData.redZone),
        ],
      ),
    );
  }

  Color _zoneColor(FoodZone zone) {
    switch (zone) {
      case FoodZone.green:
        return TColors.zoneGreen;
      case FoodZone.yellow:
        return TColors.zoneYellow;
      case FoodZone.red:
        return TColors.zoneRed;
    }
  }

  Widget _zoneCard(FoodZone zone, ZoneData data) {
    final c = _zoneColor(zone);
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                data.labelAr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: c,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data.subtitleAr,
            style: const TextStyle(
              color: TColors.textSecondary,
              fontSize: 12,
            ),
          ),
          if (data.watchwordAr != null) ...[
            const SizedBox(height: 4),
            Text(
              data.watchwordAr!,
              style: const TextStyle(
                color: TColors.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          for (final group in data.groups) ...[
            _groupRow(group, c),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _groupRow(ZoneGroup group, Color zoneColor) {
    if (group.categoryAr != null && group.items != null) {
      // مجموعة فئة (خضراء/حمراء).
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.categoryAr!,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: TColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          for (final item in group.items!)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: zoneColor,
                      shape: BoxShape.circle,
                    ),
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
      );
    }
    // مجموعة عنصر (صفراء).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: zoneColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                group.itemAr ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (group.examplesAr != null) ...[
          const SizedBox(height: 4),
          Text(
            'أمثلة: ${group.examplesAr!}',
            style: const TextStyle(
              color: TColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
        if (group.guidanceAr != null) ...[
          const SizedBox(height: 2),
          Text(
            group.guidanceAr!,
            style: const TextStyle(
              color: TColors.textSecondary,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
