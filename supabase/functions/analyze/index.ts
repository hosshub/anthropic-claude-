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

const RULES = {
  "version": "1.0",
  "system_name": "نظام الطيبات",
  "categories": [
    { "id": "starches", "name_ar": "النشويات", "allowed": ["خبز القمح الكامل (محمص يُفضّل)", "خبز الذرة", "الأرز بأنواعه", "البطاطس (مقلية، مسلوقة، مطبوخة)"], "forbidden": [] },
    { "id": "fats", "name_ar": "الدهون", "allowed": ["زيت الزيتون (الأفضل)", "الزبدة", "السمن الحيواني", "القشدة", "زيت الذرة", "زيت دوار الشمس"], "forbidden": [] },
    { "id": "cheese", "name_ar": "الأجبان", "note": "المعتقة الصلبة فقط", "allowed": ["بارميزان", "رومي", "شيدر", "فلمنك", "غودا", "موتزاريلا", "روكفور", "الجبن المطبوخ"], "forbidden": ["الجبن الأبيض", "القريش"] },
    { "id": "vegetables", "name_ar": "الخضروات", "note": "المطبوخة فقط؛ النيئة والورقية من الخبائث", "allowed": ["البطاطس", "الباذنجان", "الفلفل المطبوخ", "القلقاس", "القرنبيط"], "forbidden": ["الأفوكادو", "الخيار", "الخس", "الجرجير", "البقدونس", "الكرفس", "الجزر", "الفلفل النيء", "الطماطم", "السبانخ", "البازلاء", "الملوخية", "الكرنب", "ورق العنب"] },
    { "id": "meats", "name_ar": "اللحوم", "note": "مستوية تماماً", "allowed": ["الضأن", "الحمام", "الأرانب", "اللحوم الحمراء", "الكبدة", "الأسماك (مشوية أو مقلية)"], "forbidden": [] },
    { "id": "poultry", "name_ar": "الدواجن", "allowed": [], "forbidden": ["الدجاج", "الديك الرومي", "النعام", "البط", "الأوز"] },
    { "id": "fruits", "name_ar": "الفواكه", "note": "صنف واحد بالجلسة، متباعدة", "allowed": ["التفاح", "الكمثرى", "المانجو", "الجوافة", "الرمان", "الفراولة", "التمر", "التين", "العنب", "الموز"], "forbidden": ["البطيخ (ممنوع كلياً)", "الكنتالوب", "البرتقال", "اليوسفي", "الكيوي", "الكاكا", "البابايا"] },
    { "id": "drinks", "name_ar": "المشروبات", "allowed": ["عصائر الفواكه (بدون بذور)", "القهوة التركية", "الشاي الأخضر", "مشروبات الأعشاب", "خل القصب الطبيعي (يُؤكد عليه بعد الوجبات)"], "forbidden": ["المشروبات الغازية", "مشروبات الطاقة", "الشوكولاتة الداكنة"] },
    { "id": "sweets", "name_ar": "الحلويات", "allowed": ["البسبوسة", "الشوكولاتة بالحليب", "النوتيلا", "المربى", "العسل", "السكر", "الحلاوة الطحينية", "الفواكه المجففة"], "forbidden": [] },
    { "id": "nuts", "name_ar": "المكسرات", "note": "الجميع ما عدا المذكورة", "allowed": ["جميع المكسرات (عدا البندق واللوز والفول السوداني)"], "forbidden": ["البندق", "اللوز", "الفول السوداني"] },
    { "id": "pickles", "name_ar": "المخللات", "allowed": ["الزيتون فقط"], "forbidden": [] },
    { "id": "processed_grains", "name_ar": "الحبوب المعالجة", "allowed": [], "forbidden": ["خبز الدقيق الأبيض", "خبز الشوفان", "المعكرونة (حتى القمح الكامل)", "اللازانيا", "الكانيلوني", "البيتزا", "الكرواسون", "بسكويت الشوفان", "الكسكسي", "السمبوسك"] },
    { "id": "dairy", "name_ar": "الألبان", "allowed": [], "forbidden": ["الحليب السائل", "الجبن الأبيض", "القريش", "الزبادي", "الرائب", "حليب اللوز", "حليب جوز الهند"] },
    { "id": "eggs", "name_ar": "البيض", "allowed": [], "forbidden": ["البيض بجميع طرق الطهي"] },
    { "id": "legumes", "name_ar": "البقوليات", "allowed": [], "forbidden": ["الفول", "العدس", "اللوبيا", "الحمص", "الفاصوليا بأنواعها"] },
    { "id": "seafood", "name_ar": "مأكولات بحرية معينة", "allowed": [], "forbidden": ["الجمبري", "البطارخ"] }
  ],
  "behavioral_rules": [
    "الأكل عند الجوع الحقيقي فقط، والتوقف قبل الشبع الكامل",
    "لا مواعيد ثابتة للوجبات",
    "شرب الماء عند العطش فقط",
    "البروتين يوماً بعد يوم",
    "تفضيل المطبوخ على النيء",
    "صنف واحد من الفواكه في الجلسة الواحدة",
    "الصيام: الإثنين والخميس + الأيام البيض (13، 14، 15 هجرياً) + صيام متقطع",
    "خل القصب الطبيعي بعد الوجبات"
  ],
  "scoring": { "explicit_forbidden_cap": 60, "explicit_forbidden_examples": ["دجاج", "بيض", "بقوليات", "خضروات ورقية"] }
};

const RULES_JSON = JSON.stringify(RULES);

function buildPrompt(): string {
  return `أنت محلل صور طعام متخصص في نظام "الطيبات" الغذائي للدكتور ضياء العوضي.

قواعد النظام:
${RULES_JSON}

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
