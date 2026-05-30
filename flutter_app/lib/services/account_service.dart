import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/meal_repository.dart';

/// عنوان دالة حذف الحساب (مطابق للنسخة المنشورة على Supabase).
const String _deleteAccountUrl =
    'https://cvznuwvwhnujdgfojmsb.supabase.co/functions/v1/delete-account';

class AccountService {
  final MealRepository _meals;
  AccountService(this._meals);

  /// يحذف حساب المستخدم من Supabase ثم يمسح كل البيانات المحلية.
  Future<void> deleteAccount() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw AccountException('لا توجد جلسة مفتوحة.');
    }

    final res = await http.post(
      Uri.parse(_deleteAccountUrl),
      headers: {
        'authorization': 'Bearer ${session.accessToken}',
        'content-type': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = 'تعذّر حذف الحساب (${res.statusCode}).';
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map && decoded['error'] is String) {
          msg = decoded['error'] as String;
        }
      } catch (_) {}
      throw AccountException(msg);
    }

    // نظّف كل شيء محلياً ثم سجّل الخروج.
    await _meals.deleteAll();
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {/* الخادم حذف المستخدم بالفعل، تجاهل */}
  }
}

class AccountException implements Exception {
  final String message;
  AccountException(this.message);
  @override
  String toString() => message;
}
