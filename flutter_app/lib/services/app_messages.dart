import '../l10n/generated/app_localizations.dart';

/// Every user-facing message a service may surface to the UI. Keep this in
/// lockstep with [_resolve] below and the matching ARB keys.
enum AppMessage {
  // Auth
  authSignupConfirmEmail,
  authAppleCredentialFailed,
  authAppleSignInCancelled,
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
  final AppMessage message;
  final String? detail;

  AppException(this.message, {this.detail});

  /// Resolve to a user-visible string in the current app locale.
  String localize(AppLocalizations l) => _resolve(l, message, detail);

  @override
  String toString() => 'AppException($message${detail == null ? '' : ', "$detail"'})';
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
