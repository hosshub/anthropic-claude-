# CLAUDE.md — Tayyibat (الطيبات)

This file is the orientation memory for Claude Code sessions on this repo.
Auto-loaded by Claude. Keep it terse and current; link out to deeper docs
under `submission/` and the SwiftUI/Flutter READMEs.

---

## 1. What this project is

**Tayyibat** (الطيبات) is an **Arabic-first** mindful-eating app: the user
photographs a meal, the app sends the image through a server-side Gemini proxy,
and returns a per-item analysis with a three-zone verdict (🟢 green / 🟡 yellow /
🔴 red) plus an overall compliance score (0–100%). The system follows the
"Tayyibat" food philosophy (a simplified, traditional-leaning eating system).

The app is **medical-safety constrained**: never makes health claims, never
mentions medication, ships a scroll-gated disclaimer the user must accept
before first use.

## 2. Tech stack

| Layer | Choice |
|---|---|
| **Mobile** | Flutter (Dart 3.5+) → iOS + Android from one codebase |
| **State mgmt** | `provider` (ChangeNotifier services) |
| **Local DB** | `sqflite` (schema v2; tables: meals, food_items, body_responses, fasting_days) |
| **Auth** | Supabase Auth — email/password, Google OAuth (PKCE), Sign in with Apple |
| **Backend proxy** | Supabase Edge Functions (Deno/TypeScript) — `analyze`, `delete-account` |
| **AI** | Google **Gemini 2.5 Flash-Lite** via Generative Language API, proxied through `analyze` function. Daily per-user cap with refund-on-failure (PostgreSQL `bump_usage` / `refund_usage` RPCs) |
| **Notifications** | `flutter_local_notifications` 17.x, local only, no push/APNs |
| **Hijri calendar** | `hijri` package (for fasting recommendations: Mon/Thu + white days 13/14/15) |
| **Charts** | `fl_chart` for 30-day score trend |
| **Calendar UI** | `table_calendar` (Saturday-start) |
| **Branding** | Emerald `#0F5132`, Gold `#C9A35B`, Ivory `#FAF7F2`, Khabith red `#9B2C2C` |
| **Typography** | In-app: system fonts (RTL via Flutter). Marketing: **El Messiri** (headlines) + **Tajawal** (subheads) — both from Google Fonts |

Legacy: a SwiftUI iOS-only implementation also lives in `Tayyibat/` —
**retired** in favor of the Flutter port. Don't make changes to it.

## 3. Repository layout

```
.
├── CLAUDE.md                ← this file
├── README.md                ← original SwiftUI-era project intro (Arabic)
├── PRIVACY.md, APP_STORE.md ← legacy notes; canonical privacy now lives at web/privacy.html
│
├── flutter_app/             ← active codebase (iOS + Android)
│   ├── lib/                 ← all Dart source
│   │   ├── main.dart, app.dart, config.dart, theme/
│   │   ├── data/            ← SQLite schema, repositories, static data (guide, meal banks, program, tips)
│   │   ├── models/          ← FoodItem, Meal, FoodZone, BodyResponse, Suggestion
│   │   ├── services/        ← AuthService, AnalyzeService, AccountService, SuggestionService,
│   │   │                       NotificationService, FastingCalculator, FastingRepository,
│   │   │                       OnboardingService
│   │   ├── widgets/         ← shared UI (PrimaryButton, CardContainer, ZoneBadge,
│   │   │                       GoogleSignInButton, GoogleGLogo)
│   │   ├── shell/           ← MainShell (4-tab bottom nav)
│   │   └── features/
│   │       ├── auth/        ← AuthScreen (email + Google + Apple)
│   │       ├── onboarding/  ← DisclaimerScreen (scroll-gated + readOnly mode)
│   │       ├── today/       ← TodayScreen, WhenInDoubtScreen
│   │       ├── capture/     ← CaptureScreen, ResultScreen → MealDetailScreen
│   │       ├── history/     ← HistoryScreen (list + calendar), MealDetailScreen,
│   │       │                  BodyIntelligenceSection (trend chart + zone share + sleep)
│   │       ├── body_response/ ← BodyResponseFlow (5-question), BodyResponseCard
│   │       ├── guide/       ← 9 sections (philosophy, golden rules, eating map redesigned,
│   │       │                  forbidden, plate, weekly prep checklist, mistakes,
│   │       │                  + wrappers for program + meal banks)
│   │       ├── meal_banks/  ← MealBanksScreen (4 categories)
│   │       ├── program/     ← ProgramScreen (15-day journey)
│   │       ├── suggestions/ ← SuggestionsScreen (single meal + weekly plan tabs)
│   │       ├── fasting/     ← FastingScreen (Mon/Thu + white days)
│   │       └── settings/    ← SettingsScreen, NotificationSettingsScreen
│   ├── pubspec.yaml         ← deps (see below)
│   ├── assets/icon/         ← icon.png + icon_foreground.png (generated PNG)
│   └── README.md            ← Flutter-specific setup + SceneDelegate fix doc
│
├── supabase/
│   ├── functions/analyze/index.ts        ← Gemini proxy w/ daily cap + 3 tasks (analyze/suggest/plan)
│   ├── functions/delete-account/index.ts ← App Store 5.1.1(v) compliant deletion
│   └── sql/usage_cap.sql                 ← usage_daily + bump_usage + refund_usage RPCs
│
├── web/
│   ├── index.html, privacy.html (live at https://tayyibat.ai/privacy.html), logo.png
│
├── submission/              ← full App Store + Play Store kit
│   ├── README.md            ← master checklist
│   ├── app-store/           ← checklist, listing-ar/-en, privacy-labels, apple-signin-setup, review-notes, release-notes
│   ├── play-store/          ← checklist, listing-ar/-en, data-safety, internal-testing, release-notes
│   └── screenshots/         ← README only; PNGs gitignored
│
├── Tayyibat/, Tayyibat.xcodeproj/, TayyibatTests/, project.yml
│                            ← LEGACY SwiftUI implementation, retired. Do not modify.
└── server/                  ← Legacy proxy attempt (cPanel); replaced by Supabase Edge Functions
```

## 4. Key pubspec dependencies

```
supabase_flutter ^2.5.6     image_picker ^1.1.1     app_links ^6.3.2
sqflite ^2.3.3+1            uuid ^4.4.0             sign_in_with_apple ^6.1.4
shared_preferences ^2.3.2   provider ^6.1.2         crypto ^3.0.5
flutter_local_notifications ^17.2.2   timezone ^0.9.4
hijri ^3.0.0                table_calendar ^3.1.2   fl_chart ^0.69.0
```

Dev: `flutter_launcher_icons ^0.14.1` (runs once: `flutter pub run flutter_launcher_icons`).

## 5. Features shipped (v1.0.0 — F1..F5 phases)

### Auth + onboarding
- Email/password sign up + sign in.
- Google OAuth via Supabase PKCE flow (uses `LaunchMode.externalApplication`).
- Sign in with Apple (native `ASAuthorizationController` → `signInWithIdToken`).
  Requires `appleSignInEnabled = true` in `lib/config.dart` (now true).
- Deep-link return handled in `main.dart` via `app_links` plugin
  (URL scheme `tayyibat://login-callback`).
- **Scroll-gated medical disclaimer** before any tab opens. Persisted via
  `OnboardingService` (SharedPreferences). Re-readable from Settings.

### Core analysis loop
- Capture meal (camera or photo library) → POST to Supabase `analyze` function.
- Daily cap (`bump_usage` SQL fn) enforces N analyses/user/day; refund on failure.
- AI returns 3-zone classification per item + overall score + Arabic reasoning.
- Saved locally to SQLite with JPEG on disk.

### History + insights
- **List view**: every meal, descending date.
- **Calendar view**: monthly grid (Saturday-start), colored dots per day from
  the day's average score (green/light-green/gold/khabith bands).
- **Body Intelligence**: 30-day score trend line (fl_chart), avg satiety/bloating
  per 30 days, top comforting meals, heaviest meals, sleep impact distribution,
  green/yellow/red zone share (7d + 30d).

### Body response
- 5-question post-meal flow: satisfaction (1-5 emoji), bloating (0-5 slider),
  energy (1-5 radio), sleep impact (4 options), worth repeating (3 emoji).
- Optional notes field.

### Smart guide (9 sections)
1. Philosophy (3 cards) · 2. Golden rules (6) · 3. **Eating map** (tabbed
   green/yellow/red, redesigned in Phase 4 — chip-based, modern hero cards) ·
4. Explicit forbidden list · 5. Tayyibat plate (base formula) · 6. **15-day
   program** (interactive, 4 phases, daily card + capture button, persists via
SharedPreferences) · 7. **Meal banks** (4 categories × items with composition,
notes, and direct capture button) · 8. **Weekly prep** (checkable, auto-resets
each Saturday, progress bar) · 9. Common mistakes (6 anti-patterns).

### "When in doubt" 🤔 FAB
- Floating button on Today → 4 golden cards (اختر / امنع / اعتدل / راقب) + 3
  quick actions (meal banks, golden rules, capture-now).

### AI suggestions (Phase F4)
- Single-meal suggestion (`task: "suggest"`).
- 7-day weekly plan (`task: "plan"`, Saturday → Friday).
- Both go through the same `analyze` Edge Function but are exempt from the
  daily cap (cap is image-analysis only).

### Fasting (Phase 4 of pending → now shipped)
- `FastingCalculator` detects Mon/Thu (Gregorian) + days 13/14/15 (Hijri).
- `FastingRepository` upserts/clears today's fasting log; lists recent 30.
- `FastingScreen` shows gradient hero, today's kinds as pills, "next
  recommended" lookahead, and history.

### Notifications (Phase 3 of pending → now shipped)
- `NotificationService` schedules 5 kinds:
  - morningTip 08:00 daily · lunchReminder 13:00 daily · eveningTip 18:00 daily
  - endOfDayLog 21:30 daily · weeklyPrep Saturday 08:00
- 35-tip bank (`TipsData`) split into morning / afternoon / evening / general /
  prep / fasting slots, with last-10-shown anti-repeat per slot.
- Permission flow + per-kind toggle UI in NotificationSettingsScreen.
- Inexact scheduling (no Android `SCHEDULE_EXACT_ALARM` requirement).
- iOS requires `uiLocalNotificationDateInterpretation` (added).

### Privacy & account
- All meal data is **local-only**. Server only knows: user identity (Supabase
  Auth) and the daily-usage counter.
- In-app account deletion (Settings → حذف الحساب) hits `delete-account` Edge
  Function which verifies caller via `/auth/v1/user`, deletes usage rows, then
  deletes the auth user via admin API. Local SQLite + image files + fasting
  log are wiped client-side after success.

### App identity
- Bundle: `ai.tayyibat.tayyibat` (iOS App Store production) — registered in
  Apple Developer Portal under team **QBX2YPY4W8** (Hossam Nasef Individual).
- App Store name: `Tayyibat` (bare; "الطيبات" alone is reserved by another app).
- Icon: emerald gradient + tilted white leaf + small gold seed
  (`flutter_app/assets/icon/icon.png`).
- Privacy policy lives at https://tayyibat.ai/privacy.html (hosted via cPanel).
- Encryption export: `ITSAppUsesNonExemptEncryption = false` in Info.plist
  (we only use system HTTPS).

## 6. Submission state

| Store | State |
|---|---|
| **App Store** | App record created (bundle `ai.tayyibat.tayyibat`). v1.0.0 build 1 uploaded via Transporter (build id `5a832f4f-f5d8-4ed4-93a6-187fa95f5d81`). App Privacy labels filled. Six artistic 1320×2868 screenshots ready in `/tmp/appstore/` (re-render via `/tmp/compose2.py` if needed). Pending: final screenshot upload + Submit for Review. |
| **Google Play** | Not yet started. `submission/play-store/` has the full kit (listing copy, data-safety answers, internal-testing setup). Recommended sequence: $25 Play Console signup → Internal Testing track → invite up to 100 friends → eventual Production. |
| **Apple Sign in setup** | Done. Services ID `ai.tayyibat.web-signin` configured; Apple Key (`.p8`) JWT signed and uploaded as the Apple provider secret in Supabase. |
| **Apple Developer enrollment** | Active under personal Apple ID `hossnasef@gmail.com`. The earlier Workspace account `hossam@oryxlab.com` was blocked by Apple and abandoned. |

## 7. Roadmap (none of these are blockers for v1.0.0)

| Phase | Status | Notes |
|---|---|---|
| 1. App icon + launch screen | ✅ done | `flutter_launcher_icons` config in pubspec |
| 2. Local notifications | ✅ done | inexact scheduling, per-kind toggle |
| 3. Fasting tracker | ✅ done | DB v2 + Hijri lookup |
| 4. Calendar view | ✅ done | toggle in History |
| 5. Charts | ✅ done | fl_chart 30-day trend |
| 6. Account deletion API surface | ✅ done | App Store 5.1.1(v) compliant |
| 7. Localization (English) | ✅ full (v1.0.1) | every UI surface and content surface is bilingual: auth/onboarding/today/history/settings/capture/result, body-response flow + card, suggestions, fasting, notifications, body-intelligence, when-in-doubt, the 35-tip bank, **and** the Guide tab (philosophy, golden rules, eating map, forbidden list, plate, weekly prep, mistakes), Meal Banks (4 banks × items), and the 15-day Program (phases + day-by-day content). Runtime toggle in Settings + LocaleService; AI prompt (Gemini) locale-aware via the `locale` field on the analyze function. The "partial English" note in Settings has been narrowed accordingly. |
| 8. CI on push | ✅ wired (v1.0.1) | `.github/workflows/flutter-ci.yml` runs `flutter analyze` + `flutter test` on every push that touches `flutter_app/**`. Flutter pinned to 3.24.5 (matches Dart 3.5 floor). |
| 9. Crash reporting | ✅ wired (v1.0.1) | `sentry_flutter` 8.x in `main.dart`, gated on `--dart-define=SENTRY_DSN=...` (empty default = no events sent). PII collection, screenshots, view-hierarchy capture, traces, and profiling all disabled. EU region picked at the Sentry org level. |
| 10. Onboarding refinements | ❌ pending | name + age + height collection (currently skipped) |
| 11. Body-response notifications | ✅ wired (v1.0.1) | one-shot ~3h after each meal via `scheduleBodyFollowup`. Auto-cancels when the user logs the response, deletes the meal, or deletes the account. Toggle in Notification Settings; defaults on. Locale-aware title using the meal's `HH:MM` capture time. |
| 12. App Preview video | ❌ pending | optional Apple slot; ~1 min QuickTime recording |
| 13. Apple Watch companion | ❌ future | not v1 |
| 14. iPad layout | ❌ future | currently iPhone-only (portrait locked) |

## 8. Conventions

### Commit messages
- Lowercase prefix: `flutter:`, `docs:`, `submission:`, `supabase:`, `web:`.
- Imperative mood ("add X", not "added X").
- Body explains **why**, not what (the diff shows what).
- One feature/fix per commit.
- No co-author lines, no LLM identifier in trailers.

### Branch
- **Active**: `claude/tayyibat-ios-app-ftYsJ` (this is the working branch for
  iOS + Flutter; was the original feature branch and never merged to main).
- Push to that branch only. Never to `main` without explicit user direction.

### Code style
- Dart: prefer `const` constructors, no comments on obvious code, RTL by
  default (`Directionality(textDirection: TextDirection.rtl)` in MaterialApp).
- Arabic in UI strings, English in code identifiers and commit messages.
- Comments in Arabic for app-internal-context only when explaining a
  nuance specific to RTL or local-culture handling; otherwise English.
- No emojis in commit messages or code unless the user requests.

### Security non-negotiables
- **Never** commit:
  - Anthropic API key (we use Gemini now, but old leaks may exist)
  - Google OAuth client secret
  - Apple `.p8` key
  - Supabase service-role key
  - Anything from `.env` or `secrets.plist`
- Safe to commit: Supabase URL, Supabase **publishable** (anon) key.
- Server-side secrets (`GEMINI_API_KEY`, `SUPABASE_SERVICE_ROLE_KEY`) live
  only in Supabase Function secrets dashboard.

## 9. Common dev workflows

### Build + run on iPhone (current setup)
```bash
cd ~/anthropic-claude-/flutter_app
flutter pub get
cd ios && pod install && cd ..
flutter run -d <iphone-udid>      # current: 00008150-00092D8602C0401C
```

### Build release IPA for App Store
```bash
cd ~/anthropic-claude-/flutter_app
flutter pub run flutter_launcher_icons      # regen icons (do not skip)
flutter build ipa --release \
  --dart-define=SENTRY_DSN=https://...@o....ingest.de.sentry.io/...
# IPA at build/ios/ipa/tayyibat.ipa → drag into Transporter → Deliver.
```
Drop the `--dart-define` line if Sentry is intentionally disabled for the build.

### Build release APK for Play Store
```bash
cd ~/anthropic-claude-/flutter_app
flutter build appbundle --release
# AAB at build/app/outputs/bundle/release/app-release.aab
```

### Re-seed demo data for screenshots
Settings → "زرع بيانات تجريبية" (only visible when `kDebugMode == true`).
Inserts 11 synthetic meals across last 14 days. Wipe afterward via
Settings → "حذف الحساب".

### iOS SceneDelegate quirk (documented in `flutter_app/README.md`)
Modern `flutter create` generates `ios/Runner/SceneDelegate.swift` + an
`UIApplicationSceneManifest` plist key. Both intercept deep-link URLs before
`app_links` can see them. **Fix already applied in the project**: delete the
manifest key + replace SceneDelegate.swift with a stub that forwards URL
contexts back to AppDelegate. If a future `flutter create --platforms=ios` regenerates these, re-apply per the README's "SceneDelegate" section.

### Supabase function deploy
```bash
cd ~/anthropic-claude-/supabase
supabase functions deploy analyze --no-verify-jwt
supabase functions deploy delete-account --no-verify-jwt
```
Both functions verify the user JWT manually (calling `/auth/v1/user` with the
service role key), so the gateway must not pre-verify (`--no-verify-jwt`).

## 10. Submission kit map (under `submission/`)

- `README.md` — master checklist + recommended store order (Play first, App
  Store after Apple enrollment lands).
- `app-store/checklist.md` — App Store Connect step-by-step.
- `app-store/listing-ar.md` / `listing-en.md` — name, subtitle, promotional
  text, description, keywords. **Name = "Tayyibat" (bare)** because "الطيبات"
  is reserved.
- `app-store/privacy-labels.md` — every App Privacy nutrition-label answer.
  All four collected data types (email, photos, user ID, product interaction)
  are **linked to identity** but **not used for tracking**.
- `app-store/apple-signin-setup.md` — Services ID + .p8 + JWT secret generator
  block. Already executed; documentation for future re-runs (JWT expires in
  6 months).
- `app-store/review-notes.md` — what the Apple reviewer sees in the Review
  Notes field.
- `app-store/release-notes.md` — "What's New" in 1.0.0 (AR + EN).
- `play-store/*` — equivalents for Google Play.
- `screenshots/README.md` — six screens + dimensions + capture mechanics.
  Final renders generated via `/tmp/compose2.py` using El Messiri + Tajawal.

## 11. Live URLs

| What | URL |
|---|---|
| Marketing site | https://tayyibat.ai |
| Privacy policy | https://tayyibat.ai/privacy.html |
| Supabase project | https://supabase.com/dashboard/project/cvznuwvwhnujdgfojmsb |
| Edge function: analyze | https://cvznuwvwhnujdgfojmsb.supabase.co/functions/v1/analyze |
| Edge function: delete-account | https://cvznuwvwhnujdgfojmsb.supabase.co/functions/v1/delete-account |
| Support / privacy contact | `app@tayyibat.ai` |
| App Store record | App Store Connect → Apps → Tayyibat (id `6777743474`) |

## 12. Hard "do nots"

- ❌ Do **not** make medical claims anywhere in copy, UI, or marketing.
- ❌ Do **not** mention medication or claim to treat conditions.
- ❌ Do **not** ship without the scroll-gated disclaimer.
- ❌ Do **not** commit secrets (see §8 security).
- ❌ Do **not** rename `appleSignInEnabled` back to `false` — App Store
  Guideline 4.8 requires it since Google sign-in is offered.
- ❌ Do **not** modify the legacy `Tayyibat/` SwiftUI tree — it's retired.

---

*Last updated: 2026-06-08. When working on this project, prefer to update
this file over creating new docs for general orientation.*
