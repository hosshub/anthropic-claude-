# Sentry (crash reporting) — setup

The Flutter app integrates `sentry_flutter` in `lib/main.dart` with
privacy-first defaults. It is **opt-in at build time**: builds without a
DSN do not send anything (the init block is skipped entirely).

## One-time setup

1. Sign up at <https://sentry.io>. **Pick the EU region** when creating the
   organization — once set, the region can't be changed without recreating
   the org. EU region means data is processed/stored in Frankfurt.
2. Create a project: Platform = **Flutter**, Project name = `tayyibat`.
3. Sentry shows you a DSN like:
   ```
   https://abc123def456@o9999999.ingest.de.sentry.io/1234567
   ```
   The `.de.sentry.io` confirms EU residency. Copy it.
4. **Do not commit the DSN.** Although technically a public ingest endpoint,
   keep it out of the repo for hygiene; pass it at build time.

## Local dev / device builds

```bash
flutter run -d <udid> \
  --dart-define=SENTRY_DSN=https://abc123def456@o9999999.ingest.de.sentry.io/1234567
```

## Release builds (App Store / Play Store)

```bash
cd ~/anthropic-claude-/flutter_app
flutter pub run flutter_launcher_icons
flutter build ipa --release \
  --dart-define=SENTRY_DSN=https://...@o....ingest.de.sentry.io/...
# or for Android:
flutter build appbundle --release \
  --dart-define=SENTRY_DSN=https://...@o....ingest.de.sentry.io/...
```

If you forget the `--dart-define`, the binary still ships fine — it just
won't report errors. No runtime errors from a missing DSN.

## What gets sent

- Unhandled Dart exceptions + native (iOS / Android) crashes.
- Stack traces.
- Anonymous session start/end ping (no PII; used to compute crash-free %).
- Flutter framework version, OS version, device model class
  (e.g., `iPhone14,5`).

## What we explicitly turn off

| Option | Value | Why |
|---|---|---|
| `sendDefaultPii` | `false` | No IP, no user agent, no usernames |
| `attachScreenshot` | `false` | UI captures could leak meal photos / notes |
| `attachViewHierarchy` | `false` | Same risk |
| `tracesSampleRate` | `0.0` | No performance traces |
| `profilesSampleRate` | `0.0` | No CPU/RAM samples |
| `enableUserInteractionTracing` | `false` | No tap-by-tap breadcrumbs |
| `enableUserInteractionBreadcrumbs` | `false` | Same |

A `beforeSend` hook also wipes `user`, request headers, cookies, and
request body fields if anything sneaks them in — belt-and-suspenders on top
of `sendDefaultPii = false`.

## Privacy policy implications

`web/privacy.html` already covers "diagnostic data, anonymously, to keep
the app stable" under the third-party processors section. No changes
required for App Store / Play Store privacy labels:

- **Crash data** is collected for "App Functionality" with **no linkage to
  identity** and **no tracking** — which is the default Apple App Privacy
  classification for crash reporters.

## Verifying it works

After installing a build with a DSN baked in:

1. Run the app once on a real device so the SDK initializes.
2. Sentry Dashboard → Projects → `tayyibat` → Issues. The first real crash
   shows up here within ~30s.
3. To force a test event without crashing the UI, in `lib/main.dart`
   temporarily add inside `_bootstrap()`:
   ```dart
   await Sentry.captureMessage('hello from tayyibat');
   ```
   Run once, see it in the dashboard, then revert.

## Quotas

Sentry's free tier (Developer plan) gives 5,000 errors / 10,000 perf units
per month. With perf disabled, only errors count — Tayyibat shouldn't come
close. If you outgrow it, the **Team** plan ($26/mo) is plenty.
