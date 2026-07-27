import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/meal_repository.dart';
import '../../l10n/enum_labels.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/analysis_result.dart';
import '../../models/meal.dart';
import '../../services/score_engine.dart';
import '../../theme/theme.dart';
import '../../widgets/primary_button.dart';

/// يفتح ورقة تعديل عناصر الوجبة. تُعيد true إذا حُفظ تعديل.
Future<bool> showEditItemsSheet(BuildContext context, Meal meal) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: TColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _EditItemsSheet(meal: meal),
  );
  return saved == true;
}

class _EditItemsSheet extends StatefulWidget {
  final Meal meal;
  const _EditItemsSheet({required this.meal});

  @override
  State<_EditItemsSheet> createState() => _EditItemsSheetState();
}

class _EditableItem {
  FoodItem item;
  final TextEditingController controller;
  _EditableItem(this.item) : controller = TextEditingController(text: item.nameAr);
}

class _EditItemsSheetState extends State<_EditItemsSheet> {
  late List<_EditableItem> _items;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _items = widget.meal.items.map(_EditableItem.new).toList();
  }

  @override
  void dispose() {
    for (final e in _items) {
      e.controller.dispose();
    }
    super.dispose();
  }

  List<FoodItem> _currentItems() => [
        for (final e in _items)
          e.item.copyWith(
            nameAr: e.controller.text.trim().isEmpty
                ? e.item.nameAr
                : e.controller.text.trim(),
          ),
      ];

  int get _previewScore =>
      recomputeScore([for (final e in _items) e.item]);

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    if (_items.isEmpty) return;
    setState(() => _saving = true);
    final repo = context.read<MealRepository>();
    final navigator = Navigator.of(context);
    final items = _currentItems();
    final score = recomputeScore(items);
    try {
      await repo.updateMealItems(
        widget.meal.id,
        items,
        score: score,
        label: scoreBandLabel(l, score),
      );
      navigator.pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final previewColor = TColors.scoreColor(_previewScore);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scroll) => Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l.editItems_title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l.editItems_hint,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 12.5,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Text(
                        l.editItems_empty,
                        style: const TextStyle(color: TColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      controller: scroll,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _itemEditor(l, i),
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: TColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: TColors.cardShadow,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l.editItems_newScore,
                        style: const TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: previewColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Text(
                          l.common_percentValue(_previewScore),
                          style: TextStyle(
                            color: previewColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    label: l.common_save,
                    icon: Icons.check,
                    loading: _saving,
                    onPressed:
                        _items.isEmpty || _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemEditor(AppLocalizations l, int index) {
    final entry = _items[index];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: entry.controller,
                  decoration: InputDecoration(
                    labelText: l.editItems_nameLabel,
                    isDense: true,
                  ),
                ),
              ),
              IconButton(
                tooltip: l.editItems_removeTooltip,
                icon: const Icon(Icons.delete_outline,
                    color: TColors.khabith),
                onPressed: () => setState(() {
                  _items.removeAt(index).controller.dispose();
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SegmentedButton<FoodZone>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            segments: [
              for (final zone in FoodZone.values)
                ButtonSegment(
                  value: zone,
                  label: Text(foodZoneLabel(l, zone)),
                ),
            ],
            selected: {entry.item.zone},
            onSelectionChanged: (s) => setState(() {
              entry.item = entry.item.copyWith(newZone: s.first);
            }),
          ),
        ],
      ),
    );
  }
}
