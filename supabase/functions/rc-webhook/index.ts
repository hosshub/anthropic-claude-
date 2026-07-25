// Supabase Edge Function: rc-webhook (RevenueCat → user_entitlements)
//
// RevenueCat POSTs here on every subscription lifecycle event. We translate the
// event into a row in public.user_entitlements so the `analyze` function can
// enforce the AI-scan cap server-side — the client is never trusted for this.
//
// Deploy:  supabase functions deploy rc-webhook --no-verify-jwt
// Secret:  supabase secrets set RC_WEBHOOK_SECRET=<same value set in RevenueCat>
// In RevenueCat: Integrations → Webhooks → URL = this function,
//                Authorization header = the same secret.
//
// RevenueCat must be configured with app_user_id == the Supabase auth user id,
// which the client does via Purchases.logIn(session.user.id).

const RC_WEBHOOK_SECRET = Deno.env.get("RC_WEBHOOK_SECRET") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

/** Events that mean "this user should have premium right now". */
const GRANTING = new Set([
  "INITIAL_PURCHASE",
  "RENEWAL",
  "UNCANCELLATION",
  "NON_RENEWING_PURCHASE", // lifetime unlock
  "PRODUCT_CHANGE",
  "SUBSCRIPTION_EXTENDED",
  "TEMPORARY_ENTITLEMENT_GRANT",
]);

/** Events that mean "revoke now". CANCELLATION is deliberately absent: a
 *  cancelled subscription stays active until it expires. */
const REVOKING = new Set(["EXPIRATION", "SUBSCRIPTION_PAUSED", "REFUND"]);

function json(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json; charset=utf-8" },
  });
}

async function setEntitlement(
  userId: string,
  tier: "free" | "premium",
  expiresAt: string | null,
): Promise<boolean> {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/rpc/set_entitlement`, {
    method: "POST",
    headers: {
      apikey: SERVICE_KEY,
      authorization: `Bearer ${SERVICE_KEY}`,
      "content-type": "application/json",
    },
    body: JSON.stringify({
      p_user: userId,
      p_tier: tier,
      p_expires_at: expiresAt,
      p_source: "revenuecat",
    }),
  });
  if (!res.ok) console.error(`set_entitlement failed: ${await res.text()}`);
  return res.ok;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return json(405, { error: "Method not allowed" });

  // RevenueCat sends the shared secret in the Authorization header verbatim.
  if (!RC_WEBHOOK_SECRET) {
    console.error("RC_WEBHOOK_SECRET is not configured");
    return json(500, { error: "Server not configured" });
  }
  if (req.headers.get("authorization") !== RC_WEBHOOK_SECRET) {
    return json(401, { error: "Unauthorized" });
  }

  let payload: { event?: Record<string, unknown> };
  try {
    payload = await req.json();
  } catch {
    return json(400, { error: "Invalid body" });
  }

  const event = payload.event ?? {};
  const type = String(event.type ?? "");
  const userId = String(event.app_user_id ?? "");

  // Anonymous RevenueCat ids ($RCAnonymousID:...) belong to users who never
  // signed in; there is no Supabase user to attach them to.
  if (!userId || userId.startsWith("$RCAnonymousID")) {
    return json(200, { ok: true, skipped: "anonymous" });
  }

  if (GRANTING.has(type)) {
    const ms = Number(event.expiration_at_ms ?? 0);
    // Lifetime (non-renewing) purchases have no expiry.
    const expiresAt = Number.isFinite(ms) && ms > 0
      ? new Date(ms).toISOString()
      : null;
    const ok = await setEntitlement(userId, "premium", expiresAt);
    return json(ok ? 200 : 500, { ok, tier: "premium", type });
  }

  if (REVOKING.has(type)) {
    const ok = await setEntitlement(userId, "free", null);
    return json(ok ? 200 : 500, { ok, tier: "free", type });
  }

  // Everything else (CANCELLATION, BILLING_ISSUE, TEST…) is acknowledged but
  // changes nothing: access continues until the period actually expires.
  return json(200, { ok: true, ignored: type });
});
