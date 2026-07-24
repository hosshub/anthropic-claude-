import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/suggestion.dart';
import 'app_messages.dart';

/// نفس عنوان الوسيط — الفرق فقط في حمولة الطلب (task vs image_base64).
const String _proxyUrl =
    'https://cvznuwvwhnujdgfojmsb.supabase.co/functions/v1/analyze';

class SuggestionService {
  final http.Client _http;
  SuggestionService({http.Client? client}) : _http = client ?? http.Client();

  /// v1.2: ثلاث وجبات مقترحة دفعة واحدة. يقبل أيضاً رد الخادم القديم
  /// (كائن واحد) فيغلّفه في قائمة من عنصر واحد.
  Future<List<MealSuggestion>> suggestMeals() async {
    final body = await _postTask('suggest', const Duration(seconds: 45));
    final list = MealSuggestion.listFromJson(body);
    if (list.isEmpty) {
      throw SuggestionException.code(AppMessage.suggestBadResponse);
    }
    return list;
  }

  Future<WeeklyPlan> generateWeeklyPlan() async {
    final body = await _postTask('plan', const Duration(seconds: 60));
    return WeeklyPlan.fromJson(body);
  }

  Future<Map<String, dynamic>> _postTask(String task, Duration timeout) async {
    final session = Supabase.instance.client.auth.currentSession;
    final locale = await _currentLocale();
    final headers = <String, String>{
      'content-type': 'application/json',
      if (session != null) 'authorization': 'Bearer ${session.accessToken}',
    };

    final res = await _http
        .post(
          Uri.parse(_proxyUrl),
          headers: headers,
          body: jsonEncode({'task': task, 'locale': locale}),
        )
        .timeout(timeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final serverMsg = _extractError(res.body);
      if (serverMsg != null) throw SuggestionException.fromServer(serverMsg);
      throw SuggestionException.code(
        AppMessage.suggestFailedWithCode,
        detail: '${res.statusCode}',
      );
    }

    final parsed = jsonDecode(res.body);
    if (parsed is! Map<String, dynamic>) {
      throw SuggestionException.code(AppMessage.suggestBadResponse);
    }
    return parsed;
  }

  String? _extractError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final err = decoded['error'];
        if (err is String) return sanitizeServerMessage(err);
        if (err is Map && err['message'] is String) {
          return sanitizeServerMessage(err['message'] as String);
        }
      }
    } catch (_) {/* ليس JSON */}
    return null;
  }
}

class SuggestionException extends AppException {
  SuggestionException.code(super.code, {super.detail});

  SuggestionException.fromServer(String serverMessage)
      : super(AppMessage.suggestBadResponse, serverMessage: serverMessage);
}

Future<String> _currentLocale() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('app_locale') == 'en' ? 'en' : 'ar';
  } catch (_) {
    return 'ar';
  }
}
