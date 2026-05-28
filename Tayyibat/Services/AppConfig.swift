import Foundation

/// إعدادات التطبيق العامة.
enum AppConfig {
    /// عنوان الوسيط (proxy) الذي يحتفظ بمفتاح Anthropic على الخادم.
    /// - إن تُرك فارغاً: يعمل التطبيق بوضع المفتاح المباشر (يُدخله المستخدم في الإعدادات).
    /// - للنشر على App Store: ضع هنا رابط الوسيط المنشور (دالة Supabase Edge).
    static let proxyURL = "https://cvznuwvwhnujdgfojmsb.supabase.co/functions/v1/analyze"

    /// سر مشترك اختياري يُرسَل في ترويسة x-app-token ويطابق APP_TOKEN في الخادم.
    static let appToken = ""

    /// هل التطبيق في وضع الوسيط؟ (عندها لا يحتاج المستخدم لإدخال مفتاح.)
    static var usesProxy: Bool { !proxyURL.isEmpty }

    // MARK: - مصادقة Supabase

    /// عنوان مشروع Supabase (بدون مسار).
    static let supabaseURL = "https://cvznuwvwhnujdgfojmsb.supabase.co"

    /// المفتاح العام (anon public) من: Supabase ← Project Settings ← API.
    /// آمن لتضمينه في التطبيق. اتركه فارغاً لتعطيل المصادقة (يعمل التطبيق كما هو بلا تسجيل دخول).
    static let supabaseAnonKey = ""

    /// فعّل زر "المتابعة عبر Apple" بعد:
    /// 1) تفعيل قدرة Sign in with Apple في Xcode (تتطلب عضوية Apple Developer)،
    /// 2) ضبط مزوّد Apple في Supabase ← Authentication ← Providers.
    static let appleSignInEnabled = false

    /// مخطط/رابط إعادة التوجيه لتدفّق OAuth.
    /// أضِف `authRedirectURL` في: Supabase ← Authentication ← URL Configuration ← Redirect URLs.
    static let authRedirectScheme = "tayyibat"
    static let authRedirectURL = "tayyibat://login-callback"

    /// تُفعَّل المصادقة تلقائياً بمجرد وضع المفتاح العام أعلاه.
    static var authEnabled: Bool { !supabaseAnonKey.isEmpty }
}
