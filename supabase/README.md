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
