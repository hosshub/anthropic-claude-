import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import '../models/meal.dart';

class AnalyzeException implements Exception {
  final String message;
  AnalyzeException(this.message);
  @override
  String toString() => message;
}

/// Client for the server-side multimodal AI proxy (`analyze` edge function).
///
/// The image is sent to our backend, which calls the AI provider with keys that
/// never touch the device, applies the safety preamble (no diagnosis/treatment),
/// scores the meal against the user's active plan, and enforces the free-tier
/// daily scan cap with refund-on-failure. See docs/PRD.md §8 + backend/.
class AnalyzeService {
  Future<MealAnalysis> analyze(
    Uint8List imageBytes, {
    String? planId,
  }) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) throw AnalyzeException('لا توجد جلسة مفتوحة.');

    http.Response res;
    try {
      res = await http
          .post(
            Uri.parse(AppConfig.analyzeUrl),
            headers: {
              'authorization': 'Bearer ${session.accessToken}',
              'apikey': AppConfig.supabaseAnonKey,
              'content-type': 'application/json',
            },
            body: jsonEncode({
              'task': 'analyze',
              'image_base64': base64Encode(imageBytes),
              'media_type': 'image/jpeg',
              if (planId != null) 'plan_id': planId,
            }),
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw AnalyzeException('تعذّر الوصول للخادم. تأكّد من اتصالك. ($e)');
    }

    if (res.statusCode == 429) {
      throw AnalyzeException('وصلت للحد اليومي من التحليلات في الباقة المجانية.');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = 'فشل التحليل (رمز ${res.statusCode}).';
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map && decoded['error'] is String) {
          msg = decoded['error'] as String;
        }
      } catch (_) {}
      throw AnalyzeException(msg);
    }

    try {
      return MealAnalysis.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>,
      );
    } catch (e) {
      throw AnalyzeException('تعذّر قراءة نتيجة التحليل. ($e)');
    }
  }
}
