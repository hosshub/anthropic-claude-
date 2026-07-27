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

  /// يسمح بتجاوز مستوى الاشتراك يدوياً من الإعدادات (للاختبار فقط).
  ///
  /// بوابة وقت-ترجمة لا وقت-تشغيل: بناء الإنتاج يُنتَج بلا هذا العَلَم فلا
  /// يوجد فيه المسار أصلاً. نستعمل dart-define لا kDebugMode لأن الاختبار على
  /// الجهاز يجري على بناء release حيث kDebugMode = false.
  ///
  ///   flutter build ios --release --dart-define=DEBUG_TIER_OVERRIDE=true
  static const bool tierOverrideAllowed =
      bool.fromEnvironment('DEBUG_TIER_OVERRIDE');

  /// مفتاح RevenueCat العام. آمن للالتزام في المستودع مثل مفتاح Supabase
  /// المنشور: مفاتيح SDK العامة تُشحن داخل كل نسخة من التطبيق ويمكن لأي أحد
  /// استخراجها، وهي لا تمنح إلا ما يمنحه التطبيق نفسه. الأسرار الحقيقية
  /// (خطّاف RevenueCat، مفتاح الخدمة) تبقى في أسرار Supabase.
  ///
  /// ⚠️ القيمة الافتراضية مفتاح **متجر اختباري** (بادئة test_) — يصلح للتجربة
  /// فقط ولا يجري مشتريات حقيقية. قبل النشر مرّر مفتاح المنصّة الحقيقي:
  ///   flutter build ipa --dart-define=REVENUECAT_KEY=appl_xxxxxxxx
  static const String revenueCatApiKey = String.fromEnvironment(
    'REVENUECAT_KEY',
    defaultValue: 'test_wlFYlUCCChXvOXzsSUwitOdcWLt',
  );

  /// Sentry DSN — supplied at build time via:
  ///   flutter run --dart-define=SENTRY_DSN=https://...@o....ingest.de.sentry.io/...
  /// Empty by default so unconfigured builds don't try to send anything.
  /// Create the project at https://sentry.io (choose the EU region).
  static const String sentryDsn =
      String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  static bool get crashReportingEnabled => sentryDsn.isNotEmpty;
}
