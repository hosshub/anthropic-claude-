# Wellness AI — Competitive Analysis & Market Landscape

**Version:** 1.0  ·  **Date:** 2026-06-08  ·  **Status:** Draft for review
**Owner:** Product / Strategy
**Related docs:** [BRD.md](./BRD.md) · [PRD.md](./PRD.md)

---

## 1. Purpose

This document maps the competitive landscape for **Wellness AI** — a two-sided,
AI-driven, condition- and diet-aware nutrition + wellness platform with a
consumer app and a provider (doctor / dietitian / trainer) dashboard, Arabic-first
with English support.

It answers three questions:
1. Who are we competing with, in which category?
2. How do we compare on features and pricing?
3. Where is the defensible gap we exploit?

> ⚠️ All pricing below is **directional, gathered June 2026** from public sources
> and review aggregators. Several apps (notably Cal AI) use opaque, variable
> paywalls; treat figures as ranges, re-verify before any pricing decision. See
> §9 Sources.

---

## 2. The market is real and growing fast

| Market | 2024–25 size | Forecast | CAGR | Source |
|---|---|---|---|---|
| Digital Health + Nutrition Integration | $13.49B (2025) | $35.81B (2033) | ~13% | Data Bridge |
| U.S. Digital Dietitian | $655M (2025) | $1.8B (2035) | ~10.9% | Grand View |
| Middle East Fitness Apps | $400M (2024) | $1.11B (2033) | ~12% | Grand View |
| Saudi Arabia Fitness Apps | $26.5M (2024) | $165.5M (2033) | ~22.6% | IMARC |
| MEA Fitness Apps (aggressive est.) | $0.44B (2024) | $3.37B (2033) | ~25% | Market Data Forecast |

**Takeaways:**
- The **provider/clinical** side (digital dietitian) is growing as fast as the
  consumer side and is far less crowded with AI-native players.
- **MENA is under-served and high-growth** — localized Arabic content sees
  materially higher adoption (e.g. Saudi's Miran + Egypt's Welnes merged in 2025
  to chase exactly this). This is our beachhead.
- The single biggest demand shock is **GLP-1 medications** (Ozempic / Wegovy /
  Mounjaro / Zepbound). Tens of millions of new users need protein-forward,
  muscle-preserving, side-effect-aware tracking — a feature set legacy calorie
  counters were not built for.

---

## 3. Competitor map — five categories

Wellness AI is unusual because it spans **three** of these five at once. Most
incumbents live in exactly one.

```
┌─────────────────────────────────────────────────────────────────┐
│  A. AI MEAL SCANNERS (consumer, single-sided)                    │
│     Cal AI · SnapCalorie · Foodvisor · Amy Food Journal ·        │
│     MyNetDiary · Calorie Mama                                     │
├─────────────────────────────────────────────────────────────────┤
│  B. MAINSTREAM CALORIE / DIET TRACKERS                           │
│     MyFitnessPal · Yazio · Lifesum · Cronometer · Fitia          │
├─────────────────────────────────────────────────────────────────┤
│  C. BEHAVIOR-CHANGE / COACHING (condition-adjacent)              │
│     Noom · Klinio · Oviva · Zoe                                   │
├─────────────────────────────────────────────────────────────────┤
│  D. METABOLIC / CGM PROGRAMS                                     │
│     Levels · Nutrisense · Signos · Vively · Veri                 │
├─────────────────────────────────────────────────────────────────┤
│  E. PROVIDER / CLINICAL PLATFORMS (B2B, the "other side")        │
│     Healthie · Practice Better · Nutrium · Season Health         │
└─────────────────────────────────────────────────────────────────┘

      WELLNESS AI  =  A (AI scanning) + C/D (condition-aware)
                       +  E (provider loop)  ×  MENA-first localization
```

---

## 4. Detailed competitor profiles

### Category A — AI meal scanners

**Cal AI** — the breakout consumer AI scanner. Uses phone depth sensor +
photo to estimate volume → macros. Claims ~90–95% accuracy on common foods.
Opaque, quiz-gated, variable paywall (~$2.99/wk to ~$49.99/yr reported).
Strength: viral growth, slick UX. Weakness: no provider side, no clinical
trust, English-centric, no condition logic, accuracy degrades on mixed/ethnic
dishes.

**SnapCalorie** — built by ex-Google team that created the food-recognition
research; 3D volume estimation + optional human verification. **Free.**
Strength: best-in-class portion estimation, free. Weakness: narrow (logging
only), no coaching/provider/condition layer.

**MyNetDiary** — verified ~2M-item database, launched **GLP-1 Companion**
(May 2026) inside Premium: injection reminders, protein-focused tracking,
digestive-symptom logging, GLP-1 meal planning. 31M registered users.
Strength: data quality + GLP-1 first-mover. Weakness: dated UX, no provider
marketplace, weak in Arabic/MENA.

**Foodvisor** — strong on European cuisine recognition; consumer only.

### Category B — Mainstream trackers

**MyFitnessPal** — the incumbent. Huge food DB, now bolting on AI meal scan,
voice logging, and GLP-1 support tools (medication tracking, muscle-preserving
exercise videos). Premium ~$19.99/mo or ~$79.99/yr. Strength: brand, database,
ecosystem. Weakness: bloated, ad-heavy free tier, generic (not condition-led),
no provider loop, weak Arabic.

**Yazio** — clean, recipes + fasting. PRO ~$47.90/yr. Strong in Europe.

**Lifesum** — lifestyle/diet plans, polished. Premium ~$30.99–$99.99/yr.

**Cronometer** — micronutrient depth, the "data nerd" choice. Gold ~$49.99/yr.

**Fitia** — strong in LatAm/Spanish; shows the localization-wins thesis.

### Category C — Behavior-change / condition-adjacent

**Noom** — psychology-based coaching + daily lessons; now Noom Med adds GLP-1
access. ~$209/yr — the premium anchor. Strength: behavior science, retention,
human coach feel. Weakness: expensive, US-centric, not AI-scan-led, not
provider-extensible.

**Klinio** — diabetes/prediabetes-specific diet app; published a peer-reviewed
pilot showing HbA1c improvement. Strength: condition focus + clinical evidence.
Weakness: single condition, quiz-funnel monetization, no live provider link.

**Oviva** — digital diabetes/obesity treatment, **NHS-reimbursed**, real
dietitian care + app. Strength: payer/clinical integration. Weakness:
geography-locked (UK/EU), heavy regulated footprint.

**Zoe** — microbiome + personalized nutrition science brand; currently between
test products. Premium science brand, expensive, not provider-facing.

### Category D — Metabolic / CGM

**Levels** — CGM + app. Classic ~$24/mo ($288/yr CGM only), up to Complete
~$1,499/yr with coaching + labs. **Signos** — Dexcom Stelo-based; only CGM
service with FDA clearance for a weight-management claim; ~$129–199/mo.
**Nutrisense** — includes RD coaching on every plan; ~$299–399/mo.
**Vively** (AUS) — CGM + PCOS focus; Baseline check from ~$99.

Strength of the category: hardware moat + biological feedback. Weakness:
**expensive, hardware-dependent, not scalable to mass MENA market**. Wellness AI
can *integrate* CGM data via aggregators without being CGM-dependent.

### Category E — Provider / clinical platforms (the "other side")

**Healthie** — all-in-one EHR + practice management for wellness providers
(intake, docs, billing, telehealth). Core from ~$19/mo → Plus ~$129 → Group
~$149. Strength: clinical depth, billing/insurance. Weakness: **provider-first,
patient app is an afterthought** — no consumer-grade AI meal scanning, no
delight, no MENA localization.

**Practice Better** — 50,000+ practitioners; free Sprout (3 clients), Starter
~$25/mo. Strength: best entry pricing, broad workflow. Weakness: same — weak
patient-side AI, Western market.

**Nutrium** — 350,000+ dietitians across 90 countries; from ~$19/mo (10
clients) to ~$25/mo unlimited. Strength: meal-planning + global reach + scale.
Weakness: dietitian tool, not a consumer brand; patient app is utilitarian.

**The structural opening:** the provider platforms have the *relationship* but
not the *consumer product*; the AI scanners have the *consumer product* but not
the *relationship*. **Nobody owns both well, and nobody owns both in Arabic.**

---

## 5. Feature comparison matrix

Legend: ✅ strong · 🟡 partial/weak · ❌ absent · 💲 paid-gated

| Capability | Cal AI | MyFitnessPal | Noom | Klinio | Levels | Healthie | **Wellness AI (target)** |
|---|---|---|---|---|---|---|---|
| AI photo meal scan | ✅ | 🟡 | ❌ | 🟡 | ❌ | ❌ | ✅ multimodal |
| Portion/volume estimate | ✅ | 🟡 | ❌ | ❌ | ❌ | ❌ | ✅ |
| Macro + micro tracking | ✅ | ✅ | 🟡 | ✅ | 🟡 | 🟡 | ✅ |
| Condition-aware logic (diabetes/PCOS/HTN) | ❌ | ❌ | 🟡 | ✅ (diabetes) | 🟡 | 🟡 | ✅ multi-condition |
| Diet-type plans (keto/vegan/low-carb…) | 🟡 | ✅ | 🟡 | 🟡 | ❌ | 🟡 | ✅ |
| GLP-1 companion mode | ❌ | ✅ | ✅ | 🟡 | ❌ | ❌ | ✅ |
| Activity / exercise tracking | 🟡 | ✅ | 🟡 | 🟡 | 🟡 | ❌ | ✅ |
| Exercise recommendations | ❌ | 🟡 | 🟡 | 🟡 | ❌ | ❌ | ✅ diet-aware |
| Wearable integration (Apple/Fitbit/Oura/CGM) | 🟡 | ✅ | 🟡 | 🟡 | ✅ (own CGM) | 🟡 | ✅ via aggregator |
| **Provider dashboard (clinician sees patient)** | ❌ | ❌ | 🟡 (own coaches) | ❌ | 🟡 (own coaches) | ✅ | ✅ open marketplace |
| **Provider "prescribes" plan → patient app** | ❌ | ❌ | ❌ | ❌ | ❌ | 🟡 | ✅ core |
| Invite-code patient↔provider linking | ❌ | ❌ | ❌ | ❌ | ❌ | 🟡 | ✅ core |
| Challenges / gamification | 🟡 | 🟡 | ✅ | 🟡 | ❌ | ❌ | ✅ |
| Arabic-first + RTL | ❌ | 🟡 | ❌ | ❌ | ❌ | ❌ | ✅ |
| Culturally-relevant food DB (MENA dishes) | ❌ | 🟡 | ❌ | ❌ | ❌ | ❌ | ✅ |
| Freemium consumer tier | 🟡 | ✅ | ❌ | ❌ | ❌ | n/a | ✅ |

**Reading of the matrix:** every column has gaps; **only the Wellness AI column
has the provider loop + Arabic + multi-condition + AI scan together.** That
combination is the moat.

---

## 6. Pricing comparison

### Consumer apps (annual, USD, directional)

| App | Free tier? | Premium /yr | Premium /mo | Notes |
|---|---|---|---|---|
| SnapCalorie | ✅ full | $0 | $0 | Free; logging only |
| Cal AI | 🟡 trial | ~$20–50 | ~$3–10 (variable) | Opaque, quiz-gated paywall |
| Yazio PRO | ✅ | ~$47.90 | — | Cheapest mainstream premium |
| Cronometer Gold | ✅ | ~$49.99 | — | Micronutrient depth |
| Lifesum | ✅ | ~$31–100 | — | Wide promo range |
| MyFitnessPal | ✅ (ads) | ~$79.99 | ~$19.99 | Incumbent |
| MyNetDiary | ✅ | ~$60–70 | — | GLP-1 Companion in Premium |
| Noom | ❌ | ~$209 | ~$17.40 | Coaching-priced, premium anchor |

### Metabolic / CGM (hardware-bearing)

| Program | Entry /mo | Top /yr | Includes |
|---|---|---|---|
| Levels | ~$24 (CGM only) | up to ~$1,499 | CGM + labs + coaching tiers |
| Signos | ~$129–199 | — | Dexcom Stelo + RD sessions |
| Nutrisense | ~$299–399 | — | RD coaching every plan |

### Provider / clinical SaaS (per practitioner /mo)

| Platform | Entry | Mid | Top | Client limits |
|---|---|---|---|---|
| Practice Better | Free (3 clients) | ~$25 | ~$59+ | Tiered |
| Nutrium | ~$19 (10 clients) | ~$25 (unlimited) | — | Tiered |
| Healthie | ~$19 Core | ~$49–129 | ~$149 Group | Tiered |

### Implied pricing strategy for Wellness AI

- **Consumer freemium**: free tier capped (e.g. 1–3 AI meal scans/day, basic
  tracking, 1 diet plan). Premium individual at **a deliberately MENA-accessible
  price** — undercut MyFitnessPal/Noom; benchmark to local purchasing power
  (e.g. SAR/EGP tiers), roughly **$4–7/mo or $39–59/yr** equivalent, with
  regional price localization.
- **Provider SaaS**: per-seat, **free starter (≤5 patients)** to seed supply,
  paid tiers around **$19–49/seat/mo** mirroring Practice Better/Nutrium, plus
  **clinic/enterprise** plans for hospital groups.
- **B2B2C / payer / employer**: per-covered-life or per-active-patient billing
  for hospitals, insurers, corporate wellness — the highest-margin lane.
- **GLP-1 companion** as a premium add-on or bundled to drive retention during
  the medication wave.

---

## 7. Where Wellness AI wins (gap analysis)

1. **The provider loop is the moat.** Consumer AI apps have no clinician
   relationship; clinical SaaS has no consumer-grade AI. We own both sides via
   the **invite-code link** + **provider-prescribed plan → patient app**. This
   creates two-sided lock-in and word-of-mouth (every prescribing doctor is a
   distribution channel).
2. **Condition + diet breadth, not single-condition.** Klinio = diabetes only;
   Allara = women's health only. We cover diabetes, PCOS, hypertension,
   pre-diabetes, plus elective diets (keto, vegan, low-carb, Mediterranean,
   high-protein, halal-conscious) under one personalization engine.
3. **Arabic-first + MENA food intelligence.** No serious AI scanner recognizes
   machboos, koshari, mandi, molokhia, or kunafa or labels them in Arabic. This
   is a defensible localization moat in the fastest-growing fitness-app region.
4. **GLP-1-ready at launch.** Ride the single biggest demand wave with
   protein-forward, muscle-preserving, side-effect-aware tracking + (provider-
   supervised) medication reminders — without making drug claims ourselves.
5. **Aggregator-based wearable strategy.** Rather than building 20 integrations,
   use **Terra/Spike-style aggregators** to support 500+ devices (Apple Health,
   Health Connect, Fitbit, Oura, Garmin, WHOOP, CGM) on day one — breadth that
   takes incumbents years.
6. **Wellness-positioned, not device-classified.** Deliberately staying on the
   general-wellness side of the regulatory line (see BRD §13) lets us move fast
   in app stores and across borders while clinical platforms carry heavier
   compliance drag.

**Risks to the thesis** (also in BRD §14): AI accuracy on mixed Arabic dishes;
two-sided cold-start (need providers *and* patients); incumbents (MyFitnessPal,
Noom) bolting on similar AI; provider data-privacy expectations approaching
clinical-grade even while we stay "wellness."

---

## 8. One-line positioning

> **Wellness AI** is the Arabic-first AI wellness platform where you photograph
> your meal and your doctor, dietitian, or coach sees your progress — turning a
> prescribed diet from a paper handout into a living, tracked, guided plan.

---

## 9. Sources

AI scanners & trackers:
- [Jotform — best AI calorie trackers 2026](https://www.jotform.com/ai/best-ai-calorie-tracker/)
- [Amy Food Journal — AI calorie counter apps 2026](https://www.amyfoodjournal.com/blog/ai-calorie-counter-apps)
- [NutriScan — Cal AI pricing 2026](https://nutriscan.app/blog/posts/cal-ai-pricing-2026-monthly-yearly-premium-abc6e7b26f)
- [SnapCalorie — free version?](https://www.snapcalorie.com/blog/is-there-a-free-version-of-cal-ai.html)
- [eesel — Cal AI pricing](https://www.eesel.ai/blog/cal-ai-pricing)
- [MyNetDiary GLP-1 Companion launch (PR Newswire)](https://www.prnewswire.com/news-releases/mynetdiary-launches-glp-1-companion-for-ozempic-wegovy-and-mounjaro-users-302761158.html)

Mainstream pricing:
- [NutriScan — cheapest nutrition app 2026](https://nutriscan.app/blog/posts/cheapest-nutrition-app-2026-pricing-compared-4c18a9205d)
- [NutriScan — Yazio PRO pricing](https://nutriscan.app/blog/posts/yazio-pricing-2026-free-vs-pro-what-pro-unlocks-33b26f8fc7)
- [Nutrola — Lifesum cost 2026](https://nutrola.app/en/blog/how-much-does-lifesum-cost-now-2026)

Behavior change / condition:
- [Klinio HbA1c pilot study (ScienceDirect)](https://www.sciencedirect.com/science/article/pii/S2352648323000326)
- [Oviva diabetes/obesity platform](https://www.boltpharmacy.co.uk/guide/oviva-digital-diabetes-obesity-treatment-platform)
- [Allara Health](https://www.allarahealth.com/)
- [Vively](https://www.vively.com.au/)

CGM:
- [Nutrisense — best CGM programs 2026](https://www.nutrisense.io/blog/best-cgm-programs)
- [SNAQ — cost of Signos/Levels/Nutrisense/Veri](https://www.snaq.ai/blog/comparing-the-cost-of-signos-levels-nutrisense-veri-and-snaq)

Provider platforms:
- [ProMealPlan — Practice Better vs Nutrium vs Promealplan](https://www.promealplan.com/en/blog/dietitian-practice-management-software)
- [Capterra — Healthie](https://www.capterra.com/p/167439/Healthie/)
- [Capterra — Nutrium](https://www.capterra.com/p/173803/Nutrium/)

Integrations:
- [Terra API](https://tryterra.co/)
- [Spike API vs HealthKit & Health Connect](https://www.spikeapi.com/blog/spike-api-outshines-healthkit-and-health-connect)

Regulatory:
- [Faegre Drinker — FDA 2026 General Wellness & CDS guidance](https://www.faegredrinker.com/en/insights/publications/2026/1/key-updates-in-fdas-2026-general-wellness-and-clinical-decision-support-software-guidance)
- [Ropes & Gray — FDA digital health guidance update](https://www.ropesgray.com/en/insights/alerts/2026/01/fda-adapts-with-the-times-on-digital-health-updated-guidances-on-general-wellness-products)
- [Kendall PC — FDA 2026 general wellness devices](https://kendallpc.com/fdas-2026-guidance-on-general-wellness-devices-policy-for-low-risk-devices-key-compliance-and-regulatory-insights-for-digital-health-companies/)

Market size / MENA:
- [Grand View — Middle East fitness apps](https://www.grandviewresearch.com/industry-analysis/middle-east-fitness-apps-market-report)
- [IMARC — Saudi Arabia fitness app market](https://www.imarcgroup.com/saudi-arabia-fitness-app-market)
- [Data Bridge — digital health + nutrition integration](https://www.databridgemarketresearch.com/reports/global-digital-health-nutrition-integration-market)
- [Grand View — US digital dietitian market](https://www.grandviewresearch.com/industry-analysis/us-digital-dietitian-market-report)
- [Fast Company ME — wellness industry growth](https://fastcompanyme.com/impact/is-the-wellness-industry-in-the-middle-east-witnessing-a-healthy-growth/)
