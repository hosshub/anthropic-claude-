# Wellness AI — Backend (Supabase)

Postgres schema + Deno edge functions powering the consumer app and provider
dashboard.

## Layout
```
backend/
├── sql/0001_init.sql        # schema: profiles, plans, links+consent, meals,
│                            #   food_items, body_logs, wearable_daily, messages,
│                            #   usage_daily + bump/refund RPCs, RLS sketch
└── functions/
    ├── analyze/index.ts        # multimodal AI proxy (safety preamble, daily cap)
    └── provider-link/index.ts  # invite-code redemption + consent-scoped link
```

## Setup
1. Create a Supabase project; copy the URL + **publishable (anon)** key into the
   app's `lib/config.dart` (or pass via `--dart-define`).
2. Apply the schema:
   ```bash
   supabase db push          # or paste sql/0001_init.sql in the SQL editor
   ```
3. Set function secrets (dashboard → Edge Functions → Secrets) — **never in the app**:
   - `AI_API_KEY` (your multimodal provider)
   - `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` (auto-injected, but referenced)
4. Deploy functions (they verify the user JWT themselves):
   ```bash
   supabase functions deploy analyze --no-verify-jwt
   supabase functions deploy provider-link --no-verify-jwt
   ```

## To finish (scaffold TODOs)
- `analyze`: wire `AI_API_KEY` to your chosen multimodal model; load the user's
  active plan to ground plan-fit scoring; finalize the JSON contract consumed by
  `app/lib/models/meal.dart`.
- Add `delete-account` (App Store 5.1.1(v)) — port from Tayyibat.
- **Tighten RLS policies** before any real data (see comments in the SQL).
- Add provider-side endpoints: generate invite codes, assign plan, panel reads.

## Security non-negotiables
- Only the Supabase URL + anon key live in the app. `AI_API_KEY` and the
  service-role key are server-only secrets.
- Consent is enforced in RLS: a provider reads a patient's rows only via an
  active `provider_links` row with the matching consent flag.
