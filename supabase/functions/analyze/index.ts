// Supabase Edge Function: analyze (Google Gemini)
// Holds the Gemini API key as a Supabase secret and serves the Tayyibat app:
//   - meal-image analysis (image_base64)
//   - tayyib meal suggestion (task: "suggest")
//   - weekly meal plan (task: "plan")
// so the key never ships in the app.
//
// Deploy (CLI):   supabase functions deploy analyze --no-verify-jwt
// Secret:         supabase secrets set GEMINI_API_KEY=...      (from Google AI Studio)
// Optional:       supabase secrets set GEMINI_MODEL=gemini-2.5-flash-lite
// Endpoint:       https://<project-ref>.supabase.co/functions/v1/analyze
//   GET  -> { "ok": true }
//   POST { "image_base64": "...", "media_type": "image/jpeg" } -> analysis JSON
//   POST { "task": "suggest" }                                 -> meal suggestion JSON
//   POST { "task": "plan" }                                    -> weekly plan JSON

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") ?? "";
const GEMINI_MODEL = Deno.env.get("GEMINI_MODEL") ?? "gemini-2.5-flash-lite";
const APP_TOKEN = Deno.env.get("APP_TOKEN") ?? "";

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

// قاعدة مشتركة لكل المهام: لا ادعاءات طبية إطلاقاً.
const SAFETY_PREAMBLE =
  `لا تذكر أي ادعاءات صحية أو علاجية، ولا تدّعِ أن النظام يعالج أو يشفي أي مرض، ولا تذكر الأدوية إطلاقاً. التزم بقوائم النظام فقط.`;

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

${SAFETY_PREAMBLE}
كن متحفظاً — إذا كنت غير متأكد من عنصر، ضع confidence أقل من 0.7 ونبّه المستخدم للمراجعة في warnings.`;
}

function buildSuggestPrompt(): string {
  return `أنت مساعد في نظام "الطيبات" الغذائي. قواعد النظام:
${RULES_JSON}

اقترح وجبة طيبة واحدة متكاملة من الأطعمة المسموحة (allowed) فقط، وتجنّب تماماً أي طعام ممنوع (forbidden). راعِ القواعد السلوكية (صنف فاكهة واحد، تفضيل المطبوخ، خل القصب بعد الوجبة).

أرجع JSON فقط (بدون markdown) بهذه البنية بالضبط:
{
  "name_ar": "اسم مختصر للوجبة المقترحة",
  "components_ar": ["مكوّن 1", "مكوّن 2", "مكوّن 3"],
  "reasoning_ar": "جملة أو جملتان عن سبب كون الوجبة طيبة وفق النظام",
  "best_time_ar": "وقت مناسب للوجبة (مثلاً: فطور، غداء، عشاء خفيف)"
}

${SAFETY_PREAMBLE}`;
}

function buildPlanPrompt(): string {
  return `أنت مساعد في نظام "الطيبات" الغذائي. قواعد النظام:
${RULES_JSON}

ولّد خطة وجبات لأسبوع كامل (٧ أيام تبدأ بالسبت وتنتهي بالجمعة) من الأطعمة المسموحة (allowed) فقط، مع تجنّب كل الممنوعات (forbidden). راعِ: البروتين يوماً بعد يوم، صنف فاكهة واحد في الجلسة، تفضيل المطبوخ، وأيام الصيام المستحبة (الإثنين والخميس) بإفطار على طعام طيّب.

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

// نداء Gemini موحّد: يستقبل أجزاء المحتوى ويُرجع كائن JSON المُحلَّل أو خطأ.
async function callGemini(parts: unknown[], maxTokens: number): Promise<Response> {
  const endpoint =
    `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`;
  let upstream: Response;
  let raw: string;
  try {
    upstream = await fetch(endpoint, {
      method: "POST",
      headers: { "x-goog-api-key": GEMINI_API_KEY, "content-type": "application/json" },
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
    return json(502, { error: `تعذّر الاتصال بـ Gemini: ${(e as Error).message}` });
  }

  if (!upstream.ok) {
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
      const reason = candidate?.finishReason ?? data.promptFeedback?.blockReason;
      // رسالة ألطف عند رفض مرشّح الأمان لصورة طعام.
      if (reason === "SAFETY") {
        return json(502, { error: "تعذّر تحليل الصورة. حاول من زاوية أو إضاءة مختلفة." });
      }
      return json(502, { error: `لم يُرجِع النموذج نتيجة${reason ? ` (${reason})` : ""}` });
    }
    return json(200, JSON.parse(stripFences(text)));
  } catch {
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

  let payload: { image_base64?: string; media_type?: string; task?: string };
  try {
    payload = await req.json();
  } catch {
    return json(400, { error: "جسم الطلب غير صالح" });
  }

  // 1) اقتراح وجبة
  if (payload.task === "suggest") {
    return await callGemini([{ text: buildSuggestPrompt() }], 1024);
  }
  // 2) خطة أسبوعية
  if (payload.task === "plan") {
    return await callGemini([{ text: buildPlanPrompt() }], 4096);
  }

  // 3) تحليل صورة (الافتراضي)
  const imageBase64 = payload.image_base64;
  const mediaType = payload.media_type ?? "image/jpeg";
  if (!imageBase64) return json(400, { error: "image_base64 مطلوب" });

  return await callGemini([
    { inlineData: { mimeType: mediaType, data: imageBase64 } },
    { text: buildPrompt() },
  ], 2048);
});
