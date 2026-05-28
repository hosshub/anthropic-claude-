# الطيبات — وسيط التحليل (api.tayyibat.ai)

خدمة **Node بلا أي تبعيات** (تعتمد فقط على Node 18+) تحتفظ بمفتاح **Anthropic**
على الخادم، فيرسل التطبيق الصورة إليها بدل استدعاء `api.anthropic.com` مباشرةً.
هذا يمنع تسريب المفتاح من الجهاز، ويجعل التحليل يعمل لمراجِعي App Store بلا إعداد.

```
التطبيق ──(صورة base64)──▶ https://api.tayyibat.ai/analyze ──(+مفتاحك)──▶ Anthropic ──▶ JSON
```

## النقاط الفعّالة
- `POST /analyze` — الجسم: `{ "image_base64": "...", "media_type": "image/jpeg" }`،
  وترويسة اختيارية `x-app-token`. الرد: JSON النتيجة مباشرةً أو `{ "error": "..." }`.
- `GET /health` — فحص صحة بسيط.

## النشر على خادمك (موصى به)
بافتراض VPS فيه Node 18+ وnginx وHTTPS:

```bash
# 1) ضع الكود
sudo mkdir -p /opt/tayyibat && sudo chown -R $USER /opt/tayyibat
git clone <repo> /opt/tayyibat   # أو ارفع مجلد server/ فقط
cd /opt/tayyibat/server

# 2) الأسرار (لا تُلتزم في git أبداً)
sudo tee /etc/tayyibat-proxy.env >/dev/null <<'EOF'
ANTHROPIC_API_KEY=sk-ant-المفتاح-الجديد
APP_TOKEN=اختياري-سلسلة-سرية
EOF
sudo chmod 600 /etc/tayyibat-proxy.env

# 3) خدمة systemd
sudo cp deploy/tayyibat-proxy.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now tayyibat-proxy
curl localhost:8787/health      # => {"ok":true}

# 4) nginx + شهادة للنطاق الفرعي
sudo cp deploy/nginx-api.tayyibat.ai.conf /etc/nginx/sites-available/api.tayyibat.ai
sudo ln -s /etc/nginx/sites-available/api.tayyibat.ai /etc/nginx/sites-enabled/
sudo certbot --nginx -d api.tayyibat.ai
sudo nginx -t && sudo systemctl reload nginx

# 5) تحقّق من الخارج
curl https://api.tayyibat.ai/health    # => {"ok":true}
```
> تأكد أن سجل DNS لـ `api.tayyibat.ai` (A/AAAA) يشير إلى خادمك قبل إصدار الشهادة.

## بديل: Docker
```bash
cd server
docker build -t tayyibat-proxy .
docker run -d --restart always -p 8787:8787 \
  -e ANTHROPIC_API_KEY=sk-ant-... -e APP_TOKEN=... tayyibat-proxy
# ثم وجّه nginx لـ api.tayyibat.ai إلى 127.0.0.1:8787 كما في ملف الإعداد.
```

## ربط التطبيق
في `Tayyibat/Services/AppConfig.swift` تم الضبط مسبقاً على:
```swift
static let proxyURL = "https://api.tayyibat.ai/analyze"
static let appToken = ""   // إن استخدمت APP_TOKEN ضع القيمة نفسها
```
بمجرد أن يعمل `/health` من الخارج، أعد بناء التطبيق — سيعمل التحليل بلا مفتاح من
المستخدم (يختفي قسم المفتاح في الإعدادات تلقائياً).

## ملاحظات
- حدّث `tayyibat_rules.json` هنا عند تحديث القواعد في التطبيق ليبقيا متطابقين.
- فعّل حدّ معدّل (rate limiting) ومراقبة فواتير Anthropic. `APP_TOKEN` يقلّل العبث
  لكنه قابل للاستخراج؛ للحماية القوية استخدم App Attest لاحقاً.
