// Wellness AI — `analyze` edge function (Supabase / Deno)
//
// Server-side multimodal AI proxy. The image never reaches the model with a
// device-held key. Applies the SAFETY PREAMBLE (no diagnosis/treatment/dosing),
// scores the meal against the user's active plan, and enforces the free-tier
// daily scan cap with refund-on-failure. See docs/PRD.md §8.
//
// Deploy:  supabase functions deploy analyze --no-verify-jwt
// Secrets (Supabase dashboard, NEVER in the app):
//   AI_API_KEY, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
//
// This is a SCAFFOLD: wire AI_ENDPOINT to your chosen multimodal provider and
// finalize the JSON contract consumed by app/lib/models/meal.dart.

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const AI_API_KEY = Deno.env.get("AI_API_KEY") ?? "";

const FREE_DAILY_CAP = 3;

const CORS: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "content-type,authorization,apikey",
  "Access-Control-Allow-Methods": "POST,OPTIONS",
};

const SAFETY_PREAMBLE = `
You are a general-wellness nutrition assistant. You DO NOT diagnose, treat, or
prevent disease, and you NEVER give medication or dosage advice. You provide
lifestyle/wellness information only. If asked anything clinical, defer to the
user's licensed provider. Output Arabic ("_ar") fields. Stay within the user's
active plan rules.`;

function json(status: number, obj: unknown): Response {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { "content-type": "application/json; charset=utf-8", ...CORS },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json(405, { error: "الطريقة غير مدعومة" });

  const authHeader = req.headers.get("authorization");
  if (!authHeader) return json(401, { error: "غير مصرّح" });

  // 1) Verify the caller from their access token.
  let userId: string | null = null;
  try {
    const r = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
      headers: { apikey: SERVICE_KEY, authorization: authHeader },
    });
    if (!r.ok) return json(401, { error: "جلسة غير صالحة" });
    userId = (await r.json())?.id ?? null;
  } catch {
    return json(502, { error: "تعذّر التحقق من الجلسة" });
  }
  if (!userId) return json(401, { error: "تعذّر تحديد المستخدم" });

  const body = await req.json().catch(() => ({}));
  const task = body.task ?? "analyze";

  // 2) Daily cap (image analysis only).
  if (task === "analyze") {
    const ok = await rpc("bump_usage", { p_user: userId, p_cap: FREE_DAILY_CAP });
    if (ok === false) {
      return json(429, { error: "وصلت للحد اليومي في الباقة المجانية." });
    }
  }

  try {
    // 3) Load the user's active plan rules to ground scoring.
    //    const plan = await loadActivePlan(userId, body.plan_id);

    // 4) Call the multimodal model.
    //    const result = await callAI(SAFETY_PREAMBLE, plan, body.image_base64, body.media_type);
    //
    // SCAFFOLD: return a stubbed contract so the app compiles + runs E2E.
    const result = {
      identified_items: [
        {
          name_ar: "عنصر تجريبي",
          name_en: "sample item",
          estimated_portion: "متوسطة",
          confidence: 0.9,
          zone: "green",
          reasoning_ar: "مثال — استبدله بمخرجات النموذج.",
          calories: 250,
          protein_g: 20,
          carbs_g: 18,
          fat_g: 10,
          sodium_mg: 300,
        },
      ],
      overall_score: 82,
      score_label_ar: "جيد",
      reasoning_ar: "تحليل تجريبي من السقالة. اربط مزوّد الذكاء الاصطناعي.",
      suggestions_ar: ["أضف مصدر بروتين", "قلّل الصوديوم"],
    };

    return json(200, result);
  } catch (e) {
    if (task === "analyze") await rpc("refund_usage", { p_user: userId });
    return json(502, { error: `تعذّر التحليل: ${(e as Error).message}` });
  }
});

async function rpc(fn: string, args: Record<string, unknown>) {
  const r = await fetch(`${SUPABASE_URL}/rest/v1/rpc/${fn}`, {
    method: "POST",
    headers: {
      apikey: SERVICE_KEY,
      authorization: `Bearer ${SERVICE_KEY}`,
      "content-type": "application/json",
    },
    body: JSON.stringify(args),
  });
  try {
    return await r.json();
  } catch {
    return null;
  }
}
