import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import 'app_messages.dart';

/// خدمة المصادقة فوق supabase_flutter. تعمل كـ ChangeNotifier حتى تُعيد الواجهات
/// رسم نفسها عند تغيّر الجلسة (تسجيل دخول/خروج، تأكيد بريد… إلخ).
class AuthService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  late final StreamSubscription<AuthState> _sub;

  bool _restoring = true;
  bool _busy = false;
  // Platform-emitted errors stay as raw strings (Supabase / Apple have their
  // own language). App-owned info and error messages flow through [_infoCode]
  // and [_errorCode] so the UI can localize at presentation time.
  String? _platformError;
  AppMessage? _errorCode;
  AppMessage? _infoCode;

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

  /// Raw error message from the platform (Supabase / Apple). Not localized by us.
  String? get platformError => _platformError;

  /// App-owned error code (translatable). Resolve via [AppException.localize].
  AppMessage? get errorCode => _errorCode;
  AppMessage? get infoCode => _infoCode;

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
      _failWithAuthException(e);
      return false;
    } catch (e) {
      _failWithCode(_classifyUnexpected(e));
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
        _infoCode = AppMessage.authSignupConfirmEmail;
      }
      _finish();
      return true;
    } on AuthException catch (e) {
      _failWithAuthException(e);
      return false;
    } catch (e) {
      _failWithCode(_classifyUnexpected(e));
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
      _failWithAuthException(e);
      return false;
    } catch (e) {
      _failWithCode(_classifyUnexpected(e));
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
        _failWithCode(AppMessage.authAppleCredentialFailed);
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
      if (e.message.isEmpty) {
        _failWithCode(AppMessage.authAppleSignInCancelled);
      } else {
        _fail(e.message);
      }
      return false;
    } on AuthException catch (e) {
      _failWithAuthException(e);
      return false;
    } catch (e) {
      _failWithCode(_classifyUnexpected(e));
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
    _platformError = null;
    _errorCode = null;
    _infoCode = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // داخلية
  // ---------------------------------------------------------------------------

  void _start() {
    _busy = true;
    _platformError = null;
    _errorCode = null;
    _infoCode = null;
    notifyListeners();
  }

  void _finish() {
    _busy = false;
    notifyListeners();
  }

  void _fail(String message) {
    _busy = false;
    _platformError = message;
    notifyListeners();
  }

  /// Surfaces an [AuthException] safely: transport noise becomes a localized
  /// network message; genuine auth errors keep their (actionable) text.
  void _failWithAuthException(AuthException e) {
    final code = codeForAuthExceptionMessage(e.message);
    if (code != null) {
      _failWithCode(code);
    } else {
      _fail(e.message);
    }
  }

  /// Map a non-Auth exception (network drop, timeout, anything else) to a
  /// localizable code — never surface raw Dart exception text to the UI.
  static AppMessage _classifyUnexpected(Object e) =>
      _classifyMessage(e.toString()) ?? AppMessage.authUnexpectedError;

  /// Classifies an [AuthException] message.
  ///
  /// Supabase reports transport failures as `AuthRetryableFetchException`,
  /// which **extends AuthException** and carries the raw Dart text as its
  /// message (gotrue `fetch.dart`: `message: error.toString()`). Since our
  /// catch order handles `AuthException` before the generic `catch`, that raw
  /// text would otherwise reach the user — e.g. "ClientException with
  /// SocketException: Failed host lookup…" when the project is paused.
  ///
  /// Returns a localizable code when the message is transport noise (hide it),
  /// or null when it is a genuine, actionable auth error (show it as-is —
  /// "Invalid login credentials" is useful to the user).
  static AppMessage? codeForAuthExceptionMessage(String message) {
    if (message.trim().isEmpty) return AppMessage.authUnexpectedError;
    return _classifyMessage(message);
  }

  /// Shared transport-noise detector. Null means "not transport noise".
  static AppMessage? _classifyMessage(String message) {
    final s = message.toLowerCase();
    const markers = [
      'timeout',
      'socket',
      'connection',
      'clientexception',
      'failed host lookup',
      'network is unreachable',
      'nodename nor servname',
      'connection refused',
      'connection reset',
      'handshake',
      'os error',
    ];
    for (final m in markers) {
      if (s.contains(m)) return AppMessage.authNetworkError;
    }
    return null;
  }

  void _failWithCode(AppMessage code) {
    _busy = false;
    _errorCode = code;
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
