import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/meal_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/analyze_service.dart';
import '../../services/app_messages.dart';
import '../../services/entitlement.dart';
import '../../services/health_service.dart';
import '../../services/notification_service.dart';
import '../../services/subscription_service.dart';
import '../food_bank/food_bank_screen.dart';
import '../paywall/paywall_screen.dart';
import '../../theme/theme.dart';
import '../../widgets/primary_button.dart';
import 'result_screen.dart';

/// التقاط صورة → تحليل عبر الوسيط → حفظ الوجبة → شاشة النتيجة.
/// أثناء التحليل تُعرض الصورة الملتقطة نفسها مع مؤشر تقدّم — لا شاشة فارغة.
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final AnalyzeService _analyzer = AnalyzeService();
  bool _busy = false;
  Uint8List? _preview;
  String? _error;

  /// عدد التحليلات المتبقية للمستخدم المجاني هذا الأسبوع (null = بلا حدود).
  /// الخادم هو المرجع النهائي؛ هذا لعرض العدّاد ومنع رحلة ضائعة فقط.
  int? _remaining(BuildContext context, List<DateTime> scanTimes) =>
      scansRemainingThisWeek(
        tier: context.read<SubscriptionService>().tier,
        scanTimes: scanTimes,
        now: DateTime.now(),
      );

  Future<void> _pick(ImageSource source) async {
    final l = AppLocalizations.of(context)!;
    // بوابة لطيفة: لا نرسل الطلب أصلاً إن نفد الرصيد، ونقترح بنك الطعام.
    final repo = context.read<MealRepository>();
    final aiScans = (await repo.recentAiScanTimes())
        .take(200)
        .toList(growable: false);
    if (!mounted) return;
    final left = _remaining(context, aiScans);
    if (!canScan(remaining: left)) {
      await _showExhaustedSheet();
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _preview = null;
    });
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 80,
      );
      if (!mounted) return;
      if (picked == null) {
        setState(() => _busy = false);
        return;
      }
      final Uint8List bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() => _preview = bytes);
      final result = await _analyzer.analyze(bytes);
      if (!mounted) return;
      final saved = await context
          .read<MealRepository>()
          .saveFromAnalysis(result, bytes);
      if (!mounted) return;
      // Gentle haptic confirms the save landed; bump to medium for a
      // 90+ score so the app subtly celebrates a great meal.
      if (saved.overallScore >= 90) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
      // Mirror the meal's calories into Apple Health when the user opted in.
      // Best-effort: never blocks or fails the save.
      final kcal = saved.nutrition?.caloriesKcal ?? 0;
      unawaited(context
          .read<HealthService>()
          .writeMealEnergy(kcal: kcal, at: saved.capturedAt));
      // Best-effort schedule of the ~3h "how did you feel?" reminder.
      // No-op if the feature is off or notifications aren't granted.
      unawaited(context
          .read<NotificationService>()
          .scheduleBodyFollowup(saved.id, saved.capturedAt));
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(mealId: saved.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _preview = null;
        _error = describeError(l, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PopScope(
      // Block system-back / iOS swipe-back while Gemini is mid-analysis —
      // popping leaves an orphaned in-flight request that still burns the
      // user's daily-cap quota even though they'll never see the result.
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: Text(l.capture_title)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _busy ? _analyzingView(l) : _idleView(l),
          ),
        ),
      ),
    );
  }

  Widget _analyzingView(AppLocalizations l) {
    final preview = _preview;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (preview != null)
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(TRadii.card),
                child: Image.memory(
                  preview,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(TRadii.card),
                ),
              ),
              const CircularProgressIndicator(color: Colors.white),
            ],
          )
        else
          const Center(
            child: CircularProgressIndicator(color: TColors.primary),
          ),
        const SizedBox(height: 18),
        Text(
          l.capture_analyzing,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: TColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l.capture_analyzingHint,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: TColors.textSecondary,
            fontSize: 13,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  /// تُعرض حين ينفد الرصيد الأسبوعي: لا طريق مسدود — إمّا الاشتراك أو
  /// تسجيل الوجبة من بنك الطعام (مجاني دائماً).
  Future<void> _showExhaustedSheet() async {
    final l = AppLocalizations.of(context)!;
    await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TColors.background,
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock_clock, color: TColors.gold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.gate_scansExhausted_title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 17),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l.gate_scansExhausted_body,
                style: const TextStyle(
                  color: TColors.textSecondary,
                  height: 1.6,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(ctx).pop('upgrade'),
                  icon: const Icon(Icons.workspace_premium),
                  label: Text(l.gate_upgrade),
                  style: FilledButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(ctx).pop('bank'),
                  icon: const Icon(Icons.restaurant_menu),
                  label: Text(l.gate_useFoodBank),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((choice) async {
      if (!mounted || choice == null) return;
      if (choice == 'upgrade') {
        await showPaywall(context);
      } else if (choice == 'bank') {
        if (!mounted) return;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const FoodBankScreen()),
        );
      }
    });
  }

  Widget _idleView(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 96,
          height: 96,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: TColors.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.restaurant_menu,
            size: 46,
            color: TColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l.capture_hint,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: TColors.textSecondary,
              ),
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          label: l.capture_camera,
          icon: Icons.camera_alt,
          onPressed: () => _pick(ImageSource.camera),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _pick(ImageSource.gallery),
          icon: const Icon(Icons.photo_library),
          label: Text(l.capture_gallery),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TColors.khabith.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(TRadii.control),
              border:
                  Border.all(color: TColors.khabith.withValues(alpha: 0.25)),
            ),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: TColors.khabith,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
