import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/meal_repository.dart';
import '../../l10n/enum_labels.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/body_response.dart';
import '../../models/meal.dart';
import '../../services/notification_service.dart';
import '../../theme/theme.dart';

class BodyResponseFlow extends StatefulWidget {
  final Meal meal;
  const BodyResponseFlow({super.key, required this.meal});

  @override
  State<BodyResponseFlow> createState() => _BodyResponseFlowState();
}

class _BodyResponseFlowState extends State<BodyResponseFlow> {
  static const int _totalSteps = 6;

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
    final l = AppLocalizations.of(context)!;
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
      // Response is now logged → cancel any pending ~3h follow-up nudge.
      if (mounted) {
        await context.read<NotificationService>().cancelBodyFollowup(widget.meal.id);
      }
      _go(_totalSteps - 1);
    } catch (e) {
      setState(() => _error = l.bodyResponse_couldNotSave(e.toString()));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Whether the user has progressed past the first question (i.e. has at
  /// least one tap of effort to lose). The thank-you page (last step) is
  /// excluded — exiting from there is the natural finish.
  bool get _hasProgress => _step > 0 && _step < _totalSteps - 1;

  /// Show a confirm-discard dialog. Returns true if user confirms they
  /// want to exit (i.e. discard).
  Future<bool> _confirmDiscard(AppLocalizations l) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.bodyResponse_discardTitle),
        content: Text(l.bodyResponse_discardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.common_cancel),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(foregroundColor: TColors.khabith),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.bodyResponse_discardConfirm),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PopScope(
      // Catch system-back / iOS swipe-back. canPop=true on the thank-you
      // page or before the user starts; otherwise we intercept and ask
      // whether to discard the in-progress answers.
      canPop: !_hasProgress,
      // Flutter 3.24 API (onPopInvokedWithResult is 3.27+).
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (await _confirmDiscard(l) && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: TColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(l),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _step = i),
                  children: [
                    _satisfactionPage(l),
                    _bloatingPage(l),
                    _energyPage(l),
                    _sleepPage(l),
                    _worthPage(l),
                    _thankYouPage(l),
                  ],
                ),
              ),
              _buildFooter(l),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l) {
    final stepIndicator = _step < _totalSteps - 1
        ? l.bodyResponse_stepIndicator(_step + 1, _totalSteps - 1)
        : l.common_done;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () async {
                  if (!_hasProgress || await _confirmDiscard(l)) {
                    if (mounted) Navigator.of(context).pop();
                  }
                },
                style: TextButton.styleFrom(foregroundColor: TColors.textSecondary),
                child: Text(l.bodyResponse_later),
              ),
              const Spacer(),
              Text(
                l.bodyResponse_title,
                style: const TextStyle(
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

  Widget _buildFooter(AppLocalizations l) {
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
              child: Text(l.common_previous),
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
              child: Text(l.common_next),
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
                  : Text(l.bodyResponse_save),
            )
          else
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(l.bodyResponse_finish),
            ),
        ],
      ),
    );
  }

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

  Widget _satisfactionPage(AppLocalizations l) {
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
          return l.bodyResponse_q1_h1;
        case 2:
          return l.bodyResponse_q1_h2;
        case 3:
          return l.bodyResponse_q1_h3;
        case 4:
          return l.bodyResponse_q1_h4;
        default:
          return l.bodyResponse_q1_h5;
      }
    }

    return _questionFrame(
      title: l.bodyResponse_q1_title,
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

  Widget _bloatingPage(AppLocalizations l) {
    String hint() {
      if (_bloating == 0) return l.bodyResponse_q2_h_comfortable;
      if (_bloating <= 2) return l.bodyResponse_q2_h_lightHeavy;
      if (_bloating == 3) return l.bodyResponse_q2_h_bloating;
      if (_bloating == 4) return l.bodyResponse_q2_h_clearHeavy;
      return l.bodyResponse_q2_h_severeHeavy;
    }

    Color color() {
      if (_bloating == 0) return TColors.primary;
      if (_bloating <= 2) return TColors.gold;
      return TColors.khabith;
    }

    return _questionFrame(
      title: l.bodyResponse_q2_title,
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
          Row(
            children: [
              Text(l.bodyResponse_q2_axisStart,
                  style: const TextStyle(
                      color: TColors.textSecondary, fontSize: 11)),
              const Spacer(),
              Text(l.bodyResponse_q2_axisEnd,
                  style: const TextStyle(
                      color: TColors.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _energyPage(AppLocalizations l) {
    String label(int v) {
      switch (v) {
        case 1:
          return l.bodyResponse_q3_l1;
        case 2:
          return l.bodyResponse_q3_l2;
        case 3:
          return l.bodyResponse_q3_l3;
        case 4:
          return l.bodyResponse_q3_l4;
        default:
          return l.bodyResponse_q3_l5;
      }
    }

    return _questionFrame(
      title: l.bodyResponse_q3_title,
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

  Widget _sleepPage(AppLocalizations l) {
    return _questionFrame(
      title: l.bodyResponse_q4_title,
      hint: l.bodyResponse_q4_hint,
      body: Column(
        children: [
          for (final option in SleepImpact.values)
            _RadioRow(
              label: sleepImpactLabel(l, option),
              selected: _sleep == option,
              onTap: () => setState(() => _sleep = option),
            ),
        ],
      ),
    );
  }

  Widget _worthPage(AppLocalizations l) {
    return _questionFrame(
      title: l.bodyResponse_q5_title,
      hint: l.bodyResponse_q5_hint,
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
                              worthRepeatingLabel(l, option),
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
              decoration: InputDecoration(
                labelText: l.bodyResponse_q5_whyOptional,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _thankYouPage(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, color: TColors.primary, size: 64),
          const SizedBox(height: 14),
          Text(l.bodyResponse_thanks_title,
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(
            l.bodyResponse_thanks_body,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
