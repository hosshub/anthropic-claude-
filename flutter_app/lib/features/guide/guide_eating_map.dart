import 'package:flutter/material.dart';

import '../../data/guide_data.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/analysis_result.dart';
import '../../theme/theme.dart';

class GuideEatingMapScreen extends StatelessWidget {
  const GuideEatingMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.guide_section_eatingMap),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: TColors.background,
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: TColors.textPrimary,
                unselectedLabelColor: TColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                tabs: [
                  Tab(
                    child: _TabLabel(
                      zone: FoodZone.green,
                      label: l.guide_eatingMap_zoneGreen,
                    ),
                  ),
                  Tab(
                    child: _TabLabel(
                      zone: FoodZone.yellow,
                      label: l.guide_eatingMap_zoneYellow,
                    ),
                  ),
                  Tab(
                    child: _TabLabel(
                      zone: FoodZone.red,
                      label: l.guide_eatingMap_zoneRed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _ZonePage(zone: FoodZone.green, data: GuideData.greenZone),
            _ZonePage(zone: FoodZone.yellow, data: GuideData.yellowZone),
            _ZonePage(zone: FoodZone.red, data: GuideData.redZone),
          ],
        ),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final FoodZone zone;
  final String label;
  const _TabLabel({required this.zone, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: _zoneColor(zone),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class _ZonePage extends StatelessWidget {
  final FoodZone zone;
  final ZoneData data;
  const _ZonePage({required this.zone, required this.data});

  @override
  Widget build(BuildContext context) {
    final color = _zoneColor(zone);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _ZoneHero(zone: zone, data: data, color: color),
        const SizedBox(height: 14),
        for (int i = 0; i < data.groups.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _GroupCard(
            zone: zone,
            group: data.groups[i],
            color: color,
            index: i,
          ),
        ],
        const SizedBox(height: 18),
        _Footer(zone: zone),
      ],
    );
  }
}

class _ZoneHero extends StatelessWidget {
  final FoodZone zone;
  final ZoneData data;
  final Color color;
  const _ZoneHero({
    required this.zone,
    required this.data,
    required this.color,
  });

  IconData get _icon {
    switch (zone) {
      case FoodZone.green:
        return Icons.check_circle;
      case FoodZone.yellow:
        return Icons.warning_amber_rounded;
      case FoodZone.red:
        return Icons.block;
    }
  }

  String _verdict(AppLocalizations l) {
    switch (zone) {
      case FoodZone.green:
        return l.guide_eatingMap_verdictEat;
      case FoodZone.yellow:
        return l.guide_eatingMap_verdictModerate;
      case FoodZone.red:
        return l.guide_eatingMap_verdictAvoid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final watch = data.watchword(locale);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(_icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.label(locale),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: color,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      _verdict(l),
                      style: TextStyle(
                        fontSize: 13,
                        color: color.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.subtitle(locale),
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: TColors.textPrimary,
            ),
          ),
          if (watch != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.tips_and_updates, size: 16, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      watch,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: TColors.textPrimary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final FoodZone zone;
  final ZoneGroup group;
  final Color color;
  final int index;
  const _GroupCard({
    required this.zone,
    required this.group,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final categoryStyle =
        group.category(locale) != null && group.items(locale) != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: TColors.cardShadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: categoryStyle
          ? _CategoryStyle(
              zone: zone,
              categoryAr: group.categoryAr!,
              category: group.category(locale)!,
              items: group.items(locale)!,
              color: color,
              index: index,
            )
          : _ItemStyle(
              itemAr: group.itemAr ?? '',
              item: group.item(locale) ?? '',
              examples: group.examples(locale),
              guidance: group.guidance(locale),
              color: color,
              index: index,
            ),
    );
  }
}

class _CategoryStyle extends StatelessWidget {
  final FoodZone zone;
  final String categoryAr;
  final String category;
  final List<String> items;
  final Color color;
  final int index;
  const _CategoryStyle({
    required this.zone,
    required this.categoryAr,
    required this.category,
    required this.items,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _categoryIcon(zone, categoryAr);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: TColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                '${items.length}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in items) _ItemChip(label: item, color: color),
          ],
        ),
      ],
    );
  }
}

class _ItemStyle extends StatelessWidget {
  final String itemAr;
  final String item;
  final String? examples;
  final String? guidance;
  final Color color;
  final int index;
  const _ItemStyle({
    required this.itemAr,
    required this.item,
    required this.examples,
    required this.guidance,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(_yellowItemIcon(itemAr), color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: TColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        if (examples != null) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final ex in _splitExamples(examples!))
                if (ex.isNotEmpty) _ItemChip(label: ex, color: color),
            ],
          ),
        ],
        if (guidance != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    guidance!,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: color.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Split on either Arabic comma or Latin comma so chips render correctly
  /// in both languages.
  List<String> _splitExamples(String raw) =>
      raw.split(RegExp(r'[،,]')).map((s) => s.trim()).toList();
}

class _ItemChip extends StatelessWidget {
  final String label;
  final Color color;
  const _ItemChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: color.withValues(alpha: 0.95),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final FoodZone zone;
  const _Footer({required this.zone});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    String text;
    switch (zone) {
      case FoodZone.green:
        text = l.guide_eatingMap_footerGreen;
        break;
      case FoodZone.yellow:
        text = l.guide_eatingMap_footerYellow;
        break;
      case FoodZone.red:
        text = l.guide_eatingMap_footerRed;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline,
              size: 16, color: TColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                height: 1.6,
                color: TColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
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

/// Icon lookup is keyed off the Arabic category name so it stays stable
/// regardless of which language is currently displayed.
IconData _categoryIcon(FoodZone zone, String categoryAr) {
  if (categoryAr.contains('النشويات')) return Icons.rice_bowl;
  if (categoryAr.contains('البروتينات')) return Icons.set_meal;
  if (categoryAr.contains('الدهون')) return Icons.opacity;
  if (categoryAr.contains('إضافات بسيطة')) return Icons.spa;
  if (categoryAr.contains('مشروبات')) return Icons.local_drink;
  if (categoryAr.contains('الدواجن') || categoryAr.contains('البيض')) {
    return Icons.egg_alt;
  }
  if (categoryAr.contains('الحليب')) return Icons.local_cafe;
  if (categoryAr.contains('البقوليات')) return Icons.grain;
  if (categoryAr.contains('فائقة التصنيع')) return Icons.fastfood;
  if (categoryAr.contains('الزيوت الصناعية')) return Icons.water_drop;
  if (categoryAr.contains('الإضافات الجاهزة')) return Icons.science;
  return Icons.restaurant_menu;
}

IconData _yellowItemIcon(String itemAr) {
  if (itemAr.contains('الأجبان')) return Icons.bakery_dining;
  if (itemAr.contains('الفواكه')) return Icons.apple;
  if (itemAr.contains('العسل') || itemAr.contains('التمر')) {
    return Icons.eco;
  }
  if (itemAr.contains('القهوة')) return Icons.coffee;
  if (itemAr.contains('الشاي')) return Icons.emoji_food_beverage;
  return Icons.restaurant;
}
