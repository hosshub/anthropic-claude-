# الطيبات — وسيط التحليل (api.tayyibat.ai)

خدمة **Node بلا أي تبعيات** (`app.js`، CommonJS، تحتاج Node 18+) تحتفظ بمفتاح
**Anthropic** على الخادم، فيرسل التطبيق الصورة إليها بدل استدعاء `api.anthropic.com`
مباشرةً. هذا يمنع تسريب المفتاح من الجهاز، ويجعل التحليل يعمل لمراجِعي App Store.

```
التطبيق ──(صورة base64)──▶ https://api.tayyibat.ai/analyze ──(+مفتاحك)──▶ Anthropic ──▶ JSON
```

النقاط الفعّالة: `POST /analyze` (الجسم `{ "image_base64": "...", "media_type": "image/jpeg" }`)
و`GET /health`.

---

## النشر على cPanel (خطوة بخطوة)

### أ) صفحة الموقع (tayyibat.ai)
1. cPanel → **File Manager** → ادخل مجلد `public_html`.
2. ارفع ملفات مجلد `web/` (`index.html` و`privacy.html` و`logo.png`) إلى `public_html`
   (أو اضغطها ZIP وارفعها ثم **Extract**).
3. تأكد أن **AutoSSL** فعّال (cPanel → SSL/TLS Status) كي يعمل `https://tayyibat.ai`.
4. رابط الخصوصية لـ App Store: `https://tayyibat.ai/privacy.html`.

### ب) النطاق الفرعي api.tayyibat.ai + تطبيق Node
1. cPanel → **Domains** (أو Subdomains) → أنشئ `api.tayyibat.ai`. دع cPanel ينشئ
   مجلده الجذري (مثلاً `api.tayyibat.ai/`).
2. cPanel → قسم **Software → Setup Node.js App** → **Create Application**:
   - **Node.js version:** 18 أو أحدث.
   - **Application mode:** Production.
   - **Application root:** مجلد جديد مثل `tayyibat-proxy` (داخل الـ home).
   - **Application URL:** اختر `api.tayyibat.ai`.
   - **Application startup file:** `app.js`.
   - اضغط **Create**.
3. ارفع ملفات الوسيط إلى **Application root** (`tayyibat-proxy/`) عبر File Manager:
   - `app.js`
   - `tayyibat_rules.json`
   - `package.json`
   *(لا توجد تبعيات، لكن يمكنك الضغط على **Run NPM Install** بلا مشاكل.)*
4. في صفحة تطبيق Node نفسها → **Environment variables** → أضِف:
   - `ANTHROPIC_API_KEY` = مفتاحك الجديد من `console.anthropic.com` (بعد إلغاء المُسرَّب).
   - (اختياري) `APP_TOKEN` = سلسلة سرّية؛ ضع نفسها في `AppConfig.appToken`.
5. اضغط **Restart** (أو Stop ثم Start).
6. تأكد أن **AutoSSL** أصدر شهادة لـ `api.tayyibat.ai` (SSL/TLS Status → أعد التشغيل إن لزم).
7. تحقّق: افتح `https://api.tayyibat.ai/health` → يجب أن يردّ `{"ok":true}`.

> ملاحظة Passenger: لا تحتاج لتعديل أي شيء في `app.js` — Passenger يمرّر `PORT`
> ويربط المقبس تلقائياً. إن غيّرت متغيّرات البيئة لاحقاً اضغط **Restart**.

### ج) ربط التطبيق
`Tayyibat/Services/AppConfig.swift` مضبوط مسبقاً على:
```swift
static let proxyURL = "https://api.tayyibat.ai/analyze"
```
بمجرد أن يردّ `/health` بنجاح، أعد بناء التطبيق — يعمل التحليل بلا مفتاح من المستخدم.

---

## بدائل (VPS بجذر / Docker)
- **VPS:** `node app.js` خلف nginx مع systemd — انظر `deploy/tayyibat-proxy.service`
  و`deploy/nginx-api.tayyibat.ai.conf` وأصدر شهادة بـ `certbot`.
- **Docker:** `docker build -t tayyibat-proxy . && docker run -d --restart always -p 8787:8787 -e ANTHROPIC_API_KEY=... tayyibat-proxy`.

## ملاحظات
- حدّث `tayyibat_rules.json` هنا عند تغيير القواعد في التطبيق ليبقيا متطابقين.
- راقب فواتير Anthropic وفعّل حدّ معدّل إن أمكن. `APP_TOKEN` يقلّل العبث لكنه قابل
  للاستخراج؛ للحماية القوية استخدم App Attest لاحقاً.
