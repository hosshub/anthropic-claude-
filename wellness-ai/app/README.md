# Wellness AI — App (Flutter)

Arabic-first (RTL) Flutter app — consumer surface scaffolded; provider surface
to follow (see ../docs/PRD.md §7).

## First run
Requires Flutter ≥ 3.24.

```bash
cd wellness-ai/app

# One-time: generate ios/ + android/ without touching lib/ or pubspec.yaml
flutter create --org ai.wellness --platforms=ios,android .

flutter pub get

# Point the app at your Supabase project (or edit lib/config.dart defaults):
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_ANON_KEY
```

## Manual platform config after `flutter create`
**iOS — `ios/Runner/Info.plist`:** add `NSCameraUsageDescription`,
`NSPhotoLibraryUsageDescription`, and the `CFBundleURLTypes` entry for the
`wellnessai` scheme (OAuth return). Also apply the **SceneDelegate fix** so deep
links reach `app_links` (see the Tayyibat README for the exact steps — same
issue).

**Android — `AndroidManifest.xml`:** `INTERNET` + `CAMERA` permissions and the
`<intent-filter>` for `wellnessai://login-callback`.

## Structure
```
lib/
├── main.dart            # Supabase init + providers + RTL/Arabic
├── app.dart             # auth → disclaimer → shell routing
├── config.dart          # constants (no secrets)
├── theme/theme.dart     # teal + coral palette, plan-fit zone colors
├── models/              # meal.dart, plan.dart  (+ TODO: provider_link, body_log)
├── services/            # auth, onboarding, analyze  (+ TODO: plan, link, notif, wearable)
├── shell/main_shell.dart# Today / Log / Plan / Move / Settings
├── widgets/             # shared (placeholder_scaffold)
└── features/
    ├── auth/            # email + Google (+ TODO Apple)
    ├── onboarding/      # scroll-gated medical disclaimer
    ├── today/           # daily ring + scan CTA  (scaffold)
    ├── capture/         # photo → analyze proxy   (scaffold, wired to backend)
    ├── log/ plan/ move/ # placeholders → PRD epics C3/C4/C5
    └── settings/        # account, provider link, disclaimer, sign out
```

## Build status
This is a **scaffold** — it establishes architecture + the capture→analyze path
against the backend stub. It has **not** been compiled here (no Flutter SDK in
the authoring environment); expect minor fixups on first `flutter run`, and
build out the epics per `../docs/PRD.md §15` (MVP scope).

Stack mirrors the proven Tayyibat app (Flutter + Supabase + server-side
multimodal-AI proxy), so patterns (disclaimer gate, OAuth deep-link, daily-cap
proxy, RTL) port directly.
