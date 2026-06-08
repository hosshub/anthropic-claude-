// Supabase Edge Function: analyze (Google Gemini)
// Holds the Gemini API key as a Supabase secret and serves the Tayyibat app:
//   - meal-image analysis  (image_base64)
//   - tayyib meal suggestion  (task: "suggest")
//   - weekly meal plan        (task: "plan")
// so the key never ships in the app.
//
// Deploy (CLI):   supabase functions deploy analyze --no-verify-jwt
// Secret:         supabase secrets set GEMINI_API_KEY=...      (from Google AI Studio)
// Optional:       supabase secrets set GEMINI_MODEL=gemini-2.5-flash-lite
// Endpoint:       https://<project-ref>.supabase.co/functions/v1/analyze
//   GET   -> { "ok": true }
//   POST  { "image_base64": "...", "media_type": "image/jpeg" }  -> analysis JSON   (counted in daily cap)
//   POST  { "task": "suggest" }                                  -> meal suggestion JSON
//   POST  { "task": "plan" }                                     -> weekly plan JSON

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") ?? "";
const GEMINI_MODEL = Deno.env.get("GEMINI_MODEL") ?? "gemini-2.5-flash-lite";
const APP_TOKEN = Deno.env.get("APP_TOKEN") ?? "";

// حدّ يومي لكل مستخدم لتحليل الصور فقط (الميزة الأغلى).
// suggest/plan لا يُحتسبان لأنهما نصّيان رخيصان نسبياً.
// SUPABASE_URL و SUPABASE_SERVICE_ROLE_KEY يحقنهما Supabase تلقائياً.
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
        { "item_ar": "الفواكه الطبيعية", "examples_ar": "التفاح، الكمثرى، المانجو، الجوافة، الرمان، الفراولة، التين، العنب، الموز", "guidance_ar": "تدخل تدريجياً مع مراقبة الانتفاخ أو الخمول" },
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

// قاعدة مشتركة لكل المهام: لا ادعاءات طبية إطلاقاً.
const SAFETY_PREAMBLE =
  `لا تذكر أي ادعاءات صحية أو علاجية، ولا تدّعِ أن النظام يعالج أو يشفي أي مرض، ولا تذكر الأدوية إطلاقاً. التزم بقوائم النظام فقط.`;

const SAFETY_PREAMBLE_EN =
  `Do not make any medical or therapeutic claims. Do not claim the system treats or cures any condition. Never mention medication. Stay strictly within the Tayyibat system's food lists.`;

function buildPrompt(locale: "ar" | "en" = "ar"): string {
  if (locale === "en") {
    return `You are a food-image analyzer specialized in the "Tayyibat" eating system (visual guide v2).

The system classifies foods into three visual zones:
- 🟢 Green: the foundation of the system; most meals are built on these.
- 🟡 Yellow: use in moderation, watching your body's response.
- 🔴 Red: completely avoided.

System rules (the keys are in Arabic — keep them as-is when grounding your judgment):
${RULES_JSON}

Analyze the attached image and return JSON only (no markdown, no preamble) with EXACTLY this structure. **All natural-language string VALUES must be in clear, natural English. Keep the field NAMES exactly as below (the _ar suffix is historical):**

{
  "identified_items": [
    {
      "name_ar": "food name in English",
      "confidence": 0.0,
      "estimated_portion": "small | medium | large portion",
      "zone": "green | yellow | red",
      "zone_reason_ar": "short reason for the classification, in English",
      "caution_ar": "an item-specific caution for a yellow item (e.g., 'watch digestion after aged cheese') or null",
      "verdict": "tayyib | conditional | khabith   (for compatibility: green=tayyib, yellow=conditional, red=khabith)",
      "category": "starch | protein | fat | cheese | fruit | etc.",
      "reasoning_ar": "same as zone_reason_ar or a slightly broader description, in English",
      "rule_violated": "name of violated rule, in English, or null"
    }
  ],
  "overall_score": 0,
  "score_label_ar": "Excellent | Good | Average | Weak",
  "score_explanation_ar": "two or three sentences in English",
  "improvement_suggestions_ar": ["suggestion 1", "suggestion 2"],
  "warnings": []
}

Scoring logic (v2):
- Each green item: full points proportional to its share of the plate.
- Each yellow item: 60% of points; include a caution_ar.
- Each red item: 0 and a deduction proportional to its share.
- If a red item from the explicit red list is clearly present with high confidence, cap the overall score at 50.
- If the plate is entirely green, give full points and say "fully Tayyib meal" in score_explanation_ar.

${SAFETY_PREAMBLE_EN}
Stay aligned with the guide's wording when possible; be conservative — if unsure about an item, set confidence under 0.7 and warn the user in warnings.`;
  }

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

${SAFETY_PREAMBLE}
التزم بصياغة الدليل عند الإمكان، وكن متحفظاً — إذا لم تكن متأكداً من عنصر، ضع confidence أقل من 0.7 ونبّه المستخدم للمراجعة في warnings.`;
}

function buildSuggestPrompt(locale: "ar" | "en" = "ar"): string {
  if (locale === "en") {
    return `You are an assistant for the "Tayyibat" eating system. System rules (the three zones — keys are in Arabic, keep them as-is when grounding your judgment):
${RULES_JSON}

Suggest one complete, balanced Tayyib meal built from the green zone only (or with a measured yellow touch), and avoid every item from the red zone entirely. Honor the golden rules: simplify ingredients, stop before fullness, one fruit type per sitting, prefer cooked over raw.

Return JSON only (no markdown). Use EXACTLY these field names (the _ar suffix is historical — keep it). All natural-language string VALUES must be in clear, natural English:
{
  "name_ar": "short name of the suggested meal, in English",
  "components_ar": ["component 1", "component 2", "component 3"],
  "reasoning_ar": "one or two sentences in English explaining why this meal is Tayyib",
  "best_time_ar": "appropriate time of day (e.g., breakfast, lunch, light dinner)"
}

${SAFETY_PREAMBLE_EN}`;
  }

  return `أنت مساعد في نظام "الطيبات" الغذائي. قواعد النظام (المناطق الثلاث):
${RULES_JSON}

اقترح وجبة طيبة واحدة متكاملة من المنطقة الخضراء فقط (أو مع لمسة صفراء بحساب)، وتجنّب تماماً أي عنصر من المنطقة الحمراء. راعِ القواعد الذهبية: تبسيط المكونات، التوقف قبل الامتلاء، صنف فاكهة واحد في الجلسة، تفضيل المطبوخ.

أرجع JSON فقط (بدون markdown) بهذه البنية بالضبط:
{
  "name_ar": "اسم مختصر للوجبة المقترحة",
  "components_ar": ["مكوّن 1", "مكوّن 2", "مكوّن 3"],
  "reasoning_ar": "جملة أو جملتان عن سبب كون الوجبة طيبة وفق النظام",
  "best_time_ar": "وقت مناسب للوجبة (مثلاً: فطور، غداء، عشاء خفيف)"
}

${SAFETY_PREAMBLE}`;
}

function buildPlanPrompt(locale: "ar" | "en" = "ar"): string {
  if (locale === "en") {
    return `You are an assistant for the "Tayyibat" eating system. System rules (the three zones — keys are in Arabic, keep them as-is):
${RULES_JSON}

Generate a full week of meals (7 days, Saturday through Friday) built mostly from the green zone, with measured yellow touches, and avoid every red-zone item entirely. Honor: alternate protein day-to-day, one fruit type per sitting, prefer cooked, and the recommended fasting days (Monday and Thursday) with a Tayyib iftar.

For each day suggest breakfast, lunch, and dinner from Tayyibat foods. Return JSON only (no markdown). Use EXACTLY these field names (the _ar suffix is historical). String VALUES must be in clear, natural English; day names must be the English weekday names ("Saturday" .. "Friday"):
{
  "intro_ar": "a short introductory sentence in English",
  "days": [
    {
      "day_ar": "Saturday",
      "meals_ar": ["Breakfast: ...", "Lunch: ...", "Dinner: ..."],
      "note_ar": "optional short note in English, or empty string"
    }
  ]
}
"days" must contain exactly 7 entries in this order: Saturday, Sunday, Monday, Tuesday, Wednesday, Thursday, Friday.

${SAFETY_PREAMBLE_EN}`;
  }

  return `أنت مساعد في نظام "الطيبات" الغذائي. قواعد النظام (المناطق الثلاث):
${RULES_JSON}

ولّد خطة وجبات لأسبوع كامل (٧ أيام تبدأ بالسبت وتنتهي بالجمعة) من المنطقة الخضراء أساساً، مع لمسات صفراء بحساب، وتجنّب كل عناصر المنطقة الحمراء تماماً. راعِ: البروتين يوماً بعد يوم، صنف فاكهة واحد في الجلسة، تفضيل المطبوخ، وأيام الصيام المستحبة (الإثنين والخميس) بإفطار على طعام طيّب.

لكل يوم اقترح فطوراً وغداءً وعشاءً من الطيبات. أرجع JSON فقط (بدون markdown) بهذه البنية بالضبط:
{
  "intro_ar": "جملة تمهيدية قصيرة",
  "days": [
    {
      "day_ar": "السبت",
      "meals_ar": ["فطور: ...", "غداء: ...", "عشاء: ..."],
      "note_ar": "ملاحظة قصيرة اختيارية أو نص فارغ"
    }
  ]
}
يجب أن تحتوي days على ٧ عناصر بالضبط بالترتيب: السبت، الأحد، الإثنين، الثلاثاء، الأربعاء، الخميس، الجمعة.

${SAFETY_PREAMBLE}`;
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

/**
 * نداء Gemini موحّد للمهام الثلاث (تحليل صورة / اقتراح / خطة).
 * يُعيد Response جاهزاً للإرجاع للعميل. إذا فشلت العملية يستدعي onFailure قبل العودة
 * (يُستخدم لاسترجاع الحصّة في حال تحليل الصور).
 */
async function callGemini(
  parts: unknown[],
  maxTokens: number,
  onFailure: () => Promise<void> = async () => {},
): Promise<Response> {
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
        contents: [{ role: "user", parts }],
        generationConfig: {
          temperature: 0.4,
          maxOutputTokens: maxTokens,
          responseMimeType: "application/json",
        },
      }),
    });
    raw = await upstream.text();
  } catch (e) {
    await onFailure();
    return json(502, { error: `تعذّر الاتصال بـ Gemini: ${(e as Error).message}` });
  }

  if (!upstream.ok) {
    await onFailure();
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
      await onFailure();
      const reason = candidate?.finishReason ?? data.promptFeedback?.blockReason;
      // رسالة ألطف عند رفض مرشّح الأمان لصورة طعام.
      if (reason === "SAFETY") {
        return json(502, { error: "تعذّر تحليل الطلب. جرّب صياغة أو زاوية مختلفة." });
      }
      return json(502, { error: `لم يُرجِع النموذج نتيجة${reason ? ` (${reason})` : ""}` });
    }
    return json(200, JSON.parse(stripFences(text)));
  } catch {
    await onFailure();
    return json(502, { error: "تعذّر تحليل نتيجة النموذج" });
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

  let payload: {
    image_base64?: string;
    media_type?: string;
    task?: string;
    locale?: string;
  };
  try {
    payload = await req.json();
  } catch {
    return json(400, { error: "جسم الطلب غير صالح" });
  }

  const locale: "ar" | "en" = payload.locale === "en" ? "en" : "ar";

  // 1) اقتراح وجبة واحدة (نصّي — لا يُحتسب في الحدّ اليومي).
  if (payload.task === "suggest") {
    return await callGemini([{ text: buildSuggestPrompt(locale) }], 1024);
  }

  // 2) خطة أسبوعية كاملة (نصّي — لا يُحتسب في الحدّ اليومي).
  if (payload.task === "plan") {
    return await callGemini([{ text: buildPlanPrompt(locale) }], 4096);
  }

  // 3) تحليل صورة وجبة (الافتراضي — يخضع للحدّ اليومي).
  const imageBase64 = payload.image_base64;
  const mediaType = payload.media_type ?? "image/jpeg";
  if (!imageBase64) return json(400, { error: "image_base64 أو task مطلوب" });

  const userId = userIdFromJWT(req.headers.get("authorization"));
  let counted = false;
  if (userId) {
    const used = await bumpDailyUsage(userId);
    if (used !== null && used < 0) {
      return json(429, {
        error: locale === "en"
          ? `Daily analysis limit reached (${DAILY_LIMIT}). Try again tomorrow.`
          : `بلغت الحد اليومي للتحليلات (${DAILY_LIMIT}). جرّب مجدداً غداً.`,
      });
    }
    counted = used !== null && used > 0;
  }

  const refundIfCounted = async () => {
    if (counted && userId) await refundDailyUsage(userId);
  };

  return await callGemini(
    [
      { inlineData: { mimeType: mediaType, data: imageBase64 } },
      { text: buildPrompt(locale) },
    ],
    2048,
    refundIfCounted,
  );
});
