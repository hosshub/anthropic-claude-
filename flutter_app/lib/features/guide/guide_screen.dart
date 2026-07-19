import 'package:flutter/material.dart';

import '../../data/guide_data.dart';
import '../../data/program_data.dart';
import '../../l10n/generated/app_localizations.dart';
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
import 'guidebook_screen.dart';

/// تبويب الدليل — الفهرس الذكي ٣×٣ (٩ أقسام).
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(l.tab_guide)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.guide_index_title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.guide_index_subtitle,
                  style: const TextStyle(color: TColors.textSecondary),
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
              GuideData.medicalDisclaimer(locale),
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
  guidebook,
  weeklyPrep,
  mistakes,
}

extension _SectionMeta on _GuideSection {
  String number(String locale) {
    final raw = index + 1;
    return localizedNumeral(raw, locale).padLeft(2, locale == 'en' ? '0' : '٠');
  }

  String title(AppLocalizations l) {
    switch (this) {
      case _GuideSection.philosophy:
        return l.guide_section_philosophy;
      case _GuideSection.goldenRules:
        return l.guide_section_goldenRules;
      case _GuideSection.eatingMap:
        return l.guide_section_eatingMap;
      case _GuideSection.forbidden:
        return l.guide_section_forbidden;
      case _GuideSection.plate:
        return l.guide_section_plate;
      case _GuideSection.program15:
        return l.guide_section_program15;
      case _GuideSection.mealBanks:
        return l.guide_section_mealBanks;
      case _GuideSection.guidebook:
        return l.guide_section_guidebook;
      case _GuideSection.weeklyPrep:
        return l.guide_section_weeklyPrep;
      case _GuideSection.mistakes:
        return l.guide_section_mistakes;
    }
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
      _GuideSection.guidebook: Icons.menu_book,
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
      case _GuideSection.guidebook:
        return const GuidebookScreen();
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
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
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
                    section.number(locale),
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
                section.title(l),
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
