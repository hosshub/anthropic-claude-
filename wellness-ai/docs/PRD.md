# Wellness AI — Product Requirements Document (PRD)

**Version:** 1.0  ·  **Date:** 2026-06-08  ·  **Status:** Draft for review
**Author:** Product
**Related docs:** [BRD.md](./BRD.md) · [COMPETITIVE-ANALYSIS.md](./COMPETITIVE-ANALYSIS.md)

---

## 1. Document control

| Field | Value |
|---|---|
| Product | **Wellness AI** |
| Surfaces | **Consumer app** (iOS+Android), **Provider app/dashboard** (iOS+Android + responsive web) |
| Stack (proposed) | Flutter (mobile) · responsive web for provider · Supabase (auth, Postgres, storage, edge functions) · multimodal-AI proxy (server-side) · health-data aggregator (Terra/Spike) |
| Localization | **Arabic-first + RTL**, English secondary |
| Regulatory | General-wellness (non-diagnostic) — see BRD §13 |

> Heritage: this builds on patterns proven in the team's **Tayyibat** app
> (Flutter + Supabase + server-side multimodal-AI proxy with per-user daily caps,
> scroll-gated medical disclaimer, three-zone scoring, local + cloud data split).

---

## 2. Product overview & goals

**What it is:** a two-sided AI wellness platform. Consumers photograph meals and
get AI nutrition analysis scored against a condition-informed or elective diet
plan, plus activity/wearable tracking, recommendations and challenges. Providers
link to patients via invite codes, monitor adherence/progress, and prescribe
plans that flow into the patient app.

**Product goals**
1. Make meal logging *effortless* (photo-first, <10s per meal).
2. Make guidance *personal* (to the user's condition and/or chosen diet).
3. Make the provider relationship *first-class* (link, prescribe, monitor).
4. Be *Arabic-native* and culturally relevant.
5. Stay *delightful and safe* (wellness-positioned, disclaimer-gated).

**Non-goals (v1)**
- No diagnosis, treatment, medication dosing, or clinical alerts.
- No in-house CGM hardware (integrate, don't manufacture).
- No insurance billing/claims engine in v1 (enterprise phase).
- No social network / public feed in v1.

---

## 3. Personas

### Consumer personas
- **Layla, 34 — PCOS (S1).** Endocrinologist told her to cut refined carbs. Wants
  to know if a meal "fits," hates manual logging, motivated by visible progress.
- **Omar, 47 — Type-2 diabetes (S1).** Dietitian gave a paper plan. Forgets
  details, wants reassurance, fine sharing data with his dietitian.
- **Sara, 28 — elective keto (S2).** Knows macros, wants speed + accuracy + an AI
  that understands keto rules.
- **Khalid, 39 — GLP-1 user (S3).** On Mounjaro; eating far less; worried about
  muscle loss and protein; wants reminders + symptom logging.

### Provider personas
- **Dr. Mona — dietitian (P1).** 60 clients; drowning in WhatsApp food photos;
  wants one dashboard, prescribe-once, see adherence, save time.
- **Dr. Tariq — endocrinologist (P2).** Wants patients to *follow* the plan and a
  glance at adherence before the next visit; not a heavy EHR.
- **Coach Yousef — PT (P3).** Trains 30 clients; wants diet adherence alongside
  workouts.
- **Clinic admin — Noor (P4).** Manages 8 dietitians; wants seats, branding,
  rollups, exports.

---

## 4. Core user journeys

### J1 — Consumer onboarding (light, wellness-safe)
1. Install → language (Arabic default) → sign in (email / Google / Apple).
2. **Scroll-gated medical disclaimer** (must reach end → accept).
3. Goal selection (lose/maintain/gain · manage a condition · follow a diet ·
   general wellness).
4. **Optional** condition tags (diabetes, PCOS, hypertension…) and/or diet type
   (keto, vegan, low-carb…) — framed as "personalize my plan," skippable.
5. Optional basics (age, height, weight, activity level) — minimal, never gated.
6. Optional "Do you have a provider code?" → link now or later.
7. Land on **Today**; prompt first meal scan.

### J2 — Capture & analyze a meal
1. Today → **Scan meal** → camera or library.
2. Server-side multimodal AI returns items + portions + macros/micros +
   **plan-fit score** (green/amber/red against the user's plan) + Arabic reasoning.
3. User can **correct** items/portions (feeds learning loop).
4. Save → counts toward daily targets; visible to linked provider (if consented).
5. Free tier: enforce daily scan cap with refund-on-failure (proven pattern).

### J3 — Link to a provider (invite code)
1. Provider issues a **code** (or QR) from their dashboard.
2. Patient: Settings → "Connect a provider" → enter code → **explicit consent**
   screen (what the provider will see) → linked.
3. Provider dashboard shows the patient as active; can prescribe a plan.
4. Either side can **unlink** anytime; unlinking stops data sharing immediately.

### J4 — Provider prescribes a plan
1. Provider opens patient → **Assign plan** (template or custom: targets, allowed/
   limited foods, meal structure, notes).
2. Plan flows into the patient app as their active plan; meals now scored against it.
3. Provider sees adherence (scans, scores, streaks, flags) over time.
4. Provider can message within scope and adjust the plan.

### J5 — Provider monitors a panel
1. Dashboard → patient list with adherence signals (active, slipping, at-risk).
2. Drill into a patient → meal history, trends, wearable summary, notes.
3. Export / report for a visit.

---

## 5. Information architecture

### Consumer app (bottom nav)
- **Today** — daily targets ring, plan-fit summary, scan CTA, today's meals,
  activity snapshot, next action.
- **Log / History** — meals list + monthly calendar; trends + "Wellness
  Intelligence" (see §6).
- **Plan** — active diet/condition plan, challenges, education, recommendations.
- **Move** — activity/exercise, wearable data, recommended workouts.
- **Settings** — profile, provider link, notifications, privacy, disclaimer,
  subscription, delete account.

### Provider app/dashboard
- **Patients** — panel list + adherence signals + invite-code management.
- **Patient detail** — overview, meals, trends, wearables, plan, notes, messages.
- **Plans/Templates** — build/reuse prescribable plans.
- **Practice** — seats, branding, team, billing, exports, analytics.
- **Settings** — profile, credentials, notifications, compliance.

---

## 6. Functional requirements — Consumer app

Each epic lists key features (FR-#) with acceptance criteria (AC).

### EPIC C1 — Auth & onboarding
- **FR-C1.1** Sign in with email/password, Google, **Apple** (Guideline 4.8).
  *AC:* all three work on iOS; Apple hidden on Android.
- **FR-C1.2** Scroll-gated medical disclaimer, persisted; re-readable in Settings.
  *AC:* accept button disabled until scrolled to end.
- **FR-C1.3** Goal + optional condition/diet personalization; all skippable.
  *AC:* user can finish onboarding with zero health inputs.

### EPIC C2 — AI meal capture & analysis
- **FR-C2.1** Capture via camera or library; compress client-side; send to
  server-side AI proxy. *AC:* result < ~8s on 4G for a typical photo.
- **FR-C2.2** Return per-item name (AR/EN), portion estimate, macros + key
  micros, confidence, and a **plan-fit score** (green/amber/red) with reasoning.
  *AC:* score reflects the active plan's rules.
- **FR-C2.3** **Edit/correct** items & portions; corrections persisted and fed to
  the learning loop. *AC:* edited meal recalculates totals + score.
- **FR-C2.4** Multimodal input options: photo (v1), **barcode** (v1), **text/voice
  describe** (v1.1), label OCR (v1.1).
- **FR-C2.5** Free-tier daily scan cap with **refund-on-failure**; clear upsell.
  *AC:* failed analysis does not consume quota.
- **FR-C2.6** **MENA dish recognition** prioritized in the food model/DB.

### EPIC C3 — Tracking, history & intelligence
- **FR-C3.1** Daily targets (calories + macros + condition-relevant signals, e.g.
  carbs for diabetes, sodium for hypertension, protein for GLP-1).
- **FR-C3.2** History list + **monthly calendar** with per-day color from average
  plan-fit (pattern proven in Tayyibat).
- **FR-C3.3** **Wellness Intelligence**: trends (score, weight, key nutrients),
  adherence streaks, "best/worst for you," body-response logging (energy,
  digestion, sleep impact), zone/score share over 7/30 days.
- **FR-C3.4** Optional post-meal "how do you feel" logging.

### EPIC C4 — Plans, challenges & recommendations
- **FR-C4.1** Library of **diet plans** (keto, low-carb, vegan, Mediterranean,
  high-protein, balanced) and **condition-informed** plan templates (diabetes-
  friendly, PCOS-friendly, hypertension-friendly) — all framed as lifestyle.
- **FR-C4.2** **Recommendations engine**: next-meal and weekly suggestions from
  the user's plan, history, body-responses, and (if present) wearable data.
- **FR-C4.3** **Challenges** (e.g. "14-day protein goal," "sodium-aware week")
  with progress + streaks + gamification.
- **FR-C4.4** Educational guide content (Arabic-first), disclaimer-footed.
- **FR-C4.5** **Provider-prescribed plan** supersedes elective plan when linked
  (with user awareness).

### EPIC C5 — Activity, exercise & wearables
- **FR-C5.1** Manual + auto activity logging.
- **FR-C5.2** **Wearable/health integration** via aggregator: Apple Health,
  Google Health Connect, Fitbit, Apple Watch, Oura, Garmin, WHOOP, and **CGM**
  feeds where available. *AC:* steps, workouts, heart rate, sleep, and (if
  connected) glucose appear in-app.
- **FR-C5.3** **Exercise recommendations** aligned to the user's diet/goal (e.g.
  muscle-preserving strength cues for GLP-1 users) — wellness-framed, non-medical.

### EPIC C6 — GLP-1 companion mode (premium)
- **FR-C6.1** Optional mode: **protein-forward** targets, muscle-preservation
  nudges, **injection/medication reminders** (reminder only — no dose advice),
  **digestive-symptom logging**, GLP-1-aware meal suggestions.
  *AC:* no dosage recommendations anywhere; disclaimer reinforced.

### EPIC C7 — Provider link & sharing (consumer side)
- **FR-C7.1** Enter provider invite code/QR → **explicit consent** screen listing
  exactly what's shared → link.
- **FR-C7.2** View who I'm linked to and what they can see; **unlink** anytime
  (immediate effect). *AC:* unlink stops all sharing within seconds.
- **FR-C7.3** Receive prescribed plan + provider messages (scoped).

### EPIC C8 — Account, privacy & monetization
- **FR-C8.1** **In-app account + data deletion** (server + local wipe).
- **FR-C8.2** Notifications: meal reminders, rotating tips, plan nudges,
  challenge/streak, GLP-1 reminders — local, per-type toggles.
- **FR-C8.3** Subscription management (free vs premium; family).
- **FR-C8.4** Data export (consumer's own data).

---

## 7. Functional requirements — Provider dashboard

### EPIC P1 — Provider onboarding & practice
- **FR-P1.1** Provider sign-up with role (dietitian/physician/trainer/coach) +
  credential capture; practice profile + branding.
- **FR-P1.2** Seats/team management; roles & permissions.
- **FR-P1.3** Subscription tiers (free starter ≤5 patients → paid seats).

### EPIC P2 — Patient linking
- **FR-P2.1** Generate **invite codes / QR** (single-use or reusable; expiry).
- **FR-P2.2** Patient list with status (invited, linked, active, slipping).
- **FR-P2.3** Consent-aware: see only what the patient consented to share.

### EPIC P3 — Monitoring
- **FR-P3.1** Patient overview: adherence %, recent meals + scores, trends,
  wearable summary, flags (e.g. repeated red meals, missed days).
- **FR-P3.2** Meal-level drill-down with AI analysis + patient corrections.
- **FR-P3.3** Panel view: sort/filter by risk/adherence; "needs attention" queue.
- **FR-P3.4** Export/report (PDF/CSV) for a visit.

### EPIC P4 — Prescribing & communication
- **FR-P4.1** Build **plan templates** (targets, allowed/limited foods, structure,
  notes) and assign to patients in ≤2 taps.
- **FR-P4.2** Adjust a patient's plan; changes reflect in patient app.
- **FR-P4.3** Scoped in-app **messaging** with the patient (wellness guidance;
  not a diagnostic channel; disclaimer-bounded).

### EPIC P5 — Enterprise (later phase)
- **FR-P5.1** Clinic/hospital admin: many providers, rollup analytics, SSO,
  data-residency, audit logs, branded patient experience, B2B2C billing.

---

## 8. AI / ML requirements

- **AI-1 Meal recognition (multimodal):** image → items + portions + macros/
  micros + confidence. Prioritize **MENA dishes**. Server-side proxy (keys never
  on device). Cheap-model-first routing; escalate to stronger model on low
  confidence; cache recognized dishes to cut cost.
- **AI-2 Plan-fit scoring:** deterministic rules layer on top of AI nutrition
  output, parameterized by the active plan (condition-informed or elective) →
  green/amber/red + Arabic reasoning. Rules are auditable (not a black box) for
  safety + provider trust.
- **AI-3 Recommendations engine:** next-meal + weekly plan generation constrained
  to the user's plan, history, body-responses, wearable signals. Safety preamble
  prevents medical claims (proven in Tayyibat's analyze/suggest/plan tasks).
- **AI-4 Learning loop:** user corrections + provider feedback improve the food
  DB and model prompts/grounding over time.
- **AI-5 Safety guardrails:** never output diagnosis, treatment, or medication
  dosing; refuse/deflect clinical questions to "consult your provider"; confidence
  surfaced to users; human-verify option for accuracy-critical cases.

---

## 9. Integrations

| Integration | Purpose | Approach |
|---|---|---|
| Apple Health / HealthKit | activity, workouts, HR, sleep, weight | Aggregator SDK + native |
| Google Health Connect | same on Android | Aggregator SDK + native |
| Fitbit, Oura, Garmin, WHOOP | wearables breadth | **Terra/Spike-style aggregator** (500+ devices, one integration) |
| Apple Watch | activity/workout | via HealthKit |
| CGM (Dexcom/Libre/Stelo) where available | glucose context | Aggregator CGM feed (read-only, wellness) |
| Auth providers (Apple/Google) | sign-in | Supabase Auth |
| Payments | subscriptions | App Store / Play billing + local rails for MENA |
| Push/local notifications | reminders | Local notifications (no PHI in payload) |

---

## 10. Data model (high level)

- **User** (consumer): profile, goals, optional condition tags, diet prefs,
  consent records.
- **Provider**: profile, role, credentials, practice, seats.
- **Link** (patient↔provider): status, consent scope, timestamps. *Consent is a
  first-class object; unlink revokes immediately.*
- **Plan**: type (elective/condition-informed/provider-prescribed), targets,
  rules, owner (system/provider), assignment.
- **Meal**: image ref, AI items + portions + macros/micros, corrections,
  plan-fit score, timestamp.
- **BodyResponse / WellnessLog**: energy, digestion, sleep, symptoms.
- **Activity/WearableData**: normalized metrics from aggregator.
- **Message**: scoped provider↔patient.
- **Subscription/Usage**: tier, scan-quota counters.

**Data split (privacy):** sensitive logs default to the user's control; provider
sees only consented data; enterprise gets data-residency options. (Mirrors
Tayyibat's local-first + minimal-server pattern, extended for the provider loop.)

---

## 11. Non-functional requirements

- **Performance:** meal analysis < ~8s typical; app cold start < 3s; smooth RTL.
- **Reliability:** refund-on-failure for scans; offline read of history/plans.
- **Localization:** **Arabic-first + full RTL**; English; locale-aware dates,
  Hijri where relevant; MENA food/units.
- **Accessibility:** dynamic type, VoiceOver/TalkBack labels (Arabic), contrast.
- **Cross-platform:** single Flutter codebase (iOS+Android) to control cost.
- **Observability:** crash reporting (privacy-respecting, EU option), product
  analytics with consented, PHI-safe events.
- **Scalability:** stateless AI proxy; cache; queue heavy jobs.

---

## 12. Privacy, security & compliance

- **HIPAA-readiness** for US providers; **GDPR** for EU; **Saudi PDPL / UAE**
  alignment; data-residency for enterprise.
- **Encryption** in transit + at rest; least-privilege access; audit logs on the
  provider side; secrets server-side only (never in app).
- **Consent-first sharing:** nothing reaches a provider without explicit,
  revocable patient consent; clear "what they can see" UI.
- **In-app deletion** (account + data) with SLA; export on request.
- **App-store compliance:** Apple 4.8 (Apple sign-in), 5.1.1(v) (deletion),
  health-data rules; Google Play Data Safety + health declarations.
- **Wellness posture:** no diagnostic/treatment claims in app, store listing, or
  marketing (BRD §13).

---

## 13. Freemium gating matrix

| Capability | Free | Premium | Provider-linked |
|---|---|---|---|
| AI meal scans/day | Capped (1–3) | Unlimited | Per plan |
| Diet/condition plans | 1 active | All | Provider-assigned |
| Wellness Intelligence | Basic | Full | Full |
| Wearable sync | Limited | Full | Full |
| Challenges | Limited | Full | Provider-set |
| GLP-1 companion | ❌ | ✅ | If prescribed |
| Provider link | ✅ (always free for patients) | ✅ | ✅ |
| Export | ❌ | ✅ | ✅ |

> **Provider linking is always free for patients** — the loop is the growth
> engine; never gate it.

---

## 14. Analytics & instrumentation

Track the KPI tree (BRD §7): acquisition (installs, code redemptions),
activation (onboarding %, first scan <24h, link rate), engagement (scans/week,
DAU/MAU, provider logins, plans prescribed), retention (D1/D7/D30, linked-pair
retention), monetization (free→paid, ARPU, provider MRR, churn), AI quality
(accuracy, correction rate, Arabic-dish accuracy), trust/safety. **North star:
Weekly Active Linked Pairs.** All events PHI-safe + consent-gated.

---

## 15. MVP scope (Phase 0–1) vs later

### MVP (must-have to prove the wedge)
- Consumer: auth + disclaimer, AI photo scan + barcode, tracking + history +
  calendar, plan library (elective + condition-informed templates), basic
  Wellness Intelligence, notifications, freemium caps, account deletion,
  Arabic-first.
- Provider: sign-up, **invite codes**, patient list + monitoring, **prescribe
  plan**, basic messaging, free starter tier.
- One health integration (Apple Health / Health Connect).
- Wellness-safe positioning + disclaimers.

### Fast-follow (Phase 2)
- Aggregator-based broad wearable/CGM support; recommendations engine;
  challenges; **GLP-1 companion**; voice/text logging; richer provider analytics.

### Later (Phase 3–4)
- Enterprise/clinic admin, SSO, data-residency, B2B2C billing; global English;
  more conditions/diets; marketplace; evidence/outcome studies.

---

## 16. Release plan / milestones (indicative)

| Milestone | Contents |
|---|---|
| **M1 — Consumer alpha** | Auth, disclaimer, AI scan, tracking, 1 plan, Arabic |
| **M2 — Consumer beta** | History/calendar, plans library, intelligence, freemium, deletion |
| **M3 — Provider beta** | Dashboard, invite codes, monitoring, prescribe plan |
| **M4 — Linked GA (KSA/UAE/Egypt)** | End-to-end loop, 1 wearable, notifications |
| **M5 — Intelligence** | Aggregator wearables/CGM, recommendations, challenges, GLP-1 |
| **M6 — Enterprise** | Clinic admin, analytics, B2B2C, English |

---

## 17. Open questions

1. Exact regional consumer price points (KSA/UAE/Egypt) and payment rails?
2. Provider credential-verification depth at launch (self-attest vs verified)?
3. Which conditions ship in MVP plan templates (diabetes + PCOS + hypertension)?
4. Build vs buy for the meal-recognition model (foundation model + MENA grounding
   vs specialized food-vision API)?
5. Aggregator choice (Terra vs Spike vs direct) for cost/coverage/latency?
6. Messaging scope — how far before it risks looking like clinical care?
7. Data-residency requirements per target market (esp. Saudi PDPL)?
8. Evidence strategy — pursue a Klinio-style adherence/outcome pilot early?

---

*This PRD pairs with the BRD (business case) and Competitive Analysis (market
evidence). Treat as living; revise per milestone.*
