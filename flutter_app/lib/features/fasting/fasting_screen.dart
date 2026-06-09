import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/enum_labels.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/fasting_calculator.dart';
import '../../services/fasting_repository.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';

class FastingScreen extends StatefulWidget {
  const FastingScreen({super.key});

  @override
  State<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends State<FastingScreen> {
  Future<FastingEntry?>? _today;
  Future<List<FastingEntry>>? _recent;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _reload();
  }

  void _reload() {
    final repo = context.read<FastingRepository>();
    _today = repo.loadFor(_now);
    _recent = repo.recent();
  }

  Future<void> _toggle(FastingEntry? existing, List<FastingKind> kinds) async {
    final repo = context.read<FastingRepository>();
    if (existing != null) {
      await repo.unmark(_now);
    } else {
      final kind = kinds.isNotEmpty ? kinds.first : FastingKind.general;
      await repo.markFasting(date: _now, kind: kind);
    }
    setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final repo = context.watch<FastingRepository>();
    _today ??= repo.loadFor(_now);
    _recent ??= repo.recent();

    final todayKinds = FastingCalculator.kindsFor(_now);
    final upcoming = FastingCalculator.nextRecommended(
      _now.add(const Duration(days: 1)),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.fasting_title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FutureBuilder<FastingEntry?>(
            future: _today,
            builder: (context, snap) {
              final entry = snap.data;
              return _TodayCard(
                date: _now,
                kinds: todayKinds,
                entry: entry,
                onToggle: () => _toggle(entry, todayKinds),
              );
            },
          ),
          if (upcoming != null) ...[
            const SizedBox(height: 12),
            _UpcomingCard(date: upcoming.date, kinds: upcoming.kinds),
          ],
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 8),
            child: Text(
              l.fasting_log,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
          FutureBuilder<List<FastingEntry>>(
            future: _recent,
            builder: (context, snap) {
              final entries = snap.data ?? const <FastingEntry>[];
              if (entries.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: TColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    l.fasting_history_empty,
                    style: const TextStyle(color: TColors.textSecondary),
                  ),
                );
              }
              return Column(
                children: [
                  for (final e in entries) _HistoryRow(entry: e),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _TodayCard extends StatelessWidget {
  final DateTime date;
  final List<FastingKind> kinds;
  final FastingEntry? entry;
  final VoidCallback onToggle;
  const _TodayCard({
    required this.date,
    required this.kinds,
    required this.entry,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final fasting = entry != null;
    final color = fasting ? TColors.zoneGreen : TColors.gold;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            color.withOpacity(0.18),
            color.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.30)),
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
                child: Icon(
                  fasting ? Icons.brightness_2 : Icons.wb_sunny,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fasting ? l.fasting_fastingToday : l.fasting_today,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    Text(
                      FastingCalculator.hijriShort(date),
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
          if (kinds.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final k in kinds)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: color.withOpacity(0.30)),
                    ),
                    child: Text(
                      fastingKindLabel(l, k),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              fastingKindHint(l, kinds.first),
              style: const TextStyle(
                color: TColors.textSecondary,
                fontSize: 12.5,
                height: 1.55,
              ),
            ),
          ],
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onToggle,
            style: FilledButton.styleFrom(
              backgroundColor: fasting ? Colors.white : color,
              foregroundColor: fasting ? color : Colors.white,
              side: BorderSide(color: color, width: 1.2),
              minimumSize: const Size.fromHeight(48),
            ),
            icon: Icon(fasting ? Icons.close : Icons.check),
            label: Text(
              fasting ? l.fasting_unmarkFasting : l.fasting_markFasting,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _UpcomingCard extends StatelessWidget {
  final DateTime date;
  final List<FastingKind> kinds;
  const _UpcomingCard({required this.date, required this.kinds});

  String _daysAway(AppLocalizations l) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;
    if (diff == 1) return l.fasting_tomorrow;
    return l.fasting_inDays(diff);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return CardContainer(
      child: Row(
        children: [
          const Icon(Icons.calendar_today,
              color: TColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.fasting_nextSuggestion(_daysAway(l)),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  kinds.map((k) => fastingKindLabel(l, k)).join(l.common_listSeparator),
                  style: const TextStyle(
                    color: TColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
                Text(
                  FastingCalculator.hijriShort(date),
                  style: const TextStyle(
                    color: TColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _HistoryRow extends StatelessWidget {
  final FastingEntry entry;
  const _HistoryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: TColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.brightness_2,
                color: TColors.zoneGreen, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.dateKey,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    fastingKindLabel(l, entry.kind),
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
      ),
    );
  }
}
