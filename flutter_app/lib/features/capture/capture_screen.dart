import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/analyze_service.dart';
import '../../theme/theme.dart';
import '../../widgets/primary_button.dart';
import 'result_screen.dart';

/// التقاط صورة (كاميرا أو معرض) ثم استدعاء دالة التحليل.
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: result, imageBytes: bytes),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_busy)
                const Column(
                  children: [
                    CircularProgressIndicator(color: TColors.primary),
                    SizedBox(height: 14),
                    Text(
                      'جارٍ تحليل الوجبة…',
                      style: TextStyle(color: TColors.textSecondary),
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
                  'صوّر وجبتك أو اختر صورة من المعرض، وسنحلّلها فوراً.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: TColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'التقط بالكاميرا',
                  icon: Icons.camera_alt,
                  onPressed: () => _pick(ImageSource.camera),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('اختر من المعرض'),
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
