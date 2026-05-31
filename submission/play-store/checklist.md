# Google Play submission — step-by-step

Prereqs:
- Google Play Console account ($25 one-time): https://play.google.com/console
- Latest release APK or AAB built locally (`flutter build appbundle --release`)
- Screenshots from `submission/screenshots/`

## 1. Create the app
Play Console → **All apps → Create app**.
- App name: **الطيبات** (Arabic primary)
- Default language: **Arabic (ar)** — add **English (United States)** as additional
- App or game: **App**
- Free or paid: **Free**
- Declarations: accept all (Play policies, US export laws)

## 2. App access
Set up → **App access**.
- "All functionality is available without special access"? **No.**
- Add a test login the reviewer can use:
  - Email: a real email account you control
  - Password: that account's password
  - Instructions: "تسجيل دخول بالبريد. يمكن اختبار Google Sign-In أيضاً."

## 3. Ads
- **App does NOT contain ads.**

## 4. Content rating
Go through **Policy → App content → Content rating** questionnaire.
- Category: **Reference, News, or Educational**.
- All "no" answers.
- Expected: **Everyone**.

## 5. Target audience
- Target age: **18+**.
- Does the app unintentionally appeal to children? **No.**
- Why 18+: medical disclaimer; system not validated for minors.

## 6. News app declaration
- **No.**

## 7. COVID-19 / health
- **No.**

## 8. Data safety
Open `data-safety.md` in this folder and copy answers in order.

## 9. Government apps
- **No.**

## 10. Financial features
- **No.**

## 11. Store listing
Go to **Grow → Store presence → Main store listing**.

### Arabic (default)
Copy from `listing-ar.md`:
- App name
- Short description
- Full description
- App category: **Health & Fitness**
- Tags: pick `Health and wellness` + `Nutrition`

### English (US) localization
Add → English → copy from `listing-en.md`.

### Graphics
- **App icon**: 512×512 PNG — generate from `flutter_app/assets/icon/icon.png` upscaled or run `flutter pub run flutter_launcher_icons` and grab the highest-res Android variant.
- **Feature graphic**: 1024×500 PNG (required) — solid emerald background with the word "الطيبات" centered in white serif + the leaf icon. If you don't have this yet, ship without it and re-upload later; Play won't publish without it though.
- **Phone screenshots**: 2–8 images, see `screenshots/README.md` for dimensions and which screens.
- **7-inch tablet screenshots**: optional, skip.
- **10-inch tablet screenshots**: optional, skip.

### Contact info
- Email: `app@tayyibat.ai`
- Website: `https://tayyibat.ai`
- Phone: leave blank
- Privacy Policy: `https://tayyibat.ai/privacy.html`

## 12. Create a release
**Production → Create new release** (or **Internal testing** first — see `internal-testing.md`).

1. Generate the bundle:
   ```bash
   cd ~/anthropic-claude-/flutter_app
   flutter build appbundle --release
   ```
   Output: `build/app/outputs/bundle/release/app-release.aab`

2. Upload `app-release.aab`.

3. Release name: `1.0.0`.

4. Release notes — copy from `release-notes.md`:
   - Arabic
   - English

5. **Review release → Start rollout to Production**.

## 13. Wait
Initial reviews typically take **1–3 days**. You'll get email decisions.

## Common rejection causes (and how we avoid them)
- ❌ Missing privacy policy URL → ✅ we have one.
- ❌ Account-deletion required (Play policy 2024+) → ✅ we ship it in-app.
- ❌ Medical claims → ✅ we have a disclaimer; the listing copy is careful.
- ❌ Permissions mismatch with declared usage → ✅ camera/notifications all justified.

## After approval
- Production rollout defaults to 100% phased over 14 days. If you want all users immediately, edit the rollout percentage in the release.
- Subsequent releases: same flow, just upload a new AAB with a bumped versionCode.
