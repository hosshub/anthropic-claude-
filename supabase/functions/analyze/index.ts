// Supabase Edge Function: analyze (Google Gemini)
// Holds the Gemini API key as a Supabase secret and forwards meal-image
// analysis for the Tayyibat iOS app, so the key never ships in the app.
//
// Deploy (CLI):   supabase functions deploy analyze --no-verify-jwt
// Secret:         supabase secrets set GEMINI_API_KEY=...      (from Google AI Studio)
// Optional:       supabase secrets set GEMINI_MODEL=gemini-2.5-flash-lite
// Endpoint:       https://<project-ref>.supabase.co/functions/v1/analyze
//   GET  -> { "ok": true }
//   POST -> { "image_base64": "...", "media_type": "image/jpeg" } -> result JSON

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") ?? "";
const GEMINI_MODEL = Deno.env.get("GEMINI_MODEL") ?? "gemini-2.5-flash-lite";
const APP_TOKEN = Deno.env.get("APP_TOKEN") ?? "";

// حدّ يومي لكل مستخدم (حماية من التكلفة). يُفرَض فقط عند إرسال التطبيق توكن المستخدم.
// SUPABASE_URL و SUPABASE_SERVICE_ROLE_KEY يحقنهما Supabase تلقائياً في الدوال.
const DAILY_LIMIT = 7;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

// v2 — قواعد الطيبات وفق الدليل البصري الموسّع (إشارات ثلاثية).
const RULES = {
  "version": "2.0",
  "system_name": "نظام الطيبات",
  "zones": {
    "green": {
      "label_ar": "أخضر",
      "subtitle_ar": "أساس النظام",
      "groups": [
        { "category_ar": "النشويات البسيطة", "items": ["الأرز الأبيض", "الأرز البسمتي", "البطاطس"] },
        { "category_ar": "البروتينات الأساسية", "items": ["اللحم الأحمر", "الكبدة", "الكوارع", "لحم الأرنب", "بعض الأسماك", "الحمام", "السمان"] },
        { "category_ar": "الدهون الطبيعية", "items": ["السمن البلدي", "الزبدة الطبيعية", "زيت الزيتون", "الزيتون"] },
        { "category_ar": "إضافات بسيطة", "items": ["التمر (كمية محسوبة)", "العسل الطبيعي (كمية محسوبة)"] },
        { "category_ar": "مشروبات أساسية", "items": ["الماء", "مشروبات بسيطة حسب التحمل"] }
      ]
    },
    "yellow": {
      "label_ar": "أصفر",
      "subtitle_ar": "بحساب، وليس مفتوحاً بلا حدود",
      "watchword_ar": "جرّب، راقب، وقلّل عند ظهور ثقل أو اضطراب هضمي",
      "groups": [
        { "item_ar": "الأجبان المعتقة", "examples_ar": "شيدر، جودة، بارميزان، روكفور، فلمنك", "guidance_ar": "باعتدال وحسب الهضم" },
        { "item_ar": "الفواكه الطبيعية", "examples_ar": "التفاح، الكمثرى، المانجو، الجوافة، الرمان، الفراولة، التين، العنب، الموز", "guidance_ar": "تدخل تدريجياً، مع مراقبة الانتفاخ أو الخمول" },
        { "item_ar": "العسل والتمر", "guidance_ar": "كميات بسيطة، وليس استخداماً مفتوحاً طوال اليوم" },
        { "item_ar": "القهوة", "guidance_ar": "حسب النوم والتوتر وتحمل الكافيين" },
        { "item_ar": "الشاي", "guidance_ar": "ليس أساساً. إن وُجد يكون بسيطاً وبسكر خفيف" }
      ]
    },
    "red": {
      "label_ar": "أحمر",
      "subtitle_ar": "ممنوع تماماً في هذه النسخة",
      "groups": [
        { "category_ar": "الدواجن والبيض", "items": ["الفراخ", "الديك الرومي", "البط", "الطيور التجارية", "البيض بجميع أشكاله"] },
        { "category_ar": "الحليب ومشتقاته العادية", "items": ["الحليب", "الزبادي", "اللبن الرائب", "القشطة", "منتجات الألبان العادية"] },
        { "category_ar": "البقوليات", "items": ["الفول", "العدس", "الحمص", "الفاصوليا", "اللوبيا", "البازلاء"] },
        { "category_ar": "الأطعمة فائقة التصنيع", "items": ["الوجبات السريعة", "المنتجات الجاهزة", "المشروبات الغازية"] },
        { "category_ar": "الزيوت الصناعية", "items": ["الزيوت المهدرجة", "الزيوت كثيرة المعالجة"] },
        { "category_ar": "الإضافات الجاهزة", "items": ["الصوصات", "الخلطات الجاهزة", "المنتجات كثيرة المكونات"] }
      ]
    }
  },
  "golden_rules": [
    "الأكل عند الجوع الحقيقي",
    "التوقف قبل الامتلاء",
    "تقليل السناكات",
    "تبسيط مكونات الوجبة",
    "مراقبة الاستجابة",
    "الاستمرارية قبل المثالية"
  ]
};

const RULES_JSON = JSON.stringify(RULES);

function buildPrompt(): string {
  return `أنت محلل صور طعام متخصص في نظام "الطيبات" الغذائي وفق نسخة الدليل الموسّع (نسخة 2).

يصنّف النظام الأطعمة في ثلاث مناطق بصرية:
- 🟢 أخضر: أساس النظام، تُبنى عليه أغلب الوجبات.
- 🟡 أصفر: يُستخدم باعتدال وحسب استجابة الجسم.
- 🔴 أحمر: ممنوع تماماً.

قواعد النظام:
${RULES_JSON}

حلل الصورة المرفقة وأرجع JSON فقط (بدون markdown ولا preamble) بهذه البنية بالضبط:

{
  "identified_items": [
    {
      "name_ar": "اسم الطعام بالعربية",
      "confidence": 0.0,
      "estimated_portion": "حصة صغيرة | متوسطة | كبيرة",
      "zone": "green | yellow | red",
      "zone_reason_ar": "سبب التصنيف باختصار",
      "caution_ar": "تنبيه خاص للعنصر الأصفر (مثلاً: راقب الهضم بعد الجبن المعتق) أو null",
      "verdict": "tayyib | conditional | khabith   (للتوافق: أخضر=tayyib، أصفر=conditional، أحمر=khabith)",
      "category": "نشويات | بروتينات | دهون | أجبان | فواكه | إلخ",
      "reasoning_ar": "نفس zone_reason_ar أو وصف أوسع",
      "rule_violated": "اسم القاعدة المخالفة أو null"
    }
  ],
  "overall_score": 0,
  "score_label_ar": "ممتاز | جيد | متوسط | ضعيف",
  "score_explanation_ar": "جملتان أو ثلاث بالعربية",
  "improvement_suggestions_ar": ["اقتراح 1", "اقتراح 2"],
  "warnings": []
}

منطق النقاط (نسخة 2):
- كل عنصر أخضر: نقاط كاملة بحسب نسبة ظهوره في الطبق.
- كل عنصر أصفر: 60% من النقاط، مع تنبيه caution_ar لمراجعة استجابة الجسم.
- كل عنصر أحمر: 0 + خصم بنسبة ظهوره.
- إذا ظهر عنصر أحمر مذكور صراحة في القائمة الحمراء بثقة عالية، الحد الأقصى للنتيجة = 50.
- إذا كان الطبق كله أخضر، أعطِ النقاط الكاملة واذكر "وجبة طيبة كاملة" في score_explanation_ar.

التزم بصياغة الدليل عند الإمكان، وكن متحفظاً — إذا لم تكن متأكداً من عنصر، ضع confidence أقل من 0.7 ونبّه المستخدم للمراجعة في warnings.`;
}

function stripFences(text: string): string {
  let t = (text ?? "").trim();
  if (t.startsWith("```")) t = t.replaceAll("```json", "").replaceAll("```", "").trim();
  const a = t.indexOf("{");
  const b = t.lastIndexOf("}");
  if (a !== -1 && b !== -1) t = t.slice(a, b + 1);
  return t;
}

const CORS: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "content-type,x-app-token,authorization,apikey",
  "Access-Control-Allow-Methods": "POST,GET,OPTIONS",
};

function json(status: number, obj: unknown): Response {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { "content-type": "application/json; charset=utf-8", ...CORS },
  });
}

// يقرأ معرّف المستخدم (sub) من توكن Supabase دون التحقق من التوقيع — يكفي لعدّ الحصص.
function userIdFromJWT(authHeader: string | null): string | null {
  if (!authHeader) return null;
  const match = authHeader.match(/^Bearer\s+(.+)$/i);
  if (!match) return null;
  const parts = match[1].split(".");
  if (parts.length < 2) return null;
  try {
    let b64 = parts[1].replace(/-/g, "+").replace(/_/g, "/");
    while (b64.length % 4 !== 0) b64 += "=";
    const payload = JSON.parse(atob(b64));
    return typeof payload.sub === "string" ? payload.sub : null;
  } catch {
    return null;
  }
}

// يزيد عدّاد اليوم ذرّياً عبر دالة Postgres. يُعيد:
//   عدد موجب = مسموح (رقم التحليل اليوم بعد الزيادة)،
//   عدد سالب = تجاوز الحدّ، أو null إذا تعذّر العدّ (نسمح حينها — fail open).
async function bumpDailyUsage(userId: string): Promise<number | null> {
  if (!SUPABASE_URL || !SERVICE_KEY) return null;
  try {
    const res = await fetch(`${SUPABASE_URL}/rest/v1/rpc/bump_usage`, {
      method: "POST",
      headers: {
        apikey: SERVICE_KEY,
        authorization: `Bearer ${SERVICE_KEY}`,
        "content-type": "application/json",
      },
      body: JSON.stringify({ p_user: userId, p_limit: DAILY_LIMIT }),
    });
    if (!res.ok) return null;
    const value = await res.json();
    const n = typeof value === "number" ? value : Number(value);
    return Number.isFinite(n) ? n : null;
  } catch {
    return null;
  }
}

// يسترجع حصّة واحدة عند فشل التحليل. أفضل جهد — يتجاهل الأخطاء.
async function refundDailyUsage(userId: string): Promise<void> {
  if (!SUPABASE_URL || !SERVICE_KEY) return;
  try {
    await fetch(`${SUPABASE_URL}/rest/v1/rpc/refund_usage`, {
      method: "POST",
      headers: {
        apikey: SERVICE_KEY,
        authorization: `Bearer ${SERVICE_KEY}`,
        "content-type": "application/json",
      },
      body: JSON.stringify({ p_user: userId }),
    });
  } catch {
    // تجاهل
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method === "GET") return json(200, { ok: true });
  if (req.method !== "POST") return json(404, { error: "غير موجود" });

  if (APP_TOKEN && req.headers.get("x-app-token") !== APP_TOKEN) {
    return json(401, { error: "غير مصرّح" });
  }
  if (!GEMINI_API_KEY) {
    return json(500, { error: "الخادم غير مهيّأ: متغيّر GEMINI_API_KEY مفقود" });
  }

  let payload: { image_base64?: string; media_type?: string };
  try {
    payload = await req.json();
  } catch {
    return json(400, { error: "جسم الطلب غير صالح" });
  }
  const imageBase64 = payload.image_base64;
  const mediaType = payload.media_type ?? "image/jpeg";
  if (!imageBase64) return json(400, { error: "image_base64 مطلوب" });

  // الحدّ اليومي لكل مستخدم (إن أرسل التطبيق التوكن).
  const userId = userIdFromJWT(req.headers.get("authorization"));
  let counted = false;
  if (userId) {
    const used = await bumpDailyUsage(userId);
    if (used !== null && used < 0) {
      return json(429, {
        error: `بلغت الحد اليومي للتحليلات (${DAILY_LIMIT}). جرّب مجدداً غداً.`,
      });
    }
    counted = used !== null && used > 0;
  }

  // يُعيد الحصّة المحجوزة إذا فشل التحليل لاحقاً.
  const refundIfCounted = async () => {
    if (counted && userId) await refundDailyUsage(userId);
  };

  const endpoint =
    `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`;

  let upstream: Response;
  let raw: string;
  try {
    upstream = await fetch(endpoint, {
      method: "POST",
      headers: {
        "x-goog-api-key": GEMINI_API_KEY,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        contents: [{
          role: "user",
          parts: [
            { inlineData: { mimeType: mediaType, data: imageBase64 } },
            { text: buildPrompt() },
          ],
        }],
        generationConfig: {
          temperature: 0.2,
          maxOutputTokens: 2048,
          responseMimeType: "application/json",
        },
      }),
    });
    raw = await upstream.text();
  } catch (e) {
    await refundIfCounted();
    return json(502, { error: `تعذّر الاتصال بـ Gemini: ${(e as Error).message}` });
  }

  if (!upstream.ok) {
    await refundIfCounted();
    let msg = `خطأ من Gemini (${upstream.status})`;
    try { msg = JSON.parse(raw)?.error?.message ?? msg; } catch { /* keep default */ }
    return json(upstream.status, { error: msg });
  }

  try {
    const data = JSON.parse(raw);
    const candidate = data.candidates?.[0];
    const text = (candidate?.content?.parts ?? [])
      .map((p: { text?: string }) => p.text ?? "")
      .join("");
    if (!text) {
      await refundIfCounted();
      const reason = candidate?.finishReason ?? data.promptFeedback?.blockReason;
      return json(502, { error: `لم يُرجِع النموذج نتيجة${reason ? ` (${reason})` : ""}` });
    }
    const result = JSON.parse(stripFences(text));
    return json(200, result);
  } catch {
    await refundIfCounted();
    return json(502, { error: "تعذّر تحليل نتيجة النموذج" });
  }
});
