import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/guide_data.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';

/// ٠٨ — التحضير الأسبوعي. قائمة قابلة للتعليم، تُحفظ لكل أسبوع وتُصفّر تلقائياً
/// مع بداية أسبوع جديد (السبت).
class GuideWeeklyPrepScreen extends StatefulWidget {
  const GuideWeeklyPrepScreen({super.key});

  @override
  State<GuideWeeklyPrepScreen> createState() => _GuideWeeklyPrepScreenState();
}

class _GuideWeeklyPrepScreenState extends State<GuideWeeklyPrepScreen> {
  Set<String> _done = <String>{};
  bool _loading = true;
  late final String _weekKey;
  late final DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _weekStart = _currentArabicWeekStart();
    _weekKey =
        'weekly_prep_${_weekStart.year}-${_two(_weekStart.month)}-${_two(_weekStart.day)}';
    _load();
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  static DateTime _currentArabicWeekStart() {
    final now = DateTime.now();
    // weekday: Mon=1..Sun=7, Sat=6. الأسبوع العربي يبدأ السبت.
    final daysBack = (now.weekday + 1) % 7;
    final saturday = now.subtract(Duration(days: daysBack));
    return DateTime(saturday.year, saturday.month, saturday.day);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_weekKey) ?? const <String>[];
    if (!mounted) return;
    setState(() {
      _done = list.toSet();
      _loading = false;
    });
  }

  Future<void> _toggle(String id) async {
    setState(() {
      if (_done.contains(id)) {
        _done.remove(id);
      } else {
        _done.add(id);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_weekKey, _done.toList());
  }

  Future<void> _resetWeek() async {
    setState(() => _done = <String>{});
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_weekKey);
  }

  String get _weekLabel {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return 'أسبوع ${_weekStart.day} ${months[_weekStart.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final total = GuideData.weeklyPrep.length;
    final doneCount = _done.length;
    final progress = total == 0 ? 0.0 : doneCount / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('التحضير الأسبوعي'),
        actions: [
          if (doneCount > 0)
            IconButton(
              tooltip: 'تصفير الأسبوع',
              onPressed: _resetWeek,
              icon: const Icon(Icons.restart_alt),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.checklist, color: TColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _weekLabel,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: TColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '$doneCount / $total',
                            style: const TextStyle(
                              color: TColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor:
                              TColors.primary.withOpacity(0.12),
                          valueColor: const AlwaysStoppedAnimation(
                            TColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'علّم كل مهمة بعد إنجازها. القائمة تتصفّر تلقائياً '
                        'مع بداية كل سبت.',
                        style: TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                for (final task in GuideData.weeklyPrep) ...[
                  _TaskRow(
                    task: task,
                    done: _done.contains(task.id),
                    onToggle: () => _toggle(task.id),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final WeeklyPrepTask task;
  final bool done;
  final VoidCallback onToggle;
  const _TaskRow({
    required this.task,
    required this.done,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                done
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: done
                    ? TColors.primary
                    : TColors.primary.withOpacity(0.7),
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.titleAr,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: done
                            ? TColors.textSecondary
                            : TColors.textPrimary,
                        decoration: done
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (task.estimatedMinutes != null)
                          _meta(
                            Icons.timer_outlined,
                            '${task.estimatedMinutes} د',
                          ),
                        _meta(Icons.ac_unit, 'صالح ${task.validDays} يوم'),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: TColors.primary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Text(
                            weeklyCategoryLabel(task.category),
                            style: const TextStyle(
                              fontSize: 11,
                              color: TColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: TColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: TColors.textSecondary,
            ),
          ),
        ],
      );
}
