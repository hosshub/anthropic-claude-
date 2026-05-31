# Enable Sign in with Apple — required before App Store submission

Apple's App Review Guideline **4.8** requires that any app offering a
third-party social login (Google, in our case) **also** offer Sign in
with Apple. Submitting without it = automatic rejection.

This guide assumes your Apple Developer Program enrollment is active.

## 1. Add the capability in your App ID

In **Apple Developer Portal** → Certificates, Identifiers & Profiles →
**Identifiers** → click your app's bundle ID (e.g. `ai.tayyibat.hoss` or
your production bundle).

- Capabilities → check **Sign in with Apple** → Save.

## 2. Add the capability in Xcode

Open `flutter_app/ios/Runner.xcworkspace`.

- Select the **Runner** target → **Signing & Capabilities**.
- Click **+ Capability** → **Sign in with Apple**.
- Xcode will refresh your provisioning profile automatically.

## 3. Configure Apple as a Supabase auth provider

In Supabase dashboard → **Authentication → Providers → Apple**.

You need (from developer.apple.com):

- **Services ID** for your app (create one under Identifiers → Services IDs).
  Example: `ai.tayyibat.web-signin`. The web-style Services ID is what
  Apple calls "Client ID" in the Supabase form. **Add your production
  bundle ID** (e.g. `ai.tayyibat.tayyibat`) in **Authorized Domains** and
  Return URLs.
- **Secret key**: under **Keys** → register a new Sign in with Apple key →
  download the `.p8` file → upload to Supabase.
- **Team ID**: top right of Apple Developer portal.
- **Key ID**: shown when you created the key.

Save. Supabase will now accept Apple ID tokens.

## 4. Flip the flag in the app

```dart
// flutter_app/lib/config.dart
class AppConfig {
  ...
  static const bool appleSignInEnabled = true; // was false
}
```

## 5. Rebuild and verify

```bash
cd ~/anthropic-claude-/flutter_app
flutter clean && flutter pub get
cd ios && pod install && cd ..
flutter run -d <your iPhone>
```

On the auth screen you should now see the system Sign in with Apple
button below the Google button. Tap it → Face ID / Touch ID flow →
should drop you into the disclaimer screen, then the main shell.

## 6. Commit and submit

Commit the `config.dart` change before archiving for App Store Connect:

```bash
git add flutter_app/lib/config.dart
git commit -m "flutter: enable Sign in with Apple for App Store submission"
git push
```

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Sign-in pops Apple sheet but never returns | Services ID mismatch | Make sure Supabase's Apple "Client IDs" includes BOTH your bundle ID (for native iOS) AND your Services ID |
| "Unable to sign in" Arabic toast | Supabase secret expired or wrong key | Re-issue the .p8 key and update Supabase |
| Button hidden on the auth screen | `appleSignInEnabled = false` | Flip to true |
| Works in dev, fails in TestFlight | Provisioning profile didn't pick up the capability | In Xcode → Signing & Capabilities → click "Try Again" next to the team picker |
