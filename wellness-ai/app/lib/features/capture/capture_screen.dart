import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/analyze_service.dart';
import '../../theme/theme.dart';

/// Capture → server-side AI analysis → (TODO) save + result.
/// Implements the start of EPIC C2 (docs/PRD.md §6).
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final _picker = ImagePicker();
  final _analyzer = AnalyzeService();
  bool _busy = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
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
      final bytes = await picked.readAsBytes();
      final result = await _analyzer.analyze(bytes);
      if (!mounted) return;
      // TODO: persist meal + navigate to a ResultScreen showing items, the
      //       plan-fit score, and an edit/correct flow (EPIC C2 / FR-C2.3).
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('النتيجة: ${result.overallScore}% — ${result.scoreLabelAr}')),
      );
      setState(() => _busy = false);
    } on AnalyzeException catch (e) {
      setState(() {
        _busy = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _busy = false;
        _error = 'حدث خطأ غير متوقع: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تحليل وجبة')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_busy) ...[
                const Center(
                    child: CircularProgressIndicator(color: WColors.primary)),
                const SizedBox(height: 14),
                const Text('جارٍ تحليل الوجبة…',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: WColors.textSecondary)),
              ] else ...[
                const Icon(Icons.restaurant_menu,
                    size: 60, color: WColors.primary),
                const SizedBox(height: 14),
                const Text('صوّر وجبتك أو اختر صورة، وسنحلّلها فوراً.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: WColors.textSecondary)),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () => _pick(ImageSource.camera),
                  style: FilledButton.styleFrom(
                    backgroundColor: WColors.primary,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('التقط بالكاميرا'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('اختر من المعرض'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: WColors.primary,
                    minimumSize: const Size.fromHeight(52),
                    side: const BorderSide(color: WColors.primary),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 18),
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: WColors.zoneRed)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
