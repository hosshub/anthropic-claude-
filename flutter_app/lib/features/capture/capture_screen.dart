import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/meal_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/analyze_service.dart';
import '../../theme/theme.dart';
import '../../widgets/primary_button.dart';
import 'result_screen.dart';

/// التقاط صورة → تحليل عبر الوسيط → حفظ الوجبة → شاشة النتيجة.
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final AnalyzeService _analyzer = AnalyzeService();
  bool _busy = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    final l = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 80,
      );
      if (picked == null) {
        setState(() => _busy = false);
        return;
      }
      final Uint8List bytes = await picked.readAsBytes();
      final result = await _analyzer.analyze(bytes);
      if (!mounted) return;
      final saved = await context
          .read<MealRepository>()
          .saveFromAnalysis(result, bytes);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(mealId: saved.id),
        ),
      );
    } on AnalyzeException catch (e) {
      setState(() {
        _busy = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _busy = false;
        _error = '${l.capture_unexpectedError}: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.capture_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_busy)
                Column(
                  children: [
                    const CircularProgressIndicator(color: TColors.primary),
                    const SizedBox(height: 14),
                    Text(
                      l.capture_analyzing,
                      style: const TextStyle(color: TColors.textSecondary),
                    ),
                  ],
                )
              else ...[
                const Icon(
                  Icons.restaurant_menu,
                  size: 60,
                  color: TColors.primary,
                ),
                const SizedBox(height: 14),
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
                    foregroundColor: TColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size.fromHeight(52),
                    side: const BorderSide(color: TColors.primary, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 18),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: TColors.khabith,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
