import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';

/// Auth over supabase_flutter. ChangeNotifier so views rebuild on session
/// changes. Mirrors the Tayyibat pattern (email + Google OAuth + Apple).
class AuthService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  late final StreamSubscription<AuthState> _sub;

  bool _restoring = true;
  bool _busy = false;
  String? _error;
  String? _info;

  AuthService() {
    _sub = _client.auth.onAuthStateChange.listen((_) {
      _busy = false;
      notifyListeners();
    });
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

  Future<bool> signIn({required String email, required String password}) =>
      _guard(() => _client.auth.signInWithPassword(
            email: email,
            password: password,
          ));

  Future<bool> signUp({required String email, required String password}) async {
    _start();
    try {
      final res = await _client.auth.signUp(email: email, password: password);
      if (res.session == null) {
        _info = 'أنشأنا حسابك. تحقّق من بريدك لتأكيد الحساب ثم سجّل الدخول.';
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

  /// Opens the system browser for Google OAuth. main.dart catches the returning
  /// wellnessai://login-callback link.
  Future<bool> signInWithGoogle() async {
    _start();
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: AppConfig.oauthRedirect,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      return true; // onAuthStateChange clears _busy after the link returns
    } on AuthException catch (e) {
      _fail(e.message);
      return false;
    } catch (e) {
      _fail(e.toString());
      return false;
    }
  }

  // TODO: signInWithApple() — port from Tayyibat once Apple Developer + the
  // Supabase Apple provider are configured (see AppConfig.appleSignInEnabled).

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {}
    notifyListeners();
  }

  void clearMessages() {
    _error = null;
    _info = null;
    notifyListeners();
  }

  // --- helpers ---
  Future<bool> _guard(Future<void> Function() op) async {
    _start();
    try {
      await op();
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
