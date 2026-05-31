import 'package:flutter/material.dart';

import '../../data/guide_data.dart';
import '../../theme/theme.dart';
import 'guide_eating_map.dart';
import 'guide_forbidden.dart';
import 'guide_golden_rules.dart';
import 'guide_meal_banks_wrapper.dart';
import 'guide_mistakes.dart';
import 'guide_philosophy.dart';
import 'guide_plate.dart';
import 'guide_program_wrapper.dart';
import 'guide_weekly_prep.dart';

/// تبويب الدليل — الفهرس الذكي ٣×٣ (٩ أقسام).
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الدليل')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الفهرس الذكي',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'الدليل في ٩ أقسام',
                  style: TextStyle(color: TColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.95,
              children: [
                for (final section in _GuideSection.values)
                  _GuideIndexCard(section: section),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              GuideData.medicalDisclaimer,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: TColors.textSecondary,
                fontSize: 11,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _GuideSection {
  philosophy,
  goldenRules,
  eatingMap,
  forbidden,
  plate,
  program15,
  mealBanks,
  weeklyPrep,
  mistakes,
}

extension _SectionMeta on _GuideSection {
  String get number {
    const map = {
      _GuideSection.philosophy: '٠١',
      _GuideSection.goldenRules: '٠٢',
      _GuideSection.eatingMap: '٠٣',
      _GuideSection.forbidden: '٠٤',
      _GuideSection.plate: '٠٥',
      _GuideSection.program15: '٠٦',
      _GuideSection.mealBanks: '٠٧',
      _GuideSection.weeklyPrep: '٠٨',
      _GuideSection.mistakes: '٠٩',
    };
    return map[this]!;
  }

  String get titleAr {
    const map = {
      _GuideSection.philosophy: 'فلسفة النظام',
      _GuideSection.goldenRules: 'القواعد الذهبية',
      _GuideSection.eatingMap: 'خريطة الأكل',
      _GuideSection.forbidden: 'الممنوعات الصريحة',
      _GuideSection.plate: 'طبق الطيبات',
      _GuideSection.program15: 'برنامج ١٥ يوم',
      _GuideSection.mealBanks: 'بنك الوجبات',
      _GuideSection.weeklyPrep: 'التحضير الأسبوعي',
      _GuideSection.mistakes: 'الأخطاء الشائعة',
    };
    return map[this]!;
  }

  IconData get icon {
    const map = {
      _GuideSection.philosophy: Icons.lightbulb,
      _GuideSection.goldenRules: Icons.star,
      _GuideSection.eatingMap: Icons.map,
      _GuideSection.forbidden: Icons.block,
      _GuideSection.plate: Icons.restaurant,
      _GuideSection.program15: Icons.calendar_today,
      _GuideSection.mealBanks: Icons.inbox,
      _GuideSection.weeklyPrep: Icons.checklist,
      _GuideSection.mistakes: Icons.warning_amber,
    };
    return map[this]!;
  }

  Widget destination() {
    switch (this) {
      case _GuideSection.philosophy:
        return const GuidePhilosophyScreen();
      case _GuideSection.goldenRules:
        return const GuideGoldenRulesScreen();
      case _GuideSection.eatingMap:
        return const GuideEatingMapScreen();
      case _GuideSection.forbidden:
        return const GuideForbiddenScreen();
      case _GuideSection.plate:
        return const GuidePlateScreen();
      case _GuideSection.program15:
        return const GuideProgramWrapper();
      case _GuideSection.mealBanks:
        return const GuideMealBanksWrapper();
      case _GuideSection.weeklyPrep:
        return const GuideWeeklyPrepScreen();
      case _GuideSection.mistakes:
        return const GuideMistakesScreen();
    }
  }
}

class _GuideIndexCard extends StatelessWidget {
  final _GuideSection section;
  const _GuideIndexCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TColors.primary,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => section.destination()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    section.number,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    section.icon,
                    color: Colors.white.withOpacity(0.85),
                    size: 18,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                section.titleAr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
