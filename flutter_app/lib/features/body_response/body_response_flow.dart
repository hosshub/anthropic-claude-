import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/meal_repository.dart';
import '../../models/body_response.dart';
import '../../models/meal.dart';
import '../../theme/theme.dart';

/// تدفق متابعة الجسم بعد الوجبة — ٥ أسئلة + شاشة شكر.
class BodyResponseFlow extends StatefulWidget {
  final Meal meal;
  const BodyResponseFlow({super.key, required this.meal});

  @override
  State<BodyResponseFlow> createState() => _BodyResponseFlowState();
}

class _BodyResponseFlowState extends State<BodyResponseFlow> {
  static const int _totalSteps = 6; // ٥ أسئلة + شاشة الشكر

  final PageController _controller = PageController();
  int _step = 0;

  late int _satisfaction;
  late int _bloating;
  late int _energy;
  late SleepImpact _sleep;
  late WorthRepeating _worth;
  late TextEditingController _notesCtrl;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.meal.bodyResponse;
    _satisfaction = existing?.satisfyingFullness ?? 3;
    _bloating = existing?.bloating ?? 0;
    _energy = existing?.energyLevel ?? 3;
    _sleep = existing?.sleepImpact ?? SleepImpact.unknown;
    _worth = existing?.worthRepeating ?? WorthRepeating.maybe;
    _notesCtrl = TextEditingController(text: existing?.notes ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _go(int step) {
    if (step < 0 || step >= _totalSteps) return;
    setState(() => _step = step);
    _controller.animateToPage(
      step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _saveAndAdvance() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context.read<MealRepository>().upsertBodyResponse(
            mealId: widget.meal.id,
            satisfyingFullness: _satisfaction,
            bloating: _bloating,
            energyLevel: _energy,
            sleepImpact: _sleep,
            worthRepeating: _worth,
            notes: _notesCtrl.text,
          );
      _go(_totalSteps - 1);
    } catch (e) {
      setState(() => _error = 'تعذّر الحفظ: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: TColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _header,
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _step = i),
                  children: [
                    _satisfactionPage,
                    _bloatingPage,
                    _energyPage,
                    _sleepPage,
                    _worthPage,
                    _thankYouPage,
                  ],
                ),
              ),
              _footer,
            ],
          ),
        ),
      ),
    );
  }

  // ----- Header / Footer -----

  Widget get _header {
    final stepIndicator = _step < _totalSteps - 1
        ? '${_step + 1} / ${_totalSteps - 1}'
        : 'تم';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(foregroundColor: TColors.textSecondary),
                child: const Text('لاحقاً'),
              ),
              const Spacer(),
              const Text(
                'كيف شعرت بعد الوجبة؟',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                stepIndicator,
                style: const TextStyle(color: TColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_step + 1) / _totalSteps,
              minHeight: 6,
              backgroundColor: TColors.primary.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation(TColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _footer {
    final isQuestionPage = _step < _totalSteps - 1;
    final isLastQuestion = _step == _totalSteps - 2;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        children: [
          if (_step > 0 && isQuestionPage)
            OutlinedButton(
              onPressed: () => _go(_step - 1),
              style: OutlinedButton.styleFrom(
                foregroundColor: TColors.textSecondary,
                side: BorderSide(color: TColors.textSecondary.withOpacity(0.3)),
              ),
              child: const Text('السابق'),
            ),
          const Spacer(),
          if (_error != null) ...[
            Expanded(
              child: Text(
                _error!,
                style: const TextStyle(color: TColors.khabith, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (isQuestionPage && !isLastQuestion)
            ElevatedButton(
              onPressed: () => _go(_step + 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('التالي'),
            )
          else if (isLastQuestion)
            ElevatedButton(
              onPressed: _saving ? null : _saveAndAdvance,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('احفظ'),
            )
          else
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('أنهِ'),
            ),
        ],
      ),
    );
  }

  // ----- Pages -----

  Widget _questionFrame({
    required String title,
    required String hint,
    required Widget body,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: TColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hint,
            style: const TextStyle(color: TColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 22),
          body,
        ],
      ),
    );
  }

  Widget get _satisfactionPage {
    String emojiFor(int v) {
      switch (v) {
        case 1:
          return '😣';
        case 2:
          return '🙁';
        case 3:
          return '🙂';
        case 4:
          return '😌';
        default:
          return '😵';
      }
    }

    String hintFor(int v) {
      switch (v) {
        case 1:
          return 'لم أشعر بشبع';
        case 2:
          return 'شبع خفيف';
        case 3:
          return 'شبع مريح';
        case 4:
          return 'شبع كامل';
        default:
          return 'ممتلئ جداً';
      }
    }

    return _questionFrame(
      title: 'هل شعرت بشبع مريح؟',
      hint: hintFor(_satisfaction),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var v = 1; v <= 5; v++)
            GestureDetector(
              onTap: () => setState(() => _satisfaction = v),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _satisfaction == v
                      ? TColors.primary.withOpacity(0.18)
                      : Colors.transparent,
                  border: Border.all(
                    color: _satisfaction == v
                        ? TColors.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(emojiFor(v), style: const TextStyle(fontSize: 36)),
              ),
            ),
        ],
      ),
    );
  }

  Widget get _bloatingPage {
    String hint() {
      if (_bloating == 0) return 'مرتاح تماماً';
      if (_bloating <= 2) return 'ثقل خفيف';
      if (_bloating == 3) return 'انتفاخ ملحوظ';
      if (_bloating == 4) return 'ثقل واضح';
      return 'ثقل شديد';
    }

    Color color() {
      if (_bloating == 0) return TColors.primary;
      if (_bloating <= 2) return TColors.gold;
      return TColors.khabith;
    }

    return _questionFrame(
      title: 'هل حدث انتفاخ أو ثقل؟',
      hint: hint(),
      body: Column(
        children: [
          Text(
            '$_bloating',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: color(),
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color(),
              thumbColor: color(),
              inactiveTrackColor: color().withOpacity(0.25),
            ),
            child: Slider(
              value: _bloating.toDouble(),
              min: 0,
              max: 5,
              divisions: 5,
              onChanged: (v) => setState(() => _bloating = v.round()),
            ),
          ),
          const Row(
            children: [
              Text('٠ مرتاح',
                  style: TextStyle(color: TColors.textSecondary, fontSize: 11)),
              Spacer(),
              Text('٥ ثقل شديد',
                  style: TextStyle(color: TColors.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget get _energyPage {
    String label(int v) {
      switch (v) {
        case 1:
          return 'نعسان جداً';
        case 2:
          return 'خامل';
        case 3:
          return 'عادي';
        case 4:
          return 'نشيط';
        default:
          return 'نشيط جداً';
      }
    }

    return _questionFrame(
      title: 'كيف كانت طاقتك بعد الأكل؟',
      hint: label(_energy),
      body: Column(
        children: [
          for (var v = 5; v >= 1; v--)
            _RadioRow(
              label: label(v),
              selected: _energy == v,
              onTap: () => setState(() => _energy = v),
            ),
        ],
      ),
    );
  }

  Widget get _sleepPage {
    return _questionFrame(
      title: 'كيف كان نومك بعد الوجبة؟',
      hint: 'اختياري — يمكنك تركها على "لا أعلم" والعودة لاحقاً.',
      body: Column(
        children: [
          for (final option in SleepImpact.values)
            _RadioRow(
              label: option.labelAr,
              selected: _sleep == option,
              onTap: () => setState(() => _sleep = option),
            ),
        ],
      ),
    );
  }

  Widget get _worthPage {
    return _questionFrame(
      title: 'هل تستحق هذه الوجبة التكرار؟',
      hint: 'هذه الإجابة تساعد التطبيق يقترح ما يناسب جسمك.',
      body: Column(
        children: [
          Row(
            children: [
              for (final option in WorthRepeating.values)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _worth = option),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _worth == option
                              ? TColors.primary.withOpacity(0.12)
                              : TColors.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Text(option.emoji,
                                style: const TextStyle(fontSize: 36)),
                            const SizedBox(height: 4),
                            Text(
                              option.labelAr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: TColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_worth == WorthRepeating.no) ...[
            const SizedBox(height: 14),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              minLines: 2,
              decoration: const InputDecoration(
                labelText: 'لماذا؟ (اختياري)',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget get _thankYouPage {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, color: TColors.primary, size: 64),
          const SizedBox(height: 14),
          Text('شكراً لك',
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          const Text(
            'هذه الملاحظات تساعدك تعرف جسمك أكثر، ومع الوقت يساعدك التطبيق على اقتراح ما يناسبك.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TColors.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? TColors.primary.withOpacity(0.10) : TColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: selected ? TColors.primary : TColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: TColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
