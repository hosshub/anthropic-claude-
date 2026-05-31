import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../widgets/card_container.dart';
import '../capture/capture_screen.dart';
import '../guide/guide_golden_rules.dart';
import '../meal_banks/meal_banks_screen.dart';

/// مساعد "عندما تحتار" — ملخّص ذهبي + ٣ إجراءات سريعة.
class WhenInDoubtScreen extends StatelessWidget {
  const WhenInDoubtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عندما تحتار'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _summary(
            color: TColors.primary,
            icon: Icons.check_circle,
            title: 'اختر',
            body: 'أرز أو بطاطس + بروتين مناسب + دهون طبيعية.',
          ),
          const SizedBox(height: 10),
          _summary(
            color: TColors.khabith,
            icon: Icons.block,
            title: 'امنع تماماً',
            body:
                'الفراخ والبيض، الحليب ومشتقاته، البقوليات، المُصنّع، الزيوت الصناعية.',
          ),
          const SizedBox(height: 10),
          _summary(
            color: TColors.gold,
            icon: Icons.warning_amber,
            title: 'استخدم باعتدال',
            body:
                'الأجبان المعتقة، الفاكهة، العسل، التمر، القهوة، والشاي المحدود.',
          ),
          const SizedBox(height: 10),
          _summary(
            color: TColors.textSecondary,
            icon: Icons.visibility,
            title: 'راقب',
            body: 'الهضم، الطاقة، النوم، والشبع.',
          ),
          const SizedBox(height: 18),
          _actionRow(
            emoji: '🍽',
            title: 'افتح بنك الوجبات',
            subtitle: 'أفكار جاهزة حسب وقت اليوم',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MealBanksScreen()),
              );
            },
          ),
          const SizedBox(height: 10),
          _actionRow(
            emoji: '📖',
            title: 'اقرأ القواعد الذهبية',
            subtitle: 'ست قواعد تُبقي النظام واضحاً',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GuideGoldenRulesScreen()),
              );
            },
          ),
          const SizedBox(height: 10),
          _actionRow(
            emoji: '📸',
            title: 'صوّر ما أمامك',
            subtitle: 'نحلّل وجبتك ونعطيك الإشارة',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CaptureScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _summary({
    required Color color,
    required IconData icon,
    required String title,
    required String body,
  }) {
    return CardContainer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
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

  Widget _actionRow({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: TColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: TColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
