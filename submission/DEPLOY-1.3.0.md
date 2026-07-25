# Deploying Tayyibat 1.3.0 (build 11)

Ship checklist for **1.3.0 (11)**. The live App Store version is still
**1.0.2 (6)**, so this update carries 1.1.0 + 1.2.0 + 1.2.1 + 1.3.0 at once.

Key facts:
- Bundle `ai.tayyibat.tayyibat` · Apple team **QBX2YPY4W8** · App ID `6777743474`
- IPA: `flutter_app/build/ios/ipa/tayyibat.ipa` — `1.3.0 (11)`
- Supabase project `cvznuwvwhnujdgfojmsb` — **`analyze` already deployed** and
  backward compatible, so there is **no deploy-ordering constraint this time**.

---

## What's NEW about this submission vs 1.2.1

1.3.0 adds **HealthKit**, which is the one thing that can get this build
rejected if the paperwork is wrong. Everything below marked ⚠️ is new.

---

## Step 1 — ⚠️ HealthKit capability on the App ID

Automatic signing usually enables this for you, but confirm it, or the
upload fails validation with a provisioning-profile/entitlement mismatch:

1. https://developer.apple.com/account → **Certificates, IDs & Profiles**
   → **Identifiers** → `ai.tayyibat.tayyibat`
2. Ensure **HealthKit** is checked. (Do **not** tick "Clinical Health Records"
   — we don't use it, and it triggers extra review.)
3. Save. If you changed it, regenerate the App Store provisioning profile.

Verify the built IPA carries it:
```bash
cd "/Users/hoss/Code Projects/anthropic-claude-/flutter_app"
unzip -p build/ios/ipa/tayyibat.ipa "Payload/Runner.app/embedded.mobileprovision" \
  | strings | grep -A2 healthkit
```

## Step 2 — Upload the build

The IPA is already signed. **Transporter** (installed):
1. Open Transporter, sign in on team QBX2YPY4W8.
2. Drag in `flutter_app/build/ios/ipa/tayyibat.ipa` → **Deliver**.
3. Build **11** appears under TestFlight → iOS builds after ~5–15 min.

## Step 3 — Create the 1.3.0 version record

App Store Connect → Tayyibat → iOS App → **＋ Add Version** → `1.3.0`.

- **What's New** — paste the v1.3.0 block from
  `submission/app-store/release-notes.md` (Arabic → Arabic locale, English →
  English (U.S.)).
- **Build** — ＋ → select build **11**.
- **Screenshots** — see `submission/screenshots/` (6.9" in `ar/` and `en/`,
  6.5" in `6.5in/ar` and `6.5in/en`).
- **Export compliance** — **No** (HTTPS only; `ITSAppUsesNonExemptEncryption`
  is already false in Info.plist).
- **Pricing** — unchanged.

## Step 4 — ⚠️ App Privacy: add the Health & Fitness entry

App Store Connect → **App Privacy** → Edit.

Add data type **Health & Fitness → Health**:

| Question | Answer |
|---|---|
| Is this data collected? | **No** — it is read on-device and never transmitted |
| Linked to the user? | N/A (not collected) |
| Used for tracking? | **No** |

If ASC forces "collected", answer: **used for App Functionality only**, **not
linked to identity**, **not used for tracking**. The app reads steps, active
energy, sleep, and weight purely to display them and adjust the local calorie
budget; nothing is uploaded. Meal calories are only ever *written* to Health,
and only when the user turns on the opt-in switch.

Nothing else in the privacy label changes from 1.0.2.

## Step 5 — ⚠️ Review notes (add the HealthKit paragraph)

Paste the body of `submission/app-store/review-notes.md`, then append:

```
APPLE HEALTH (new in 1.3.0)
- Optional and off until the user taps Settings → "Connect Apple Health".
- READ: steps, active energy, sleep, weight. Shown on the Today and History
  tabs and used to adjust the user's own daily calorie budget locally.
- WRITE: dietary energy only, and only after the user separately enables
  "Write meals to Health". Off by default.
- No health data is transmitted off the device, and none is used for tracking
  or advertising. The app makes no medical claims and does not diagnose.
- To test without Health data: the activity card simply does not appear;
  every other feature works normally.
```

Sign-In Information stays as-is (Sign in with Apple works; the
`reviewer@tayyibat.ai` fallback lives in Supabase Auth).

## Step 6 — Submit

**Add for Review → Submit to App Review.** Release option: **Manually
release** is still the safer choice, though 1.3.0 has no server-ordering
dependency (the `analyze` function already serves old and new clients).

---

## Rollback / safety

- **App:** 1.0.2 stays live until you release 1.3.0.
- **Server:** already deployed and backward compatible; the previous revision
  is in Supabase's function history if needed.
- **On-device DB:** schema v5 is additive and migration-tested (v3→v5 and
  v4→v5 both covered).

## Not needed for 1.3.0

- No Postgres/SQL changes, no new Supabase secrets.
- No price change.
- No Google Play action (that track is on its own clock; note the Android
  minSdk moved to 26 for Health Connect).
