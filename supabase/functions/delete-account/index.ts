// Supabase Edge Function: delete-account
// Deletes the *calling* user's account and server-side data (App Store 5.1.1(v)).
// Verifies the caller from their access token, removes their usage rows, then
// deletes the auth user via the admin API (service role).
//
// Deploy (CLI):  supabase functions deploy delete-account --no-verify-jwt
// No extra secrets: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are auto-injected.
//   POST  (Authorization: Bearer <user access token>)  -> { "ok": true }

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const CORS: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "content-type,authorization,apikey",
  "Access-Control-Allow-Methods": "POST,OPTIONS",
};

function json(status: number, obj: unknown): Response {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { "content-type": "application/json; charset=utf-8", ...CORS },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json(405, { error: "الطريقة غير مدعومة" });

  if (!SUPABASE_URL || !SERVICE_KEY) {
    return json(500, { error: "الخادم غير مهيّأ" });
  }

  const authHeader = req.headers.get("authorization");
  if (!authHeader) return json(401, { error: "غير مصرّح" });

  // 1) تحقّق من هوية المُتصل عبر توكنه (لا نحذف إلا حساب صاحب الطلب).
  let userId: string | null = null;
  try {
    const userRes = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
      headers: { apikey: SERVICE_KEY, authorization: authHeader },
    });
    if (!userRes.ok) return json(401, { error: "جلسة غير صالحة" });
    const user = await userRes.json();
    userId = typeof user?.id === "string" ? user.id : null;
  } catch {
    return json(502, { error: "تعذّر التحقق من الجلسة" });
  }
  if (!userId) return json(401, { error: "تعذّر تحديد المستخدم" });

  // 2) احذف عدّاد الاستخدام الخاص به (أفضل جهد).
  try {
    await fetch(`${SUPABASE_URL}/rest/v1/usage_daily?user_id=eq.${userId}`, {
      method: "DELETE",
      headers: {
        apikey: SERVICE_KEY,
        authorization: `Bearer ${SERVICE_KEY}`,
        prefer: "return=minimal",
      },
    });
  } catch { /* تجاهل */ }

  // 3) احذف حساب المصادقة عبر واجهة المشرف.
  try {
    const delRes = await fetch(`${SUPABASE_URL}/auth/v1/admin/users/${userId}`, {
      method: "DELETE",
      headers: { apikey: SERVICE_KEY, authorization: `Bearer ${SERVICE_KEY}` },
    });
    if (!delRes.ok) {
      const body = await delRes.text();
      let msg = "تعذّر حذف الحساب";
      try { msg = JSON.parse(body)?.msg ?? JSON.parse(body)?.error_description ?? msg; } catch { /* keep */ }
      return json(delRes.status, { error: msg });
    }
  } catch (e) {
    return json(502, { error: `تعذّر حذف الحساب: ${(e as Error).message}` });
  }

  return json(200, { ok: true });
});
