import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/meal_repository.dart';
import 'app_messages.dart';

/// عنوان دالة حذف الحساب (مطابق للنسخة المنشورة على Supabase).
const String _deleteAccountUrl =
    'https://cvznuwvwhnujdgfojmsb.supabase.co/functions/v1/delete-account';

/// عنوان مفتاح Supabase العام — يلزم لتمرير apikey لدوال Edge المعطّلة JWT.
const String _supabaseAnonKey =
    'sb_publishable_LecfzCczF2tn3w_x7mtbyQ_Ug-Dee-X';

class AccountService {
  final MealRepository _meals;
  AccountService(this._meals);

  /// يحذف حساب المستخدم من Supabase ثم يمسح كل البيانات المحلية.
  /// يرمي [AccountException] بكود قابل للترجمة عند أي فشل.
  Future<void> deleteAccount() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw AccountException.code(AppMessage.accountNoSession);
    }

    http.Response res;
    try {
      res = await http.post(
        Uri.parse(_deleteAccountUrl),
        headers: {
          'authorization': 'Bearer ${session.accessToken}',
          'apikey': _supabaseAnonKey,
          'content-type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
    } catch (e) {
      // Keep the parenthesised detail short and technical-looking ("timeout",
      // "offline") — e.toString() dumps a full English exception description
      // into the middle of a localized sentence.
      final kind = e.toString().toLowerCase();
      final detail = kind.contains('timeout')
          ? 'timeout'
          : kind.contains('socket')
              ? 'offline'
              : 'network';
      throw AccountException.code(
        AppMessage.accountServerUnreachable,
        detail: detail,
      );
    }

    if (res.statusCode == 404) {
      throw AccountException.code(AppMessage.accountDeleteNotDeployed);
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      String? serverMsg;
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map && decoded['error'] is String) {
          serverMsg = sanitizeServerMessage(decoded['error'] as String);
        }
      } catch (_) {}
      if (serverMsg != null) {
        throw AccountException.fromServer(serverMsg, '${res.statusCode}');
      }
      throw AccountException.code(
        AppMessage.accountDeleteFailedWithCode,
        detail: '${res.statusCode}',
      );
    }

    // نظّف كل شيء محلياً ثم سجّل الخروج. لا نتعامل بفشل signOut هنا
    // لأن الجلسة الخادمية صارت لاغية بحذف الحساب.
    await _meals.deleteAll();
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {/* تجاهل: الخادم حذف المستخدم بالفعل */}
  }
}

class AccountException extends AppException {
  /// HTTP status the delete call failed with, shown as a suffix in Settings.
  final String? statusCode;

  AccountException.code(super.code, {super.detail}) : statusCode = null;

  AccountException.fromServer(String serverMessage, String status)
      : statusCode = status,
        super(
          AppMessage.accountDeleteFailedWithCode,
          detail: status,
          serverMessage: serverMessage,
        );
}
