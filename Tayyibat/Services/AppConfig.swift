import Foundation

/// إعدادات التطبيق العامة.
enum AppConfig {
    /// عنوان الوسيط (proxy) الذي يحتفظ بمفتاح Anthropic على الخادم.
    /// - إن تُرك فارغاً: يعمل التطبيق بوضع المفتاح المباشر (يُدخله المستخدم في الإعدادات).
    /// - للنشر على App Store: ضع هنا رابط الوسيط المنشور، مثل:
    ///   "https://YOUR-SITE.netlify.app/analyze"
    static let proxyURL = ""

    /// سر مشترك اختياري يُرسَل في ترويسة x-app-token ويطابق APP_TOKEN في الخادم.
    static let appToken = ""

    /// هل التطبيق في وضع الوسيط؟ (عندها لا يحتاج المستخدم لإدخال مفتاح.)
    static var usesProxy: Bool { !proxyURL.isEmpty }
}
