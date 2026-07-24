import 'package:flutter/material.dart';

import '../../data/meal_banks_data.dart';
import '../../l10n/enum_labels.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/analysis_result.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';
import '../../widgets/primary_button.dart';
import '../capture/capture_screen.dart';

class MealBanksScreen extends StatelessWidget {
  const MealBanksScreen({super.key});

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

  void _openItem(BuildContext context, MealBankItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => _MealItemSheet(
        item: item,
        zoneColor: _zoneColor(item.zone),
        onCapture: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CaptureScreen()),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(l.guide_section_mealBanks)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CardContainer(
            child: Row(
              children: [
                const Icon(Icons.inbox, color: TColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.mealBanks_intro,
                    style: const TextStyle(height: 1.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final bank in MealBanksData.banks) ...[
            _bankCard(context, bank, locale),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _bankCard(BuildContext context, MealBank bank, String locale) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(bank.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bank.title(locale),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      bank.subtitle(locale),
                      style: const TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1),
          ),
          for (final item in bank.items)
            InkWell(
              onTap: () => _openItem(context, item),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _zoneColor(item.zone),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name(locale),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            item.composition(locale),
                            style: const TextStyle(
                              color: TColors.textSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.info_outline,
                      color: TColors.textSecondary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MealItemSheet extends StatelessWidget {
  final MealBankItem item;
  final Color zoneColor;
  final VoidCallback onCapture;
  const _MealItemSheet({
    required this.item,
    required this.zoneColor,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final note = item.note(locale);
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: TColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: zoneColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    foodZoneLabel(l, item.zone),
                    style: TextStyle(
                      color: zoneColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.name(locale),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.list_alt, color: TColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          l.mealBanks_composition,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: TColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.composition(locale),
                      style: const TextStyle(height: 1.6),
                    ),
                  ],
                ),
              ),
              if (note != null) ...[
                const SizedBox(height: 12),
                CardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: item.zone == FoodZone.yellow
                                ? TColors.gold
                                : TColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l.mealBanks_note,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: item.zone == FoodZone.yellow
                                  ? TColors.gold
                                  : TColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        note,
                        style: const TextStyle(height: 1.6),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              PrimaryButton(
                label: l.mealBanks_capture,
                icon: Icons.camera_alt,
                onPressed: onCapture,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.common_close),
              ),
            ],
          ),
        );
      },
    );
  }
}
