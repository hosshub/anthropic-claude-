# Wellness AI — Business Requirements Document (BRD)

**Version:** 1.0  ·  **Date:** 2026-06-08  ·  **Status:** Draft for review
**Author:** Product / Strategy
**Related docs:** [PRD.md](./PRD.md) · [COMPETITIVE-ANALYSIS.md](./COMPETITIVE-ANALYSIS.md)

---

## 1. Document control

| Field | Value |
|---|---|
| Product name | **Wellness AI** |
| Product type | Two-sided AI wellness platform (consumer app + provider dashboard) |
| Platforms | iOS + Android (consumer); iOS/Android + responsive web (provider) |
| Primary market | MENA (Arabic-first), then global English |
| Business model | Freemium consumer + B2B SaaS provider + B2B2C payer/employer |
| Regulatory stance | **General-wellness** (non-diagnostic, non-treatment) — see §13 |

---

## 2. Executive summary

Wellness AI is an **AI-powered, condition- and diet-aware nutrition + wellness
platform** with two connected sides:

1. **Consumer app** — a user photographs a meal; multimodal AI identifies items,
   estimates portions and macros/micros, scores the meal against the user's
   chosen plan (whether that plan is condition-informed — diabetes, PCOS,
   hypertension, pre-diabetes — or elective — keto, vegan, low-carb,
   Mediterranean, high-protein), tracks activity and wearable data, and serves a
   personalized recommendations + challenges engine.

2. **Provider app/dashboard** — doctors, dietitians, nutritionists, personal
   trainers and coaches issue an **invite code**. The patient links their app to
   the provider, who then sees the patient's meals, adherence and progress and
   can **"prescribe" a structured plan that flows into the patient's app** —
   turning a paper diet handout into a living, tracked, guided program.

The wedge is structural: **AI consumer scanners have no clinician relationship,
and clinical platforms have no consumer-grade AI — nobody owns both, and nobody
owns both in Arabic.** (See COMPETITIVE-ANALYSIS.md §4–§7.)

The platform is **Arabic-first** with MENA food intelligence, **GLP-1-ready** to
ride the dominant 2026 demand wave, and **deliberately positioned as general
wellness** to move fast across app stores and borders without medical-device
classification.

---

## 3. Business context & problem statement

### Problems we solve

| Stakeholder | Pain today |
|---|---|
| **Patient with a condition** | The doctor hands over a diet on paper. It's hard to follow, easy to misinterpret, impossible to stick to without feedback, and the doctor never sees what actually happened between visits. |
| **Elective dieter** | Generic calorie apps don't understand *their* diet's rules; logging is tedious; motivation fades; no expert in the loop. |
| **Doctor / dietitian / trainer** | No lightweight way to monitor a patient's real eating between appointments. Clinical SaaS is heavy and patient-unfriendly; consumer apps don't report back. Adherence is a black box. |
| **MENA users specifically** | No serious AI nutrition app speaks Arabic natively or recognizes regional dishes; cultural relevance is missing. |

### Why now

- **GLP-1 surge**: tens of millions of new medication users need protein-forward,
  muscle-preserving, side-effect-aware nutrition support — a net-new market.
- **AI inflection**: multimodal models make photo→nutrition viable and cheap.
- **MENA tailwind**: fastest-growing fitness-app region (Saudi ~22% CAGR);
  localized Arabic content demonstrably wins adoption.
- **Regulatory clarity**: 2026 FDA general-wellness guidance gives a clear,
  broader safe-harbor for non-diagnostic wellness software.

---

## 4. Vision & mission

- **Vision:** Make every prescribed or chosen diet *followable* — with AI in your
  pocket and your provider in the loop.
- **Mission:** Give people a delightful AI wellness companion, and give their
  providers a window into real progress — Arabic-first, globally capable.

---

## 5. Market opportunity

(Full figures + sources in COMPETITIVE-ANALYSIS.md §2.)

- Digital Health + Nutrition Integration: **$13.5B (2025) → $35.8B (2033)**.
- U.S. Digital Dietitian: **$655M (2025) → $1.8B (2035)**.
- Middle East Fitness Apps: **$400M (2024) → $1.1B (2033)**, Saudi ~22% CAGR.
- The **provider/clinical lane grows as fast as consumer and is far less
  AI-saturated** — our differentiated entry point.

**Serviceable beachhead:** Arabic-speaking, condition-aware and diet-following
consumers in **KSA, UAE, Egypt**, plus the **dietitians, clinics and PTs** who
serve them — expanding to global English thereafter.

---

## 6. Target market & segments

### Demand side (consumers)
- **S1 — Condition-informed:** diabetes / pre-diabetes, PCOS, hypertension,
  high cholesterol, weight management. Often arrive *via a provider*.
- **S2 — Elective dieters:** keto, low-carb, vegan/vegetarian, Mediterranean,
  high-protein, intermittent fasting, halal-conscious eating.
- **S3 — GLP-1 users:** on Ozempic/Wegovy/Mounjaro/Zepbound; need protein +
  symptom + muscle-preservation support.
- **S4 — General wellness / fitness:** weight, fitness, habit improvement.

### Supply side (providers)
- **P1 — Dietitians / nutritionists** (highest fit; primary supply).
- **P2 — Physicians / endocrinologists / GPs** (prescribe via code; trust anchor).
- **P3 — Personal trainers / coaches** (fitness + diet adherence).
- **P4 — Clinics, hospitals, corporate wellness, insurers** (enterprise / B2B2C).

### Geography
1. **Phase 1:** KSA, UAE, Egypt (Arabic-first).
2. **Phase 2:** wider GCC + Levant + North Africa.
3. **Phase 3:** global English markets.

---

## 7. Business objectives & success metrics

### Year-1 business objectives (illustrative — set real targets in planning)
- **O1** Launch consumer app (iOS+Android) + provider dashboard in KSA/UAE/Egypt.
- **O2** Seed a two-sided network: recruit founding providers; activate their
  patients via invite codes.
- **O3** Validate willingness to pay on both sides (consumer premium + provider
  SaaS).
- **O4** Establish 2–3 lighthouse hospital/clinic partnerships.

### North-star metric
**Weekly Active Linked Pairs** — a patient *and* their provider both active on a
shared plan in a given week. It captures the two-sided value no single-sided
competitor can.

### KPI tree

| Layer | KPIs |
|---|---|
| Acquisition | Consumer installs; provider sign-ups; invite-code redemptions; CAC by channel |
| Activation | % completing onboarding; first meal scanned <24h; first plan assigned; patient↔provider link rate |
| Engagement | Meals scanned/user/week; DAU/MAU; streaks; provider logins/week; plans prescribed |
| Retention | D1/D7/D30; W4/W12; provider seat retention; linked-pair retention |
| Monetization | Consumer free→paid conversion; ARPU; provider MRR/ARR; seat expansion; churn; LTV:CAC |
| AI quality | Meal-recognition accuracy; portion-estimate error; correction rate; Arabic-dish accuracy |
| Trust/safety | Disclaimer acceptance; zero medical-claim incidents; data-deletion SLA |

---

## 8. Business model & monetization

A **three-engine** model:

### Engine 1 — Consumer freemium (B2C)
- **Free:** capped AI meal scans/day (e.g. 1–3), basic tracking, 1 active plan,
  limited history, ads-free but feature-gated.
- **Premium (individual):** unlimited scans, all diet/condition plans, full
  Body/Wellness Intelligence, wearable sync, challenges, GLP-1 companion mode.
  Regionally **price-localized** and deliberately under MyFitnessPal/Noom
  (target ~$4–7/mo or ~$39–59/yr equivalent; SAR/EGP tiers).
- **Family plan** add-on.

### Engine 2 — Provider SaaS (B2B)
- **Free starter** (≤5 patients) to seed supply and word-of-mouth.
- **Per-seat tiers** (~$19–49/seat/mo) by patient volume + features (branded
  plans, analytics, messaging, export). Benchmarked to Practice Better / Nutrium.

### Engine 3 — Enterprise / payer / employer (B2B2C)
- **Per-covered-life or per-active-patient** for hospitals, insurers, corporate
  wellness, pharma disease-management programs. Highest margin; longest sales
  cycle; strongest moat.

### Adjacent / later
- **GLP-1 companion** premium add-on (rides the wave; high retention).
- **Marketplace take-rate** if we later enable paid provider↔patient consults.
- **Anonymized, consented insights** (population nutrition trends) — privacy-first,
  opt-in, never PII resale.

---

## 9. Stakeholders

| Stakeholder | Interest |
|---|---|
| Consumers (S1–S4) | Easy logging, real guidance, results, trust, Arabic |
| Providers (P1–P4) | Adherence visibility, time-saving, patient outcomes, billing fit |
| Hospitals / clinics / insurers | Outcomes, engagement, cost reduction, branding |
| Internal: Product, AI/ML, Eng, Design, Clinical advisory, Growth, Legal/Compliance | Delivery, safety, growth |
| Regulators / app stores | Wellness-not-medical compliance; privacy |
| Investors | Two-sided network, defensibility, unit economics |

---

## 10. Value proposition by segment

- **Condition-informed consumer:** "Follow your doctor's plan without guesswork —
  snap your meal, get a green/amber/red read against *your* condition, and your
  doctor sees your progress."
- **Elective dieter:** "An AI that actually understands keto/vegan/low-carb rules
  and keeps you on track."
- **GLP-1 user:** "Protect your muscle and hit your protein while you lose weight
  — with reminders and symptom logging."
- **Provider:** "See what your patients actually eat between visits, prescribe a
  plan in two taps, and prove adherence — without heavy clinical software."
- **Enterprise:** "Scale dietetic guidance to thousands of members with AI doing
  the logging and your team doing the judgment."

---

## 11. Competitive positioning (summary)

Full analysis in COMPETITIVE-ANALYSIS.md. In one line:

> The Arabic-first AI wellness platform where you photograph your meal and your
> provider sees your progress — the only player combining consumer-grade AI
> scanning, multi-condition/diet breadth, a provider-prescription loop, and MENA
> localization.

Defensible moats: (1) two-sided provider lock-in, (2) Arabic + MENA food
intelligence, (3) GLP-1 readiness, (4) aggregator-based 500+ device breadth,
(5) wellness regulatory posture enabling speed.

---

## 12. Partnerships & go-to-market

### Supply-led GTM (seed providers first)
1. **Founding-provider program:** recruit dietitians/clinics in KSA/UAE/Egypt
   with free seats + co-marketing; each provider brings their patient panel.
2. **Hospital/clinic pilots:** 2–3 lighthouse partners "prescribe" the app via
   codes; measure adherence + outcomes for case studies.
3. **PT / gym chains:** trainers as a fast, less-regulated supply channel.

### Demand-led
4. **Condition + GLP-1 content** SEO/social in Arabic + English.
5. **App-store optimization** with localized screenshots (Arabic + English).
6. **Referral loops:** provider invite codes are themselves a growth channel.

### Strategic partnerships
- Wearable/CGM data via **aggregators** (Terra/Spike) — breadth fast.
- Pharma/disease-management programs (GLP-1 manufacturers' patient support).
- Insurers / employers for B2B2C distribution.
- Halal/regional food databases + local nutrition authorities for credibility.

---

## 13. Regulatory & compliance strategy

**Principle: stay firmly on the general-wellness side of the line.** Per 2026 FDA
general-wellness guidance, software stays non-device if it does **not** diagnose,
treat, cure, mitigate, or prevent disease, and avoids diagnostic alerts or
treatment recommendations. Regulatory status is driven by **claims, labeling and
store descriptions** as much as functionality.

**Design rules (binding):**
- ❌ No diagnosis, no disease-treatment claims, no medication dosing, no
  clinical alerts. ✅ Frame condition inputs as *lifestyle personalization*
  ("plans informed by your goals"), not medical therapy.
- ✅ The **provider** — a licensed human — makes clinical judgments; the app is a
  tracking + communication tool. The app never auto-prescribes therapy.
- ✅ Mandatory, scroll-gated **medical disclaimer** at onboarding (pattern proven
  in our Tayyibat app); persistent disclaimer in guidance surfaces.
- ✅ GLP-1 features = reminders + tracking + education only; **no dose advice**.
- ✅ Privacy by design: **HIPAA-readiness** (US providers), **GDPR** (EU),
  **Saudi PDPL / UAE** data-protection alignment; data-residency options for
  enterprise; in-app account + data deletion.
- ✅ App-store compliance: Apple Guideline 4.8 (offer Sign in with Apple when
  offering social login), 5.1.1(v) account deletion, health-data handling rules;
  Google Play health/data-safety declarations.

**Boundary watch:** if a feature ever crosses into diagnosis/treatment (e.g.
auto-titrating anything, predicting disease), it triggers device classification —
gate such features behind a separate, regulated track or a licensed provider's
explicit action.

---

## 14. Risks & mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| AI accuracy on mixed/Arabic dishes | High | High | MENA food DB; human-verify option; user-correction loop that retrains; confidence display |
| Two-sided cold-start (need both sides) | High | High | Supply-led GTM; free provider seats; invite codes as growth; lighthouse clinics |
| Incumbents add similar AI (MFP, Noom) | High | Med | Moat = provider loop + Arabic + enterprise, not scanning alone |
| Regulatory drift into device territory | Med | High | Strict wellness posture (§13); legal review of every claim; provider-gated clinical actions |
| Health-data breach / privacy loss | Med | Very High | Security-by-design, encryption, least-privilege, audits, data-residency, deletion SLAs |
| Provider data expectations ≈ clinical-grade | Med | Med | Build HIPAA-ready even while "wellness"; audit logs; consent flows |
| Unit economics (AI inference cost vs free tier) | Med | Med | Cap free scans; efficient model routing; cache; tiered model quality |
| MENA payment friction / localization | Med | Med | Local payment rails, regional pricing, Arabic CS |
| Clinical trust without evidence | Med | Med | Publish adherence/outcome case studies (cf. Klinio HbA1c pilot) |

---

## 15. High-level roadmap (business phasing)

| Phase | Theme | Business outcome |
|---|---|---|
| **P0 — Foundations** | Consumer MVP: AI scan + tracking + plans, Arabic-first, disclaimer, freemium | Prove consumer delight + willingness to pay |
| **P1 — The Loop** | Provider dashboard + invite-code linking + prescribe-plan | Prove the two-sided wedge; founding providers |
| **P2 — Intelligence** | Wearable/CGM via aggregator; recommendations + challenges; GLP-1 companion | Engagement + retention + premium pull |
| **P3 — Enterprise** | Clinic/hospital admin, analytics, billing fit, B2B2C contracts | High-margin revenue + moat |
| **P4 — Scale** | Global English, more conditions/diets, marketplace, evidence studies | Expansion + defensibility |

(Detailed feature scoping in PRD.md §15–16.)

---

## 16. Financial considerations (directional)

- **Revenue lines:** consumer premium subscriptions; provider SaaS seats;
  enterprise/payer contracts; GLP-1 add-on.
- **Primary variable cost:** AI inference per scan → controlled via free-tier
  caps, model routing (cheap model first, escalate on low confidence), caching of
  recognized dishes, and an editable food DB to reduce repeat inference.
- **Targets to model in planning:** consumer free→paid %, blended ARPU,
  provider seat ARPU + expansion, CAC by channel, **LTV:CAC ≥ 3**, gross margin
  after inference, payback < 12 months.
- **Two-sided flywheel economics:** each paid provider drives low-CAC patient
  installs (invite codes), improving blended CAC over time.

---

## 17. Assumptions & constraints

**Assumptions**
- Multimodal AI is accurate/cheap enough for photo→nutrition at scale.
- Providers will adopt a lightweight tool that saves time and shows adherence.
- MENA users will pay region-appropriate prices for Arabic-native value.
- Wellness positioning holds across target geographies' regulators.

**Constraints**
- Must remain general-wellness (no device classification) in v1.
- Arabic-first + RTL is non-negotiable for the beachhead.
- Privacy/security must be near-clinical even while positioned as wellness.
- Built cross-platform (one codebase) to control cost — leveraging team's
  proven Flutter + Supabase + multimodal-AI-proxy stack (see Tayyibat).

---

*This BRD pairs with the PRD (product/functional spec) and the Competitive
Analysis (market evidence). Update all three together as strategy evolves.*
