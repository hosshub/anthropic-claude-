// خادم وسيط بلا تبعيات (CommonJS) — متوافق مع cPanel/Passenger و VPS و Docker.
// يحتاج Node 18+ (لتوفّر fetch عالمياً).
const http = require("node:http");
const rules = require("./tayyibat_rules.json");
const rulesJSON = JSON.stringify(rules);

const PORT = Number(process.env.PORT || 8787);
const APP_TOKEN = process.env.APP_TOKEN || "";
const API_KEY = process.env.ANTHROPIC_API_KEY || "";
const MODEL = "claude-opus-4-7";
const ANTHROPIC_VERSION = "2023-06-01";
const MAX_BODY = 20 * 1024 * 1024; // 20MB

function buildPrompt() {
  return `أنت محلل صور طعام متخصص في نظام "الطيبات" الغذائي للدكتور ضياء العوضي.

قواعد النظام:
${rulesJSON}

حلل الصورة المرفقة وأرجع JSON فقط (بدون markdown ولا preamble) بهذه البنية بالضبط:

{
  "identified_items": [
    {
      "name_ar": "اسم الطعام بالعربية",
      "confidence": 0.0,
      "estimated_portion": "حصة صغيرة | متوسطة | كبيرة",
      "verdict": "tayyib | khabith | conditional",
      "category": "نشويات | لحوم | خضروات | فواكه | إلخ",
      "reasoning_ar": "السبب بالعربية",
      "rule_violated": "اسم القاعدة المخالفة أو null"
    }
  ],
  "overall_score": 0,
  "score_label_ar": "ممتاز | جيد | متوسط | ضعيف",
  "score_explanation_ar": "جملتين أو ثلاث بالعربية",
  "improvement_suggestions_ar": ["اقتراح 1", "اقتراح 2"],
  "warnings": []
}

منطق النقاط:
- كل عنصر طيب: نقاط كاملة بحسب نسبة ظهوره في الطبق
- كل عنصر مشروط: نصف النقاط
- كل عنصر خبيث: صفر + خصم بنسبة ظهوره
- لو فيه أي عنصر ممنوع صراحة (دجاج، بيض، بقوليات، خضروات ورقية) ظاهر بوضوح، الحد الأقصى للنتيجة = 60

كن متحفظاً — إذا كنت غير متأكد من عنصر، ضع confidence أقل من 0.7 ونبّه المستخدم للمراجعة في warnings.`;
}

function stripFences(text) {
  let t = (text || "").trim();
  if (t.startsWith("```")) t = t.replace(/```json/g, "").replace(/```/g, "").trim();
  const a = t.indexOf("{");
  const b = t.lastIndexOf("}");
  if (a !== -1 && b !== -1) t = t.slice(a, b + 1);
  return t;
}

function send(res, status, obj) {
  res.writeHead(status, {
    "content-type": "application/json; charset=utf-8",
    "access-control-allow-origin": "*",
    "access-control-allow-headers": "content-type,x-app-token",
    "access-control-allow-methods": "POST,GET,OPTIONS",
  });
  res.end(JSON.stringify(obj));
}

const server = http.createServer((req, res) => {
  if (req.method === "OPTIONS") return send(res, 204, {});
  if (req.method === "GET" && req.url === "/health") return send(res, 200, { ok: true });

  if (req.method !== "POST" || !req.url.startsWith("/analyze")) {
    return send(res, 404, { error: "غير موجود" });
  }
  if (APP_TOKEN && req.headers["x-app-token"] !== APP_TOKEN) {
    return send(res, 401, { error: "غير مصرّح" });
  }
  if (!API_KEY) {
    return send(res, 500, { error: "الخادم غير مهيّأ: متغيّر ANTHROPIC_API_KEY مفقود" });
  }

  let body = "";
  let aborted = false;
  req.on("data", (c) => {
    body += c;
    if (body.length > MAX_BODY) {
      aborted = true;
      send(res, 413, { error: "الصورة كبيرة جداً" });
      req.destroy();
    }
  });
  req.on("end", async () => {
    if (aborted) return;
    let imageBase64, mediaType;
    try {
      const p = JSON.parse(body);
      imageBase64 = p.image_base64;
      mediaType = p.media_type || "image/jpeg";
    } catch {
      return send(res, 400, { error: "جسم الطلب غير صالح" });
    }
    if (!imageBase64) return send(res, 400, { error: "image_base64 مطلوب" });

    const anthropicBody = {
      model: MODEL,
      max_tokens: 2000,
      messages: [
        {
          role: "user",
          content: [
            { type: "image", source: { type: "base64", media_type: mediaType, data: imageBase64 } },
            { type: "text", text: buildPrompt() },
          ],
        },
      ],
    };

    let upstream, raw;
    try {
      upstream = await fetch("https://api.anthropic.com/v1/messages", {
        method: "POST",
        headers: {
          "x-api-key": API_KEY,
          "anthropic-version": ANTHROPIC_VERSION,
          "content-type": "application/json",
        },
        body: JSON.stringify(anthropicBody),
      });
      raw = await upstream.text();
    } catch (e) {
      return send(res, 502, { error: `تعذّر الاتصال بـ Anthropic: ${e.message}` });
    }

    if (!upstream.ok) {
      let msg = `خطأ من Anthropic (${upstream.status})`;
      try { msg = JSON.parse(raw)?.error?.message || msg; } catch {}
      return send(res, upstream.status, { error: msg });
    }

    try {
      const data = JSON.parse(raw);
      const text = (data.content || []).filter((b) => b.type === "text").map((b) => b.text).join("");
      const result = JSON.parse(stripFences(text)); // تحقق من صحة JSON
      return send(res, 200, result);
    } catch {
      return send(res, 502, { error: "تعذّر تحليل نتيجة النموذج" });
    }
  });
});

// تحت Passenger (cPanel) يُمرَّر PORT تلقائياً ويُربط بالمقبس الصحيح.
server.listen(PORT, () => console.log(`Tayyibat proxy listening on :${PORT}`));
