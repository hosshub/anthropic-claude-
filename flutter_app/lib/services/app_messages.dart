import '../l10n/generated/app_localizations.dart';

/// Every user-facing message a service may surface to the UI. Keep this in
/// lockstep with [_resolve] below and the matching ARB keys.
enum AppMessage {
  // Auth
  authSignupConfirmEmail,
  authAppleCredentialFailed,
  authAppleSignInCancelled,
  authNetworkError,
  authUnexpectedError,
  // Analyze proxy (image)
  analyzeDailyCapReached,
  analyzeFailedWithCode,
  analyzeBadResponse,
  // Suggestion proxy (text)
  suggestFailedWithCode,
  suggestBadResponse,
  // Account / server-side delete
  accountNoSession,
  accountServerUnreachable,
  accountDeleteNotDeployed,
  accountDeleteFailedWithCode,
}

/// Exception thrown by services. Carries an [AppMessage] code so the UI can
/// look up the localized string at presentation time — and an optional
/// [detail] for placeholder substitution (e.g. a status code or an error
/// message bubbled up from the server).
class AppException implements Exception {
  final AppMessage code;
  final String? detail;

  /// Message emitted by our edge function, already localized server-side and
  /// already passed through [sanitizeServerMessage] at extraction. Null when
  /// the server said nothing usable — [localize] is the fallback.
  final String? serverMessage;

  AppException(this.code, {this.detail, this.serverMessage});

  /// Resolve to a user-visible string in the current app locale.
  String localize(AppLocalizations l) => _resolve(l, code, detail);

  /// What the UI should actually render: the (sanitized) server message when
  /// present, otherwise the localized fallback for [code].
  String display(AppLocalizations l) => serverMessage ?? localize(l);

  @override
  String toString() => 'AppException($code${detail == null ? '' : ', "$detail"'})';
}

/// Pure lookup. Keep it switch-exhaustive so adding an [AppMessage] without
/// wiring an ARB key is a compile error.
String _resolve(AppLocalizations l, AppMessage m, String? detail) {
  switch (m) {
    case AppMessage.authSignupConfirmEmail:
      return l.auth_signUpEmailSent;
    case AppMessage.authAppleCredentialFailed:
      return l.auth_appleCredentialFailed;
    case AppMessage.authAppleSignInCancelled:
      return l.auth_appleSignInCancelled;
    case AppMessage.authNetworkError:
      return l.error_network;
    case AppMessage.authUnexpectedError:
      return l.error_unexpected;
    case AppMessage.analyzeDailyCapReached:
      return l.analyze_dailyCapReached;
    case AppMessage.analyzeFailedWithCode:
      return l.analyze_failedWithCode(detail ?? '?');
    case AppMessage.analyzeBadResponse:
      return l.analyze_badResponse;
    case AppMessage.suggestFailedWithCode:
      return l.suggest_failedWithCode(detail ?? '?');
    case AppMessage.suggestBadResponse:
      return l.suggest_badResponse;
    case AppMessage.accountNoSession:
      return l.error_noSession;
    case AppMessage.accountServerUnreachable:
      return l.error_couldNotReachServer(detail ?? '');
    case AppMessage.accountDeleteNotDeployed:
      return l.account_deleteNotDeployed;
    case AppMessage.accountDeleteFailedWithCode:
      return l.account_deleteFailedWithCode(detail ?? '?');
  }
}

/// Resolve a bare [AppMessage] without a thrown exception (e.g. service info
/// banners like "check your email to confirm").
String localizeAppMessage(AppLocalizations l, AppMessage m, {String? detail}) =>
    _resolve(l, m, detail);

/// Gate for error strings that arrive from our edge functions before the UI
/// renders them. Our own server messages are short, URL-free, and written for
/// end users (Arabic or English). Anything else — an upstream provider
/// message that slipped through, e.g. Gemini's "Your prepayment credits are
/// depleted. Please go to AI Studio at https://..." — must never reach the
/// screen (Apple rejected 1.0.2(5) for exactly that). Returns null when the
/// message is unsafe so callers fall back to their localized generic string.
String? sanitizeServerMessage(String? message) {
  if (message == null) return null;
  final m = message.trim();
  if (m.isEmpty || m.length > 160) return null;
  final lower = m.toLowerCase();
  if (lower.contains('http://') || lower.contains('https://')) return null;
  const providerMarkers = [
    'api key', 'apikey', 'billing', 'credit', 'quota', 'prepayment',
    'ai studio', 'gemini', 'oauth', 'token', 'project', 'console',
  ];
  for (final marker in providerMarkers) {
    if (lower.contains(marker)) return null;
  }
  return m;
}

/// One-stop mapping from any caught error to a user-presentable, localized
/// string. Screens should route every catch through this instead of
/// interpolating `e.toString()` (which renders raw English exception dumps
/// like "TimeoutException after 0:00:30..." inside a localized UI).
String describeError(AppLocalizations l, Object error) {
  if (error is AppException) return error.display(l);
  final s = error.toString().toLowerCase();
  if (s.contains('timeout') ||
      s.contains('socket') ||
      s.contains('clientexception') ||
      s.contains('connection')) {
    return l.error_network;
  }
  return l.error_unexpected;
}
