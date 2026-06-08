// Wellness AI — `provider-link` edge function (Supabase / Deno)
//
// Redeems a provider invite code and creates a consent-scoped patient<->provider
// link. The patient must be authenticated; the link records exactly what the
// provider may see. See docs/PRD.md EPIC C7 / P2.
//
// Deploy:  supabase functions deploy provider-link --no-verify-jwt
//
// POST { code, consent_meals?, consent_activity?, consent_body_logs? }
//   -> { ok: true, provider_id }

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

  const authHeader = req.headers.get("authorization");
  if (!authHeader) return json(401, { error: "غير مصرّح" });

  // Verify patient identity.
  let patientId: string | null = null;
  try {
    const r = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
      headers: { apikey: SERVICE_KEY, authorization: authHeader },
    });
    if (!r.ok) return json(401, { error: "جلسة غير صالحة" });
    patientId = (await r.json())?.id ?? null;
  } catch {
    return json(502, { error: "تعذّر التحقق من الجلسة" });
  }
  if (!patientId) return json(401, { error: "تعذّر تحديد المستخدم" });

  const body = await req.json().catch(() => ({}));
  const code = (body.code ?? "").toString().trim();
  if (!code) return json(400, { error: "رمز الدعوة مطلوب" });

  // Look up the invite code.
  const codeRows = await rest(
    `invite_codes?code=eq.${encodeURIComponent(code)}&select=code,provider_id,reusable,expires_at`,
  );
  const invite = Array.isArray(codeRows) ? codeRows[0] : null;
  if (!invite) return json(404, { error: "رمز غير صالح" });
  if (invite.expires_at && new Date(invite.expires_at) < new Date()) {
    return json(410, { error: "انتهت صلاحية الرمز" });
  }

  // Create / upsert the consent-scoped link.
  const upsert = await fetch(`${SUPABASE_URL}/rest/v1/provider_links`, {
    method: "POST",
    headers: {
      apikey: SERVICE_KEY,
      authorization: `Bearer ${SERVICE_KEY}`,
      "content-type": "application/json",
      prefer: "resolution=merge-duplicates,return=minimal",
    },
    body: JSON.stringify({
      provider_id: invite.provider_id,
      patient_id: patientId,
      status: "linked",
      consent_meals: body.consent_meals ?? true,
      consent_activity: body.consent_activity ?? true,
      consent_body_logs: body.consent_body_logs ?? true,
      linked_at: new Date().toISOString(),
      unlinked_at: null,
    }),
  });
  if (!upsert.ok) {
    return json(502, { error: "تعذّر إنشاء الربط" });
  }

  // Single-use codes get consumed.
  if (!invite.reusable) {
    await fetch(
      `${SUPABASE_URL}/rest/v1/invite_codes?code=eq.${encodeURIComponent(code)}`,
      {
        method: "DELETE",
        headers: { apikey: SERVICE_KEY, authorization: `Bearer ${SERVICE_KEY}` },
      },
    );
  }

  return json(200, { ok: true, provider_id: invite.provider_id });
});

async function rest(path: string) {
  const r = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    headers: { apikey: SERVICE_KEY, authorization: `Bearer ${SERVICE_KEY}` },
  });
  try {
    return await r.json();
  } catch {
    return null;
  }
}
