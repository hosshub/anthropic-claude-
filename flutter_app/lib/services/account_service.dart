import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/meal_repository.dart';

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
  /// يرمي [AccountException] برسالة عربية صريحة عند أي فشل.
  Future<void> deleteAccount() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw AccountException('لا توجد جلسة مفتوحة.');
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
      throw AccountException(
        'تعذّر الوصول للخادم. تأكّد من اتصالك بالإنترنت. ($e)',
      );
    }

    if (res.statusCode == 404) {
      throw AccountException(
        'خدمة حذف الحساب غير منشورة على الخادم. أبلغ المطوّر.',
      );
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = 'فشل حذف الحساب (رمز ${res.statusCode}).';
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map && decoded['error'] is String) {
          msg = '${decoded['error']} (رمز ${res.statusCode})';
        }
      } catch (_) {}
      throw AccountException(msg);
    }

    // نظّف كل شيء محلياً ثم سجّل الخروج. لا نتعامل بفشل signOut هنا
    // لأن الجلسة الخادمية صارت لاغية بحذف الحساب.
    await _meals.deleteAll();
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {/* تجاهل: الخادم حذف المستخدم بالفعل */}
  }
}

class AccountException implements Exception {
  final String message;
  AccountException(this.message);
  @override
  String toString() => message;
}
