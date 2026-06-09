import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/analysis_result.dart';
import 'app_messages.dart';

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
      // Server message (if present) is already localized via the edge function;
      // fall back to the ARB key when it isn't.
      final serverMsg = _extractError(res.body);
      if (serverMsg != null) throw AnalyzeException.fromServer(serverMsg);
      throw AnalyzeException.code(AppMessage.analyzeDailyCapReached);
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final serverMsg = _extractError(res.body);
      if (serverMsg != null) throw AnalyzeException.fromServer(serverMsg);
      throw AnalyzeException.code(
        AppMessage.analyzeFailedWithCode,
        detail: '${res.statusCode}',
      );
    }

    final parsed = jsonDecode(res.body);
    if (parsed is! Map<String, dynamic>) {
      throw AnalyzeException.code(AppMessage.analyzeBadResponse);
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

/// Thrown by [AnalyzeService]. Carries either a localizable [AppMessage] code
/// or a passthrough server-emitted message (already localized by the proxy).
class AnalyzeException extends AppException {
  /// Raw message from the server, already localized by the edge function.
  final String? serverMessage;

  AnalyzeException._({
    required AppMessage code,
    String? detail,
    this.serverMessage,
  }) : super(code, detail: detail);

  factory AnalyzeException.code(AppMessage code, {String? detail}) =>
      AnalyzeException._(code: code, detail: detail);

  factory AnalyzeException.fromServer(String serverMessage) =>
      AnalyzeException._(
        code: AppMessage.analyzeBadResponse,
        serverMessage: serverMessage,
      );

  /// Backwards-compat accessor for any caller still reading `.message`.
  /// Prefer [localize] from the UI layer.
  String get message => serverMessage ?? toString();
}

Future<String> _currentLocale() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('app_locale') == 'en' ? 'en' : 'ar';
  } catch (_) {
    return 'ar';
  }
}
