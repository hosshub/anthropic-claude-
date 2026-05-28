# الطيبات — وسيط التحليل على Supabase (Edge Function)

دالة **Supabase Edge Function** باسم `analyze` تحتفظ بمفتاح **Anthropic** كسرٍّ على
Supabase، فيرسل التطبيق الصورة إليها بدل استدعاء `api.anthropic.com` مباشرةً.
HTTPS جاهز تلقائياً، بلا خادم ولا DNS ولا Passenger.

```
التطبيق ──(صورة base64)──▶ https://<ref>.supabase.co/functions/v1/analyze ──(+المفتاح)──▶ Anthropic ──▶ JSON
```

النقاط: `GET` ⇒ `{"ok":true}` (فحص)، و`POST` بجسم
`{"image_base64":"...","media_type":"image/jpeg"}` ⇒ نتيجة JSON.

الكود كله في ملف واحد: `functions/analyze/index.ts` (القواعد مضمّنة بداخله).

---

## الطريقة (أ): لوحة تحكم Supabase — موصى بها (بلا طرفية)
1. أنشئ مشروعاً على https://supabase.com (سجّل الدخول → New project). احفظ **Project Ref**
   (الموجود في الرابط/الإعدادات، مثل `abcd1234efgh`).
2. من القائمة → **Edge Functions** → **Create a function** → الاسم: `analyze`.
3. الصق كامل محتوى `functions/analyze/index.ts` في المحرّر → **Deploy**.
4. **السرّ:** Project Settings → **Edge Functions** (أو Functions → Secrets) → أضف:
   - `ANTHROPIC_API_KEY` = مفتاحك الجديد من console.anthropic.com
   - (اختياري) `APP_TOKEN` = سلسلة سرّية.
5. **عطّل التحقق من JWT** لهذه الدالة: في إعدادات الدالة، أوقف **Verify JWT**
   (حتى يستطيع التطبيق استدعاءها مباشرةً بلا توكن Supabase).
6. انسخ **Function URL**: `https://<ref>.supabase.co/functions/v1/analyze`.
7. افتح الرابط في المتصفح (GET) → يجب أن يردّ `{"ok":true}`.

## الطريقة (ب): سطر الأوامر
```bash
# على جهازك (إنترنت مفتوح)
npm i -g supabase            # أو brew install supabase/tap/supabase
supabase login               # يفتح المتصفح
cd ~/anthropic-claude-
supabase link --project-ref <ref>
supabase secrets set ANTHROPIC_API_KEY=sk-ant-...   # و APP_TOKEN اختياري
supabase functions deploy analyze --no-verify-jwt
```

---

## ربط التطبيق
بعد الحصول على **Project Ref**، يُضبط في `Tayyibat/Services/AppConfig.swift`:
```swift
static let proxyURL = "https://<ref>.supabase.co/functions/v1/analyze"
```
(أرسل لي الـ ref وسأحدّثه وأدفعه.) بعدها أعد بناء التطبيق فيعمل التحليل بلا مفتاح من المستخدم.

## ملاحظات
- بعد نجاح كل شيء، **دوّر مفتاح Anthropic** (لأنه ظهر سابقاً في لقطات الشاشة) وحدّث السرّ.
- صفحة الموقع تبقى على cPanel (`tayyibat.ai`)؛ Supabase تستضيف الـ API فقط.
- لم نعد بحاجة لتطبيق Python على cPanel ولا لسجل `api.tayyibat.ai` (يمكن حذفهما).

---

# تسجيل الدخول (Supabase Auth) — Google و Apple

أُضيفت مصادقة كاملة للتطبيق عبر Supabase (بلا أي مكتبة خارجية). تبقى **معطّلة**
حتى تضع المفتاح العام، فلا تكسر البناء الحالي.

## ما عليك فعله (مرة واحدة)

### 1) المفتاح العام في التطبيق
Supabase ← **Project Settings ← API** ← انسخ **anon public** key، ثم ضعه في
`Tayyibat/Services/AppConfig.swift`:
```swift
static let supabaseAnonKey = "ضع-anon-public-key-هنا"
```
بمجرد وضعه، يطلب التطبيق تسجيل الدخول عند الإقلاع. (آمن في التطبيق — مفتاح عام.)

### 2) رابط إعادة التوجيه
Supabase ← **Authentication ← URL Configuration ← Redirect URLs** ← أضِف:
```
tayyibat://login-callback
```

### 3) مزوّد Google
1. [Google Cloud Console](https://console.cloud.google.com) ← أنشئ مشروعاً ←
   **APIs & Services ← Credentials ← Create OAuth client ID ← Web application**.
2. في **Authorized redirect URIs** ضع:
   `https://cvznuwvwhnujdgfojmsb.supabase.co/auth/v1/callback`
3. انسخ **Client ID** و**Client Secret**.
4. Supabase ← **Authentication ← Providers ← Google** ← فعّله والصق المفتاحين ← احفظ.

> يعمل تسجيل Google فوراً (لا يحتاج عضوية Apple) — مناسب لاختبار الأصدقاء عبر TestFlight لاحقاً.

### 4) مزوّد Apple (بعد عضوية Apple Developer)
1. في Xcode: target ← **Signing & Capabilities ← + Capability ← Sign in with Apple**.
2. Supabase ← **Authentication ← Providers ← Apple** ← فعّله وأضف **Client ID** =
   `com.tayyibat.app` (وبيانات الـ Services ID/المفتاح حسب دليل Supabase).
3. في `AppConfig.swift` بدّل:
   ```swift
   static let appleSignInEnabled = true
   ```
> آبل تشترط وجود "Sign in with Apple" متى وُجد تسجيل دخول اجتماعي آخر (Google)،
> لذا فعّله **قبل** رفع التطبيق للمتجر.

## كيف تعمل (للمرجع)
- Google: `ASWebAuthenticationSession` + PKCE ← `/auth/v1/authorize?provider=google`.
- Apple: زر Sign in with Apple الأصلي ← تبادل `id_token` عبر `/auth/v1/token`.
- تُحفظ الجلسة في Keychain وتُجدَّد تلقائياً عند الإقلاع. زر "تسجيل الخروج" في الإعدادات.
