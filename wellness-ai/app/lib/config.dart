/// App-wide configuration constants.
///
/// SECURITY: only the Supabase URL and the **publishable (anon)** key belong
/// here. Server-side secrets (AI provider key, service-role key) live only in
/// Supabase Function secrets — never in the app. See docs/BRD.md §13.
class AppConfig {
  // Fill these from your Supabase project (Settings → API).
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR-PROJECT.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_PUBLISHABLE_ANON_KEY',
  );

  /// OAuth redirect — register in Supabase → Auth → URL Configuration.
  static const String oauthRedirect = 'wellnessai://login-callback';

  /// Edge function endpoints.
  static String get analyzeUrl => '$supabaseUrl/functions/v1/analyze';
  static String get providerLinkUrl => '$supabaseUrl/functions/v1/provider-link';
  static String get deleteAccountUrl =>
      '$supabaseUrl/functions/v1/delete-account';

  /// Enable after Apple Developer setup + Supabase Apple provider config.
  /// Required by App Store Guideline 4.8 once Google sign-in is offered.
  static const bool appleSignInEnabled = false;

  /// Free-tier daily AI meal-scan cap (server-enforced; mirrored here for UI).
  static const int freeDailyScanCap = 3;
}
