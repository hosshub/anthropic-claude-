package com.tayyibat.app.config

/** إعدادات التطبيق العامة (مطابقة لنظيرتها في تطبيق iOS). */
object AppConfig {
    /** عنوان الوسيط (proxy) الذي يحتفظ بمفتاح Anthropic على الخادم.
     *  - إن تُرك فارغاً: يعمل التطبيق بوضع المفتاح المباشر (يُدخله المستخدم في الإعدادات).
     *  - للنشر: ضع هنا رابط الوسيط المنشور (دالة Supabase Edge). */
    const val PROXY_URL = "https://cvznuwvwhnujdgfojmsb.supabase.co/functions/v1/analyze"

    /** سر مشترك اختياري يُرسَل في ترويسة x-app-token ويطابق APP_TOKEN في الخادم. */
    const val APP_TOKEN = ""

    /** هل التطبيق في وضع الوسيط؟ (عندها لا يحتاج المستخدم لإدخال مفتاح.) */
    val usesProxy: Boolean get() = PROXY_URL.isNotEmpty()

    // مصادقة Supabase
    const val SUPABASE_URL = "https://cvznuwvwhnujdgfojmsb.supabase.co"

    /** المفتاح العام (anon public). آمن لتضمينه. اتركه فارغاً لتعطيل المصادقة. */
    const val SUPABASE_ANON_KEY = "sb_publishable_LecfzCczF2tn3w_x7mtbyQ_Ug-Dee-X"

    /** زر "المتابعة عبر Google" يستخدم تدفّق OAuth عبر المتصفح + PKCE. */
    const val AUTH_REDIRECT_SCHEME = "tayyibat"
    const val AUTH_REDIRECT_URL = "tayyibat://login-callback"

    /** تُفعَّل المصادقة تلقائياً بمجرد وضع المفتاح العام. */
    val authEnabled: Boolean get() = SUPABASE_ANON_KEY.isNotEmpty()
}
