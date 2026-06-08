# Wellness AI — Technical Architecture (overview)

**Version:** 0.1 · **Date:** 2026-06-08 · Pairs with [PRD.md](./PRD.md) §8–§12.

## System diagram (logical)

```
        ┌──────────────────────┐         ┌──────────────────────┐
        │  Consumer app        │         │  Provider app/web    │
        │  (Flutter, RTL AR)   │         │  (Flutter + web)     │
        └─────────┬────────────┘         └──────────┬───────────┘
                  │  HTTPS (JWT)                     │  HTTPS (JWT)
                  ▼                                  ▼
        ┌───────────────────────────────────────────────────────┐
        │                 Supabase                               │
        │  Auth (email/Google/Apple, PKCE)                       │
        │  Postgres + RLS (consent-scoped)                       │
        │  Storage (private meal images)                         │
        │  Edge Functions (Deno):                                │
        │    • analyze        → multimodal AI proxy + daily cap  │
        │    • provider-link  → invite code + consent link       │
        │    • delete-account → (todo) account/data deletion     │
        └───────┬───────────────────────────────┬───────────────┘
                │ server-only key                │ server-only key
                ▼                                ▼
        ┌────────────────┐              ┌──────────────────────┐
        │ Multimodal AI  │              │ Wearable aggregator  │
        │ provider       │              │ (Terra / Spike)      │
        │ (meal vision)  │              │ Apple Health,        │
        └────────────────┘              │ Health Connect,      │
                                        │ Fitbit, Oura, CGM…   │
                                        └──────────────────────┘
```

## Key decisions

1. **Single cross-platform codebase (Flutter)** for both apps to control cost;
   provider dashboard adds a responsive-web target later. Proven on Tayyibat.
2. **Server-side AI proxy.** The device never holds the model key. The proxy
   injects the safety preamble, grounds scoring in the user's active plan, and
   enforces the free-tier daily cap with refund-on-failure.
3. **Deterministic plan-fit scoring layer** on top of AI nutrition output —
   auditable green/amber/red, not a black box (trust + safety + provider buy-in).
4. **Consent as a first-class object.** A provider reads a patient's data only
   via an active `provider_links` row with matching consent flags, enforced in
   RLS. Unlink revokes immediately.
5. **Aggregator for wearables.** One integration (Terra/Spike) → 500+ devices,
   rather than N bespoke integrations. Native HealthKit/Health Connect in MVP.
6. **Privacy/security near-clinical even while wellness-positioned:** encryption
   in transit + at rest, least-privilege, audit logs on the provider side,
   data-residency option for enterprise, in-app deletion. (BRD §13.)
7. **Wellness-not-device posture** baked into prompts (no diagnosis/treatment/
   dosing) and into product copy/store listings.

## Data flow — capture a meal
1. App compresses photo → POST `/functions/v1/analyze` with JWT.
2. Function verifies user, bumps daily usage (cap), loads active plan.
3. Calls multimodal model with safety preamble + plan rules.
4. Returns items + portions + macros/micros + plan-fit score (+ Arabic reasoning).
5. App saves meal (image to private storage; row in `meals`/`food_items`).
6. If the user is linked + consented, the meal is visible to the provider via RLS.

## Cost control
Cheap-model-first routing → escalate on low confidence; cache recognized dishes;
editable food DB to cut repeat inference; free-tier caps. (BRD §16.)

## Build-vs-buy (open — PRD §17)
Meal recognition: foundation multimodal model + MENA grounding vs a specialized
food-vision API. Aggregator: Terra vs Spike vs direct. Decide in planning.
