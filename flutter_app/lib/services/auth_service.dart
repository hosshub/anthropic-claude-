import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';

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
    _sub = _client.auth.onAuthStateChange.listen((state) {
      // أي تغيير في الجلسة (signedIn, signedOut, …) ينهي حالة العمل ويُحدّث الواجهات.
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

  // ---------------------------------------------------------------------------
  // البريد وكلمة المرور
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Google (تدفّق متصفح + رابط عائد)
  // ---------------------------------------------------------------------------

  /// يفتح متصفّحاً داخل التطبيق (SFSafariViewController على iOS،
  /// Chrome Custom Tabs على Android) فيُسجّل المستخدم دخوله في Google ثم
  /// يُغلق نفسه تلقائياً عند إعادة التوجيه إلى `tayyibat://login-callback`
  /// لأن iOS/Android يلتقطان مخطّط tayyibat الذي سجّلناه. ذلك يُعيد التطبيق
  /// للواجهة بسلاسة، فيلتقط main.dart الرابط ويُسلّمه إلى getSessionFromUrl.
  Future<bool> signInWithGoogle() async {
    _start();
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: AppConfig.oauthRedirect,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      // لا ننهي _busy هنا — onAuthStateChange سيفعل ذلك بعد عودة الرابط.
      return true;
    } on AuthException catch (e) {
      _fail(e.message);
      return false;
    } catch (e) {
      _fail(e.toString());
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Apple (أصلي على iOS — يتطلب عضوية Apple Developer)
  // ---------------------------------------------------------------------------

  /// يستخدم Sign in with Apple الأصلي ثم يبادل id_token مع Supabase.
  /// يعمل فقط بعد تفعيل قدرة Sign in with Apple وضبط مزوّد Apple في Supabase.
  Future<bool> signInWithApple() async {
    _start();
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        _fail('تعذّر الحصول على بيانات Apple.');
        return false;
      }

      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
      _finish();
      return true;
    } on SignInWithAppleAuthorizationException catch (e) {
      _fail(e.message.isEmpty ? 'أُلغي تسجيل الدخول.' : e.message);
      return false;
    } on AuthException catch (e) {
      _fail(e.message);
      return false;
    } catch (e) {
      _fail(e.toString());
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // تسجيل الخروج
  // ---------------------------------------------------------------------------

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {/* نمضي قُدُماً بحذف الجلسة محلياً حتى لو فشلت دعوة الخادم. */}
    notifyListeners();
  }

  void clearMessages() {
    _error = null;
    _info = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // داخلية
  // ---------------------------------------------------------------------------

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

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  static String _sha256(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
