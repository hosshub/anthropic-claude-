# Wellness AI

> **Wellness AI** — the Arabic-first AI wellness platform where you photograph
> your meal and your doctor, dietitian, or coach sees your progress. A two-sided
> product: a delightful consumer app + a provider dashboard, connected by an
> invite code, so a prescribed or chosen diet becomes a living, tracked, guided
> plan.

This folder holds the strategy + spec for a **new product** distinct from the
Tayyibat app in this repo. It reuses Tayyibat's proven stack and patterns
(Flutter + Supabase + server-side multimodal-AI proxy, scroll-gated disclaimer,
three-zone scoring, freemium caps) but is its own business.

---

## Documents

| Doc | What it covers |
|---|---|
| **[docs/BRD.md](./docs/BRD.md)** | Business Requirements — vision, market, segments, business model, monetization, partnerships, regulatory strategy, risks, roadmap, unit economics |
| **[docs/PRD.md](./docs/PRD.md)** | Product Requirements — personas, journeys, IA, functional requirements (consumer + provider), AI/ML, integrations, data model, privacy, freemium gating, MVP scope, milestones |
| **[docs/COMPETITIVE-ANALYSIS.md](./docs/COMPETITIVE-ANALYSIS.md)** | Market size, competitor map, detailed profiles, feature matrix, pricing tables, gap analysis, positioning, sources |

---

## The one-paragraph thesis

AI calorie scanners (Cal AI, SnapCalorie, MyFitnessPal) are single-sided consumer
apps with no clinician relationship. Provider platforms (Healthie, Practice
Better, Nutrium) own the clinical relationship but have weak, patient-unfriendly
consumer AI. **Nobody owns both — and nobody owns both in Arabic.** Wellness AI
combines consumer-grade AI meal scanning, multi-condition + multi-diet breadth, a
provider-prescription loop, GLP-1 readiness, and MENA localization, in the
fastest-growing fitness-app region on earth.

---

## Why this can win (defensible moats)

1. **The provider loop** — invite-code linking + prescribe-plan-into-patient-app
   creates two-sided lock-in; every prescribing provider is a distribution
   channel.
2. **Arabic-first + MENA food intelligence** — no serious AI scanner recognizes
   machboos, koshari, mandi, or labels in Arabic.
3. **GLP-1-ready** — protein-forward, muscle-preserving, symptom-aware support for
   the dominant 2026 demand wave (without making drug claims).
4. **Aggregator-based wearable breadth** — 500+ devices via Terra/Spike on day one.
5. **Wellness-positioned, not device-classified** — move fast across app stores
   and borders while clinical platforms carry regulatory drag.

---

## Additional features worth considering (from the research)

Beyond the brief, these surfaced as high-leverage during competitive research.
Prioritization lives in PRD §15.

**Engagement & retention**
- **Challenges + streaks + leaderboards** (Noom-style behavior science, but
  AI-assisted and provider-settable).
- **Body-response logging** (energy / digestion / sleep) feeding a "what works for
  *you*" insight engine — a differentiator vs pure calorie counters.
- **Family / household plans** (shared cooking is cultural in MENA).

**AI depth**
- **Multimodal logging beyond photos:** barcode, **voice/text describe**, label
  OCR, restaurant-menu lookup — meet users where logging friction is highest.
- **Editable food DB + correction learning loop** — accuracy compounding moat,
  especially for regional dishes.
- **Confidence display + optional human verification** for accuracy-critical
  users (SnapCalorie does the latter well).

**Clinical-adjacent (wellness-safe)**
- **GLP-1 companion mode** (premium; rides the wave).
- **Condition-aware target signals** (carbs for diabetes, sodium for hypertension,
  protein for GLP-1) — personalization without diagnosis.
- **Provider report export** (PDF/CSV) for visits — saves provider time, builds
  trust.
- **Adherence "needs attention" queue** for providers managing large panels.

**Data & ecosystem**
- **CGM data integration** (read-only) for users who already wear one — context
  without manufacturing hardware.
- **Wearable-driven exercise recommendations** aligned to the diet/goal.

**Trust & growth**
- **Evidence pilot** (Klinio-style adherence/HbA1c case study) for clinical
  credibility and enterprise sales.
- **Enterprise/clinic admin + B2B2C billing** — highest-margin lane.
- **Halal/regional food authority partnerships** for credibility.

---

## Pricing posture (directional — see COMPETITIVE-ANALYSIS §6)

- **Consumer freemium:** free tier capped (1–3 AI scans/day, 1 plan); premium
  **region-localized, deliberately under MyFitnessPal/Noom** (~$4–7/mo or
  ~$39–59/yr equivalent; SAR/EGP tiers); family add-on.
- **Provider SaaS:** **free starter (≤5 patients)** to seed supply → paid seats
  (~$19–49/seat/mo), benchmarked to Practice Better / Nutrium.
- **Enterprise / payer / employer:** per-covered-life or per-active-patient —
  highest margin, strongest moat.
- **GLP-1 companion:** premium add-on / retention lever.

> **Always free for patients to link a provider** — the loop is the growth engine.

---

## Regulatory north star

Stay firmly on the **general-wellness** side of the line (2026 FDA guidance): no
diagnosis, no treatment claims, no medication dosing, no clinical alerts. The
**licensed provider** makes clinical judgments; the app is a tracking +
communication tool. Mandatory scroll-gated disclaimer; privacy near-clinical
(HIPAA-ready, GDPR, Saudi PDPL). Details in BRD §13.

---

## Status

Strategy + spec drafted (this folder). Next steps: validate pricing + regional
go-to-market, choose the meal-recognition build-vs-buy, recruit founding
providers, and scope the MVP per PRD §15. These are **planning documents**, not
code — when build starts, the recommended foundation is the same Flutter +
Supabase + multimodal-AI-proxy stack proven in Tayyibat.

*Last updated: 2026-06-08.*
