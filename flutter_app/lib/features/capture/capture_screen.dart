import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/meal_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/analyze_service.dart';
import '../../services/app_messages.dart';
import '../../services/health_service.dart';
import '../../services/notification_service.dart';
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

  Future<void> _pick(ImageSource source) async {
    final l = AppLocalizations.of(context)!;
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
