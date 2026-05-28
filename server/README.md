# الطيبات — الوسيط الخلفي (Backend Proxy)

دالة بلا خادم (serverless) تحتفظ بمفتاح **Anthropic** على الخادم، فيرسل التطبيق
الصورة إلى هذا الوسيط بدل استدعاء `api.anthropic.com` مباشرةً. هذا يمنع تسريب
المفتاح من جهاز المستخدم، ويجعل ميزة التحليل تعمل لمراجِعي App Store دون أي إعداد.

```
التطبيق  ──(صورة base64)──▶  /analyze  ──(+ مفتاحك)──▶  Anthropic  ──▶  JSON النتيجة
```

## النقطة الفعّالة
`POST /analyze`

الطلب:
```json
{ "image_base64": "...", "media_type": "image/jpeg" }
```
الترويسات: `content-type: application/json` و(اختياري) `x-app-token: <APP_TOKEN>`.

الرد: نفس بنية `AnalysisResult` التي يتوقعها التطبيق (JSON النتيجة مباشرةً)، أو
`{ "error": "..." }` مع رمز حالة مناسب.

## النشر على Netlify (موصى به — مجاني وسريع)
1. ادفع المستودع إلى GitHub (تم).
2. في Netlify: **Add new site → Import from GitHub** واختر هذا المستودع.
3. **Base directory:** `server`  •  Build command: (اتركه فارغاً)  •  Publish: `public`.
4. **Site settings → Environment variables**، أضِف:
   - `ANTHROPIC_API_KEY` = مفتاحك الجديد من `console.anthropic.com` (الذي أنشأته بعد إلغاء المُسرَّب).
   - (اختياري) `APP_TOKEN` = أي سلسلة سرّية؛ ضع نفسها في `AppConfig.appToken` بالتطبيق.
5. Deploy. سيصبح الرابط: `https://YOUR-SITE.netlify.app/analyze`.

### بديل: Netlify CLI
```bash
cd server
npm i -g netlify-cli
netlify deploy --prod
# ثم اضبط متغيّرات البيئة من لوحة التحكم
```

## ربط التطبيق بالوسيط
في `Tayyibat/Services/AppConfig.swift`:
```swift
static let proxyURL = "https://YOUR-SITE.netlify.app/analyze"
static let appToken = ""   // إن استخدمت APP_TOKEN على الخادم ضع القيمة نفسها
```
عند ضبط `proxyURL`، يتوقف التطبيق عن طلب مفتاح من المستخدم تلقائياً (يختفي قسم
المفتاح في الإعدادات) ويستخدم الوسيط.

## ملاحظات أمان/تكلفة
- `APP_TOKEN` يقلّل العبث لكنه قابل للاستخراج من الثنائية؛ للحماية القوية استخدم
  **App Attest** لاحقاً.
- فعّل حدّ معدّل (rate limiting) على الدالة ومراقبة فواتير Anthropic.
- المفتاح يبقى في متغيّرات بيئة Netlify فقط — لا يُلتزم في المستودع أبداً.
