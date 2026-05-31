import 'package:flutter/material.dart';

import '../../data/guide_data.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';

/// ٠٥ — طبق الطيبات (الصيغة الأساسية).
class GuidePlateScreen extends StatelessWidget {
  const GuidePlateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طبق الطيبات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.adjust, color: TColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'الصيغة الأساسية',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'أرز أو بطاطس + بروتين مناسب + دهون طبيعية',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _block(
            title: 'نشويات',
            body: 'اختر بين الأرز أو البطاطس بأي طريقة تحبها (مسلوقة، مشوية، مقلية…).',
            icon: Icons.eco,
          ),
          const SizedBox(height: 10),
          _block(
            title: 'بروتين',
            body:
                'لحم أحمر، كبدة، كوارع، أرنب، حمام، أو سمك مستوٍ تماماً. تجنّب الدواجن والبيض.',
            icon: Icons.restaurant_menu,
          ),
          const SizedBox(height: 10),
          _block(
            title: 'دهون طبيعية',
            body: 'سمن بلدي، زبدة طبيعية، زيت زيتون، أو زيتون — باعتدال.',
            icon: Icons.water_drop,
          ),
          const SizedBox(height: 12),
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.star, color: TColors.gold),
                    SizedBox(width: 6),
                    Text(
                      'القاعدة الذهبية',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: TColors.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'بسّط مكونات الوجبة، وتوقّف قبل الامتلاء، وراقب استجابة جسمك.',
                  style: TextStyle(height: 1.55),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
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

  Widget _block({required String title, required String body, required IconData icon}) {
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
