import { readFileSync } from "node:fs";

// قواعد نظام الطيبات تُحمّل مرة واحدة وتُضمَّن في الـ prompt.
const rulesJSON = readFileSync(new URL("./tayyibat_rules.json", import.meta.url), "utf8");

const MODEL = "claude-opus-4-7";
const ANTHROPIC_VERSION = "2023-06-01";

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
  if (t.startsWith("```")) {
    t = t.replace(/```json/g, "").replace(/```/g, "").trim();
  }
  const start = t.indexOf("{");
  const end = t.lastIndexOf("}");
  if (start !== -1 && end !== -1) t = t.slice(start, end + 1);
  return t;
}

function json(status, obj) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { "content-type": "application/json; charset=utf-8" },
  });
}

export default async (req) => {
  if (req.method !== "POST") return json(405, { error: "Method not allowed" });

  // سر مشترك اختياري لتقليل إساءة الاستخدام.
  const expected = process.env.APP_TOKEN;
  if (expected && req.headers.get("x-app-token") !== expected) {
    return json(401, { error: "غير مصرّح" });
  }

  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) return json(500, { error: "الخادم غير مهيّأ: مفتاح ANTHROPIC_API_KEY مفقود" });

  let payload;
  try {
    payload = await req.json();
  } catch {
    return json(400, { error: "جسم الطلب غير صالح" });
  }
  const imageBase64 = payload?.image_base64;
  const mediaType = payload?.media_type || "image/jpeg";
  if (!imageBase64) return json(400, { error: "image_base64 مطلوب" });

  const body = {
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

  let upstream;
  try {
    upstream = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "x-api-key": apiKey,
        "anthropic-version": ANTHROPIC_VERSION,
        "content-type": "application/json",
      },
      body: JSON.stringify(body),
    });
  } catch (e) {
    return json(502, { error: `تعذّر الاتصال بـ Anthropic: ${e.message}` });
  }

  const raw = await upstream.text();
  if (!upstream.ok) {
    let msg = `خطأ من Anthropic (${upstream.status})`;
    try {
      msg = JSON.parse(raw)?.error?.message || msg;
    } catch {}
    return json(upstream.status, { error: msg });
  }

  let text = "";
  try {
    const data = JSON.parse(raw);
    text = (data.content || [])
      .filter((b) => b.type === "text")
      .map((b) => b.text)
      .join("");
  } catch {
    return json(502, { error: "رد غير متوقع من Anthropic" });
  }

  const cleaned = stripFences(text);
  try {
    const result = JSON.parse(cleaned); // تحقّق من صحة JSON
    return json(200, result);
  } catch {
    return json(502, { error: "تعذّر تحليل نتيجة النموذج" });
  }
};

export const config = { path: "/analyze" };
