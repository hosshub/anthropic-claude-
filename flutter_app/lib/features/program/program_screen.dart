import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/program_data.dart';
import '../../theme/theme.dart';
import '../../widgets/card_container.dart';
import '../../widgets/primary_button.dart';
import '../capture/capture_screen.dart';

const String _prefsKey = 'program_started_at_ms';

class ProgramScreen extends StatefulWidget {
  const ProgramScreen({super.key});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  DateTime? _startedAt;
  bool _loading = true;
  int _selectedDay = 1;

  ProgramStatus get _status => ProgramData.statusFor(_startedAt);

  @override
  void initState() {
    super.initState();
    _loadStartedAt();
  }

  Future<void> _loadStartedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_prefsKey);
    setState(() {
      _startedAt = ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
      _loading = false;
      _selectedDay = _status is InProgress ? (_status as InProgress).day : 1;
    });
  }

  Future<void> _start() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setInt(_prefsKey, now.millisecondsSinceEpoch);
    setState(() {
      _startedAt = now;
      _selectedDay = 1;
    });
  }

  Future<void> _stop() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    setState(() {
      _startedAt = null;
      _selectedDay = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('برنامج ١٥ يوم')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _introCard,
                const SizedBox(height: 12),
                ..._bodyForStatus(_status),
              ],
            ),
    );
  }

  // ---- Common parts ----

  Widget get _introCard => CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.calendar_month, color: TColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ProgramData.titleAr,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: TColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              ProgramData.philosophyAr,
              style: TextStyle(
                color: TColors.textSecondary,
                height: 1.55,
              ),
            ),
          ],
        ),
      );

  List<Widget> _bodyForStatus(ProgramStatus status) {
    if (status is NotStarted) {
      return [
        _phasesPreview,
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'ابدأ البرنامج اليوم',
          icon: Icons.play_arrow,
          onPressed: _start,
        ),
      ];
    }
    if (status is InProgress) {
      final currentDay = status.day;
      return [
        _progressHeader(currentDay),
        const SizedBox(height: 10),
        _phasePills(currentDay),
        const SizedBox(height: 12),
        _daySelector(currentDay),
        const SizedBox(height: 12),
        _dayDetailCard(
          ProgramData.day(_selectedDay)!,
          _selectedDay == currentDay,
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _stop,
          icon: const Icon(Icons.stop),
          label: const Text('أوقف البرنامج'),
          style: OutlinedButton.styleFrom(
            foregroundColor: TColors.khabith,
            minimumSize: const Size.fromHeight(46),
            side: const BorderSide(color: TColors.khabith, width: 1.2),
          ),
        ),
      ];
    }
    // completed
    return [
      _completionCard,
      const SizedBox(height: 12),
      PrimaryButton(
        label: 'ابدأ من جديد',
        icon: Icons.replay,
        onPressed: _start,
      ),
    ];
  }

  // ---- Not started: phases preview ----

  Widget get _phasesPreview => CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'مراحل الرحلة',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: TColors.primary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            for (final phase in ProgramData.phases) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: phase.color,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        arabicNumeral(phase.number),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phase.titleAr,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            phase.daysRangeAr,
                            style: const TextStyle(
                              color: TColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            phase.focusAr,
                            style: const TextStyle(
                              color: TColors.textSecondary,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  // ---- In-progress: header + selector + day card ----

  Widget _progressHeader(int currentDay) {
    final day = ProgramData.day(currentDay);
    return CardContainer(
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: currentDay / 15,
                    strokeWidth: 8,
                    backgroundColor: TColors.primary.withOpacity(0.15),
                    color: TColors.primary,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '${arabicNumeral(currentDay)}/${arabicNumeral(15)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: TColors.primary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اليوم ${arabicNumeral(currentDay)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: TColors.textPrimary,
                  ),
                ),
                if (day != null)
                  Text(
                    day.focusAr,
                    style: const TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _phasePills(int currentDay) {
    return Row(
      children: [
        for (final phase in ProgramData.phases) ...[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _phasePill(phase, phase.contains(currentDay)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _phasePill(ProgramPhase phase, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: active ? phase.color.withOpacity(0.20) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: phase.color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 6),
          Text(
            phase.titleAr,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? TColors.textPrimary : TColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _daySelector(int currentDay) {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 15,
        itemBuilder: (_, i) {
          final d = i + 1;
          final selected = d == _selectedDay;
          final isCurrent = d == currentDay;
          final completed = d < currentDay;
          final bg = selected
              ? TColors.primary
              : isCurrent
                  ? TColors.gold.withOpacity(0.18)
                  : completed
                      ? TColors.primary.withOpacity(0.15)
                      : TColors.surface;
          final fg = selected ? Colors.white : TColors.textPrimary;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedDay = d),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(color: TColors.gold, width: 2)
                      : null,
                ),
                child: Text(
                  arabicNumeral(d),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: fg,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _dayDetailCard(ProgramDay detail, bool isCurrent) {
    final completed = detail.day < (_status is InProgress
        ? (_status as InProgress).day
        : 0);
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'اليوم ${arabicNumeral(detail.day)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: TColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              if (isCurrent)
                _badge('اليوم الحالي', TColors.gold)
              else if (completed)
                _badge('اكتمل', TColors.primary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detail.focusAr,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          _block(
            label: 'وجبة مقترحة',
            text: detail.exampleMealAr,
            color: TColors.primary,
            icon: Icons.restaurant,
          ),
          const SizedBox(height: 10),
          _block(
            label: 'نصيحة اليوم',
            text: detail.tipAr,
            color: TColors.gold,
            icon: Icons.lightbulb_outline,
          ),
          if (isCurrent) ...[
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'صوّر وجبة اليوم',
              icon: Icons.camera_alt,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CaptureScreen()),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      );

  Widget _block({
    required String label,
    required String text,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(height: 1.6)),
      ],
    );
  }

  // ---- Completed ----

  Widget get _completionCard => CardContainer(
        child: Column(
          children: [
            const Icon(
              Icons.verified,
              size: 56,
              color: TColors.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'أكملت البرنامج 🎉',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'اعرف الآن أي وجبات تعطيك راحة وشبعاً بدون ثقل. كرّر أفضل ٥ منها كقاعدة لك.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      );
}
