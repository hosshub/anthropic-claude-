import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/analysis_result.dart';

/// نفس عنوان دالة Supabase المستخدم في نسخة SwiftUI.
const String _proxyUrl =
    'https://cvznuwvwhnujdgfojmsb.supabase.co/functions/v1/analyze';

/// خدمة التحليل: ترسل صورة base64 للوسيط وتُعيد AnalysisResult.
class AnalyzeService {
  final http.Client _http;

  AnalyzeService({http.Client? client}) : _http = client ?? http.Client();

  Future<AnalysisResult> analyze(Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);
    final session = Supabase.instance.client.auth.currentSession;
    final locale = await _currentLocale();

    final headers = <String, String>{
      'content-type': 'application/json',
      if (session != null) 'authorization': 'Bearer ${session.accessToken}',
    };

    final body = jsonEncode({
      'image_base64': base64Image,
      'media_type': 'image/jpeg',
      'locale': locale,
    });

    final res = await _http
        .post(Uri.parse(_proxyUrl), headers: headers, body: body)
        .timeout(const Duration(seconds: 60));

    if (res.statusCode == 429) {
      throw AnalyzeException(
        _extractError(res.body) ?? 'بلغت الحد اليومي للتحليلات.',
      );
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = _extractError(res.body) ??
          'تعذّر التحليل (${res.statusCode}).';
      throw AnalyzeException(msg);
    }

    final parsed = jsonDecode(res.body);
    if (parsed is! Map<String, dynamic>) {
      throw AnalyzeException('استجابة غير متوقعة من الوسيط.');
    }
    return AnalysisResult.fromJson(parsed);
  }

  String? _extractError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final err = decoded['error'];
        if (err is String) return err;
        if (err is Map && err['message'] is String) {
          return err['message'] as String;
        }
      }
    } catch (_) {/* غير قابل للقراءة كـ JSON */}
    return null;
  }
}

class AnalyzeException implements Exception {
  final String message;
  AnalyzeException(this.message);
  @override
  String toString() => message;
}

Future<String> _currentLocale() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('app_locale') == 'en' ? 'en' : 'ar';
  } catch (_) {
    return 'ar';
  }
}
