# Deploying Tayyibat 1.2.1 (build 9)

Ship checklist for the **1.2.1 (9)** release. The live App Store version is
**1.0.2 (6)**, so this update carries every change from 1.1.0 + 1.2.0 + 1.2.1
at once. Do the steps in this order.

Key facts:
- Bundle: `ai.tayyibat.tayyibat` · Apple team **QBX2YPY4W8** · App ID `6777743474`
- Signed IPA (already built): `flutter_app/build/ios/ipa/tayyibat.ipa` — `1.2.1 (9)`, 21 MB
- Supabase project ref: `cvznuwvwhnujdgfojmsb`
- Marketing/branch state: code is committed + pushed on `claude/tayyibat-ios-app-ftYsJ`, CI green.

---

## Order of operations (important)

```
1. Supabase: create the reviewer test account          (before submitting)
2. App Store Connect: upload build 9 via Transporter
3. App Store Connect: create the 1.2.1 version record, attach build 9, fill notes
4. Submit for review
5. AFTER 1.2.1 is Approved AND Released to users:
   Supabase: deploy the updated `analyze` function      (the 3-suggestions server)
```

**Why the server deploy is last:** the new `analyze` function returns meal
suggestions as `{"suggestions":[...]}` (three at once). The 1.2.1 app
understands both that and the old single-object shape, but the **currently
live 1.0.2 app understands only the old shape**. If you deploy the server
now, your existing paying users get a blank suggestion card until they
update. The 1.2.1 app runs perfectly against the *old* server (it falls back
to one suggestion), so there is zero rush — deploy the server only once 1.2.1
is the live version and most users have moved over.

---

## Step 1 — Supabase: reviewer test account (before submitting)

Apple can sign in with "Sign in with Apple," so this is optional but
recommended as a fallback for the reviewer.

1. Open the Supabase dashboard →
   https://supabase.com/dashboard/project/cvznuwvwhnujdgfojmsb
2. **Authentication → Users → Add user → Create new user.**
   - Email: `reviewer@tayyibat.ai`
   - Password: choose a strong one (e.g. `Apple@2026` or better). **Do not
     commit it anywhere** — the repo is public.
   - Tick "Auto Confirm User" so no email verification is needed.
3. You will paste this password into App Store Connect in Step 3 (Sign-In
   Information), not into the repo.

No schema or SQL changes are needed for 1.2.1 — the new tables
(`meal_plans`, `plan_days`) and the `meals.was_edited` column are all in the
**on-device** SQLite database, which migrates itself on first launch. Nothing
changes in the Supabase Postgres database.

---

## Step 2 — Upload build 9 with Transporter

The IPA is already built and signed. You do **not** need Xcode Organizer.

1. Open the **Transporter** app (Mac App Store; already installed per prior
   sessions). Sign in with the Apple ID on team QBX2YPY4W8.
2. Drag `flutter_app/build/ios/ipa/tayyibat.ipa` into Transporter.
3. Click **Deliver**. Wait for "Delivered successfully."
4. In App Store Connect, the build appears under **TestFlight → iOS builds**
   after ~5–15 min of processing (it may briefly show "Processing").

If you'd rather rebuild from scratch first (not required — the current IPA is
current with the pushed code):

```bash
cd "/Users/hoss/Code Projects/anthropic-claude-/flutter_app"
git checkout claude/tayyibat-ios-app-ftYsJ && git pull --ff-only
flutter pub get
cd ios && pod install && cd ..
flutter pub run flutter_launcher_icons
flutter build ipa --release
# → build/ios/ipa/tayyibat.ipa
```

---

## Step 3 — Create the 1.2.1 version record

1. App Store Connect → **My Apps → Tayyibat → iOS App**.
2. Top-left, click the **＋ (Add Version or Platform)** → **iOS** →
   version number **`1.2.1`** → Create. (The existing record is 1.0.2; build 9
   will not attach to it — you need a fresh 1.2.1 version.)
3. In the new 1.2.1 page:
   - **What's New in This Version** — paste the **cumulative** block from
     `submission/app-store/release-notes.md` (the ⭐ "USE THIS ONE" section).
     Arabic in the Arabic locale, English in the English (US) locale.
   - **Build** — click **＋** next to Build, pick **build 9**. (If it's still
     processing, wait and refresh.)
   - **Screenshots** — the current live screenshots still apply, but they
     predate nutrition/guidebook/plans. Optional but recommended: refresh the
     6.7" and 5.5" sets to show the calorie tracker, editable meal, and
     suggestions. Graphics tooling notes are in `submission/screenshots/`.
   - **Export Compliance** — "Does your app use encryption?" → the Info.plist
     already declares `ITSAppUsesNonExemptEncryption = false`, so answer
     **No** (HTTPS only). No extra docs needed.
4. **App Review Information** (left nav, under the version):
   - **Sign-In required: Yes.** Sign-In Information → Username
     `reviewer@tayyibat.ai`, Password = the one you set in Step 1.
   - **Notes** — paste the body of `submission/app-store/review-notes.md`
     (mentions the scroll-gated disclaimer, account deletion, camera flow,
     Sign in with Apple for Guideline 4.8).
5. **Pricing** — leave as-is. This stays a paid app at the current tier
   (USD 4.99 / AED 18.99 ≈ $6.50). Do **not** change price.

---

## Step 4 — Submit for review

1. Save all changes on the 1.2.1 page.
2. Click **Add for Review → Submit to App Review**.
3. If Apple's previous 1.0.2 rejection thread is still open, reply there
   noting the fixes shipped (the raw Gemini billing message is now fully
   sanitized server-side; see review-notes).
4. Release option: choose **"Automatically release this version"** or
   **"Manually release"**. Manual is safer here — it lets you release 1.2.1
   and deploy the Supabase server in the same short window (Step 5).

Typical review time: ~24–48h.

---

## Step 5 — Supabase: deploy the updated `analyze` function (AFTER 1.2.1 is live)

Only the **suggest** task changed (now returns 3 meals; `maxOutputTokens`
raised for that task). The image-analysis and weekly-plan tasks are
unchanged, so existing behaviour is unaffected apart from suggestions.

Once 1.2.1 shows as **Ready for Sale** (and, if you chose manual release, you
have released it):

```bash
cd "/Users/hoss/Code Projects/anthropic-claude-"   # repo root, NOT supabase/
supabase functions deploy analyze --no-verify-jwt
```

- `--no-verify-jwt` is required: the function verifies the user JWT itself.
- The `GEMINI_API_KEY` and `SUPABASE_SERVICE_ROLE_KEY` secrets are already
  set in the Supabase dashboard — you don't re-enter them.
- Verify after deploy: open the app's Suggestions tab → "Suggest 3 meals"
  should return three distinct cards. You can also watch
  Supabase → Edge Functions → `analyze` → Logs for HTTP 200s.

Keep Gemini billing funded (it was depleted once and caused the 1.0.2
rejection). Google AI Studio → Billing.

---

## Rollback / safety notes

- **App:** if 1.2.1 has a problem, Apple lets you keep 1.0.2 as the released
  version until you're ready; a bad build can be rejected/removed before
  release.
- **Server:** the previous `analyze` version stays available in Supabase's
  function history; redeploy the prior revision if the 3-suggestion prompt
  misbehaves. The 1.2.1 app tolerates the old server automatically.
- **On-device DB:** the schema-v4 migration is additive (new tables + one
  column) and is covered by tests; existing meals, body responses, and
  fasting logs are untouched.

---

## What is NOT needed for 1.2.1

- No Postgres schema/SQL changes.
- No new Supabase secrets.
- No Apple capability/entitlement changes (Sign in with Apple already set up).
- No price change.
- No Google Play action (that track is on its own clock).
