# Tayyibat — Session Handoff Brief

**Read this first in a new session.** It's the single entry point that ties
together `CLAUDE.md` (deep orientation) and `V1.2_PLAN.md` (the next work).
Written 2026-07-21 to hand off from a remote (web) session to a local one.

---

## 1. What this app is (30-second version)
**Tayyibat (الطيبات)** — an Arabic-first, fully bilingual (ar/en) mindful-eating
app. User photographs a meal → image goes through a Supabase Edge Function
(`analyze`) to **Google Gemini 2.5 Flash-Lite** → returns a per-item 3-zone
verdict (🟢/🟡/🔴), an overall 0–100 compliance score, and (v1.1) per-item
calories/macros/micros. Plus: history/calendar, body-response tracking, a smart
guide, meal banks, a 15-day program, a full meal guidebook, AI meal suggestions
+ weekly plans, fasting tracker (Hijri), local notifications, daily calorie
tracker. **Medical-safety constrained**: never makes health claims, never
mentions medication, ships a scroll-gated disclaimer.

- **Stack:** Flutter (Dart 3.5+) → iOS + Android from one codebase. `provider`
  state, `sqflite` (schema **v3**), Supabase Auth (email + Google + Apple),
  Supabase Edge Functions (Deno/TS), Gemini AI.
- **Paid app:** $6.50 (USD 4.99 base) on both stores.
- **Bundle:** `ai.tayyibat.tayyibat` · **Apple team** QBX2YPY4W8 (Hossam Nasef).

## 2. Current release state (as of this brief)
| Track | State |
|---|---|
| **App Store** | **1.0.2 (6) APPROVED + commercially live** (Paid Apps Agreement, bank, tax all Active). Listing: `apps.apple.com/ae/app/tayyibat-ai/id6777743474`. |
| **App Store — 1.1.0 (7)** | Built + CI-green + release notes ready; **not yet submitted**. Adds nutrition, calorie tracker, meal guidebook. Submit as a fast-follow. Needs: deploy `analyze` (nutrition prompt), build IPA on Mac, create 1.1.0 version, attach build 7, submit. |
| **Google Play** | App created as **Paid**. Blocked by the new-personal-account gate: **12 testers opted-in for 14 continuous days** before production. Plan: recruit via tester-exchange communities. AAB must be rebuilt at 1.1.0+7 (on-disk one is stale). Remaining Play tasks: content rating, data safety, target audience, health declaration, store listing, price. Graphics ready in `submission/play-store/graphics/`. |
| **Website** | `tayyibat.ai` refreshed: v1.1.0 features, App Store download badge, new logo (App Store icon), screenshot gallery, explicit Gemini note in privacy. User deploys the pack to cPanel. |

## 3. The immediate next work: v1.2 (post-launch fixes)
Full detail in **`V1.2_PLAN.md`**. Triaged from real launch reviews. Locked
decisions: **hardening sweep** (no specific repros), **3 meal recommendations
at once**, **keep $6.50 + add features**, **editable analyzed ingredients**,
**meal-plan tracking**, **editable display name** (no username today — greeting
derives from email), **onboarding overhaul**, **spelling audit** (ar+en).
Release as **1.2.0+8**.

### File map for v1.2 (what each item touches)
- **Spelling/copy:** `flutter_app/lib/l10n/app_ar.arb`, `app_en.arb`,
  `flutter_app/lib/data/{guide_data,meal_banks_data,guidebook_data,tips_data,program_data}.dart`
- **Editable ingredients + score recompute:**
  `flutter_app/lib/features/history/meal_detail_screen.dart`,
  `flutter_app/lib/models/analysis_result.dart`, `.../models/meal.dart`,
  `flutter_app/lib/data/meal_repository.dart` (+ new score-recompute helper mirroring
  server logic: green full / yellow 60% / red 0 + cap 50 on explicit red).
- **3 recommendations:** `supabase/functions/analyze/index.ts` (`buildSuggestPrompt`
  → array of 3), `flutter_app/lib/services/suggestion_service.dart`,
  `.../models/suggestion.dart`, `.../features/suggestions/suggestions_screen.dart`.
- **Meal-plan tracking:** `flutter_app/lib/data/database.dart` (schema **v4** — new
  `meal_plans`/`plan_days` tables + migration), new repo methods,
  `.../features/suggestions/`, `WeeklyPlan` model.
- **Display name:** new profile store (SharedPreferences or `profile` table),
  `.../features/settings/settings_screen.dart`, `.../features/onboarding/`,
  `.../features/today/today_screen.dart` (greeting).
- **Onboarding:** `.../features/onboarding/disclaimer_screen.dart` + new steps,
  `.../services/onboarding_service.dart`.
- **Hardening:** every `.../features/**`, route catches through `describeError`
  in `.../services/app_messages.dart`, `mounted` checks, empty/null states.

## 4. Secrets & config — WHERE they live (never in repo)
- **Gemini API key, Supabase service-role key:** Supabase Function secrets
  dashboard only. (Gemini billing was depleted → refilled; keep it funded.)
- **Reviewer login** `reviewer@tayyibat.ai` / `Apple@2026`: Supabase Auth +
  store forms only. **Never commit** — repo is public.
- **Android keystore** (`upload-keystore.jks`) + `key.properties`: Mac-only,
  gitignored. Back up the keystore.
- **Safe to commit:** Supabase URL, Supabase publishable (anon) key.
- Project ref: `cvznuwvwhnujdgfojmsb`. Endpoints in CLAUDE.md §11.

## 5. Dev workflows (Mac)
```bash
# location
cd "/Users/hoss/Code Projects/anthropic-claude-"

# run/test on device
cd flutter_app && flutter pub get && cd ios && pod install && cd .. && flutter run --release

# iOS release: flutter build ipa --release  → Xcode Organizer → Distribute App
# (CLI export fails on signing cert — that's expected; use Organizer)

# Android release
flutter build appbundle --release   # → build/app/outputs/bundle/release/app-release.aab

# deploy edge function (from REPO ROOT, not supabase/)
supabase functions deploy analyze --no-verify-jwt
```
CI: `.github/workflows/flutter-ci.yml` runs `flutter analyze --no-fatal-infos`
+ `flutter test` on `flutter_app/**` pushes (unpinned stable channel).

## 6. Conventions
- **Branch:** `claude/tayyibat-ios-app-ftYsJ` (only). Never `main` without
  explicit direction.
- **Commits:** lowercase prefix (`flutter:`/`supabase:`/`web:`/`docs:`/
  `submission:`), imperative, body explains why. No co-author/LLM trailers.
- **Do nots:** no medical claims; no medication; never remove the scroll-gated
  disclaimer; never set `appleSignInEnabled=false`; don't touch legacy
  `Tayyibat/` SwiftUI tree.
- Active PR: **#1** (open, CI green, subscribed for webhook events).

## 7. To start the local session
```bash
cd "/Users/hoss/Code Projects/anthropic-claude-"
git pull --ff-only
claude
```
Then (optional, for the Superpowers plugin — local only, one command at a time):
```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```
First prompt to give it:
> Read SESSION_BRIEF.md and V1.2_PLAN.md, then start on v1.2.
