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
      throw AccountException.code(
        AppMessage.accountServerUnreachable,
        detail: e.toString(),
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
          serverMsg = decoded['error'] as String;
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
  /// Server-emitted message (already in the requesting locale), optionally
  /// suffixed with the status code in the UI.
  final String? serverMessage;
  final String? statusCode;

  AccountException._({
    required AppMessage code,
    String? detail,
    this.serverMessage,
    this.statusCode,
  }) : super(code, detail: detail);

  factory AccountException.code(AppMessage code, {String? detail}) =>
      AccountException._(code: code, detail: detail);

  factory AccountException.fromServer(String serverMessage, String statusCode) =>
      AccountException._(
        code: AppMessage.accountDeleteFailedWithCode,
        detail: statusCode,
        serverMessage: serverMessage,
        statusCode: statusCode,
      );

  /// Backwards-compat — prefer [localize] from the UI layer.
  String get message => serverMessage != null
      ? '$serverMessage (${statusCode ?? ''})'
      : toString();
}
