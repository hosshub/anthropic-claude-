/// ثوابت مشتركة (تطابق AppConfig.swift / AppConfig.kt).
class AppConfig {
  static const String supabaseUrl =
      'https://cvznuwvwhnujdgfojmsb.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_LecfzCczF2tn3w_x7mtbyQ_Ug-Dee-X';

  /// رابط إعادة التوجيه لتدفّق OAuth — لا بد من إضافته في:
  /// Supabase ← Authentication ← URL Configuration ← Redirect URLs.
  static const String oauthRedirect = 'tayyibat://login-callback';

  /// تشغيل تسجيل Apple. مفعّل بعد:
  /// 1) معرّف الحزمة `ai.tayyibat.tayyibat` مسجّل في Apple Developer + قدرة
  ///    Sign in with Apple مفعّلة عليه.
  /// 2) Services ID `ai.tayyibat.web-signin` مسجّل + Apple Key (.p8) منشأ.
  /// 3) Supabase ← Authentication ← Providers ← Apple مفعّل بكلا المعرّفين
  ///    وبسرّ JWT مولّد من المفتاح.
  static const bool appleSignInEnabled = true;
}
