/// ثوابت مشتركة (تطابق AppConfig.swift / AppConfig.kt).
class AppConfig {
  static const String supabaseUrl =
      'https://cvznuwvwhnujdgfojmsb.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_LecfzCczF2tn3w_x7mtbyQ_Ug-Dee-X';

  /// رابط إعادة التوجيه لتدفّق OAuth — لا بد من إضافته في:
  /// Supabase ← Authentication ← URL Configuration ← Redirect URLs.
  static const String oauthRedirect = 'tayyibat://login-callback';

  /// فعّل بعد:
  /// 1) عضوية Apple Developer + قدرة Sign in with Apple على App ID.
  /// 2) ضبط مزوّد Apple في Supabase ← Authentication ← Providers ← Apple
  ///    (في حقل Client IDs أضف معرّف الحزمة `ai.tayyibat.tayyibat`).
  static const bool appleSignInEnabled = false;
}
