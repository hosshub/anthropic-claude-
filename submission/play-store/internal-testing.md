# Internal Testing track — share with friends without a public release

Internal Testing lets up to 100 testers install the app from Play Store
without it being publicly listed. It's the cleanest replacement for
distributing APKs via Google Drive.

## 1. Set up
Play Console → **Testing → Internal testing**.

## 2. Build the bundle
```bash
cd ~/anthropic-claude-/flutter_app
flutter build appbundle --release
```
Upload `build/app/outputs/bundle/release/app-release.aab`.

Release notes: copy from `release-notes.md` (Arabic). Keep them short — testers see them inside Play Store.

## 3. Add testers
**Testers** tab → **Create email list**.
- List name: "Internal testers"
- Add tester emails (max 100): comma-separated Gmail/Google Workspace addresses
- Save → check the list under **Testers**.

## 4. Share the opt-in link
After the release is processed (a few minutes to a couple of hours), Play
gives you a **"Copy link"** option. Send that URL to your testers via
WhatsApp / email — they tap it, accept the invitation, then install the
app from Play Store like any other.

Format:
```
https://play.google.com/apps/internaltest?id=ai.tayyibat.tayyibat
```

## 5. Updating
Push a new build → upload to the same Internal track → testers get an
auto-update from Play Store within a few hours.

## Notes for testers
- They must use the Gmail you added.
- Their device must be at least Android 5.0 (API 21).
- Country restrictions don't apply at internal track.
- All Tayyibat features work: Google sign-in returns to the app (Custom Tabs auto-dismiss on Android), local data persists across updates.

## Promoting Internal → Production
When you're ready for the public release, you can **Promote** the internal
build directly to Production from the release page. No re-upload needed.
