# App Store submission — step-by-step

Prereqs:
- Active Apple Developer Program enrollment ($99/yr).
- `appleSignInEnabled = true` in `lib/config.dart` (Apple won't accept the
  build otherwise — see `apple-signin-setup.md`).
- Production bundle ID configured everywhere (Apple Developer Portal,
  Xcode, Supabase Apple provider).
- Screenshots from `submission/screenshots/`.

## 1. Set up App Store Connect
https://appstoreconnect.apple.com → **My Apps → + → New App**.

- Platforms: **iOS**
- Name: **الطيبات**
- Primary Language: **Arabic**
- Bundle ID: pick your registered bundle (e.g. `ai.tayyibat.tayyibat`)
- SKU: `tayyibat-ios-1`
- User Access: Full Access

## 2. App Information
Sidebar → **App Information**.

- **Subtitle (Arabic)**: from `listing-ar.md`
- **Subtitle (English)**: from `listing-en.md`
- **Privacy Policy URL**: `https://tayyibat.ai/privacy.html`
- **Category**: Primary **Health & Fitness**, Secondary **Food & Drink**
- **Content Rights**: Does this app contain third-party content? **No**
- **Age Rating**: open the questionnaire → answer all "None" → expect **17+**
  - (17+ comes from the medical disclaimer; the rest is harmless.)
- **Notes for the reviewer**: copy from `review-notes.md`

## 3. Pricing and Availability
- **Price**: Paid — $4.99 USD base tier; regional prices set per country (US/UAE/KSA/Egypt/EU). Mirror the same model on Google Play.
- **Availability**: all countries where Saudi Arabia, Egypt, UAE, US are
  included — easiest is "All territories".

## 4. App Privacy
Sidebar → **App Privacy → Get Started / Edit**.
- Open `privacy-labels.md` in this folder and answer each section.

## 5. Build the IPA
```bash
cd ~/anthropic-claude-/flutter_app
flutter build ipa --release
```

This produces an `.ipa` at `build/ios/ipa/tayyibat.ipa`.

## 6. Upload via Transporter
Open the **Transporter** Mac app (free on Mac App Store) → drag the
`.ipa` in → **Deliver**.

Wait ~10 minutes for the build to appear under
"TestFlight → Builds" in App Store Connect.

## 7. TestFlight (recommended for one friend test first)
- TestFlight tab → **Internal Testing → + Group → Tayyibat Internal**.
- Add your own email + 1-2 friends (max 100 internal testers).
- After they install TestFlight on their iPhone, they get an email
  invitation and can install in seconds.

Use TestFlight for at least 1-2 days to catch crashes / odd states
before submitting for App Store review.

## 8. Prepare the version for review
Sidebar → **iOS App → 1.0 Prepare for Submission**.

### Localizations
- Add **English (US)** as additional localization (Arabic is primary).
- For each locale fill: Name, Subtitle, Promotional Text, Description,
  Keywords, Support URL, Marketing URL.
- Source: `listing-ar.md` and `listing-en.md`.

### Screenshots
- 6.7-inch iPhone (Pro Max): 6 images required (1290×2796 or 1320×2868).
- 6.5-inch iPhone (XS Max / 11 Pro Max): 6 images optional.
- 5.5-inch iPhone (8 Plus): legacy — only required if you don't have a
  6.7-inch set. Skip.
- iPad: not required (we are iPhone-only).
- See `submission/screenshots/README.md` for which screens to capture.

### App Preview (video)
- Optional. Skip for v1; revisit later.

### General App Information
- Copyright: `© 2026 Tayyibat`
- Routing App Coverage File: skip
- Trade Representative Contact: skip (only required for Korea)

### App Review Information
- First Name / Last Name / Email Address / Phone Number — yours
- Sign in required: **Yes** → use the reviewer test account from
  `review-notes.md` OR rely on Sign in with Apple (preferred)
- Notes: paste from `review-notes.md`

### Version Release
- **Automatically release this version** is fine; or pick "Manually
  release" if you want to time the launch.

## 9. Build selection
At the top of the "Prepare for Submission" page click **+** under
**Build** → pick the uploaded build from Transporter.

Provide **Export Compliance**:
- Does your app use encryption? **Yes, only standard HTTPS**.
- Does it qualify for the exemption (3(b)(3))? **Yes**.

## 10. Submit
Bottom of page → **Save** → top right → **Submit for Review**.

Initial review takes **24-72 hours** typically. You'll get email
notifications at each state change.

## Common rejection reasons (and how we avoided them)
- ❌ Guideline 4.8 (Sign in with Apple) → ✅ enabled.
- ❌ Guideline 5.1.1(v) (account deletion) → ✅ in-app, hits Supabase admin API.
- ❌ Guideline 1.4.1 (medical content) → ✅ disclaimer + no claims.
- ❌ Guideline 4.0 (design/HIG) → ✅ standard UIKit/Material via Flutter, RTL respected.
- ❌ Guideline 2.5.1 (private APIs) → ✅ all plugins are public.
- ❌ Guideline 2.3.10 (irrelevant keyword stuffing) → ✅ keywords match features.

## After approval
- Status changes to **Ready for Sale** within an hour of approval.
- Subsequent releases: increment version in `pubspec.yaml`
  (`1.0.0+1` → `1.0.1+2` etc.), build, upload via Transporter, repeat the
  "Prepare for Submission" steps with the new build.
