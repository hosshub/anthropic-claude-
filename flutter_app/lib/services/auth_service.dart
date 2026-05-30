import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// خدمة المصادقة فوق supabase_flutter. تعمل كـ ChangeNotifier حتى تُعيد الواجهات
/// رسم نفسها عند تغيّر الجلسة (تسجيل دخول/خروج، تأكيد بريد… إلخ).
class AuthService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  late final StreamSubscription<AuthState> _sub;

  bool _restoring = true;
  bool _busy = false;
  String? _error;
  String? _info;

  AuthService() {
    _sub = _client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
    // supabase_flutter يستعيد الجلسة من التخزين الآمن تلقائياً عند بدء التشغيل.
    _restoring = false;
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  bool get isRestoring => _restoring;
  bool get isBusy => _busy;
  bool get isAuthenticated => _client.auth.currentSession != null;
  String? get email => _client.auth.currentUser?.email;
  String? get error => _error;
  String? get info => _info;

  Future<bool> signIn({required String email, required String password}) async {
    _start();
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _finish();
      return true;
    } on AuthException catch (e) {
      _fail(e.message);
      return false;
    } catch (e) {
      _fail(e.toString());
      return false;
    }
  }

  Future<bool> signUp({required String email, required String password}) async {
    _start();
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
      );
      if (res.session == null) {
        // التأكيد عبر البريد مُفعّل في Supabase.
        _info = 'أنشأنا حسابك. تحقّق من بريدك لتأكيد الحساب، ثم سجّل الدخول.';
      }
      _finish();
      return true;
    } on AuthException catch (e) {
      _fail(e.message);
      return false;
    } catch (e) {
      _fail(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      // نمضي قُدُماً بحذف الجلسة محلياً حتى لو فشلت دعوة الخادم.
    }
    notifyListeners();
  }

  void clearMessages() {
    _error = null;
    _info = null;
    notifyListeners();
  }

  void _start() {
    _busy = true;
    _error = null;
    _info = null;
    notifyListeners();
  }

  void _finish() {
    _busy = false;
    notifyListeners();
  }

  void _fail(String message) {
    _busy = false;
    _error = message;
    notifyListeners();
  }
}
