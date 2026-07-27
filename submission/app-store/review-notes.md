# Notes for the Apple reviewer

This text goes into App Store Connect → **App Information → Notes for
Review** field. It's only seen by Apple's review team.

## Sign-in
- Reviewers can sign in with Apple from the auth screen — no test
  account needed.
- A traditional email/password flow is also available.
- Optional test account if Apple prefers email login:
  - Email: `reviewer@tayyibat.ai`
  - Password: **set in Supabase Auth → Users; paste the real value
    directly into App Store Connect → "Sign-In Information" or into the
    review reply. DO NOT commit the password to this repo — it is public.**

  (Create this account in Supabase Auth → Add user before submitting. The
  reviewer will use it to bypass any first-time onboarding state.)

## Onboarding gate
- First sign-in lands on a scroll-gated medical disclaimer
  ("التنبيه الطبي"). The reviewer must scroll to the end before the
  green "أوافق وأتحمل المسؤولية" button activates. This is intentional
  and a one-time step.
- After acceptance, the main tabs appear: اليوم / السجل / الدليل /
  الإعدادات (Today / History / Guide / Settings).

## Account deletion
- Settings → "حذف الحساب" → confirm → a blocking dialog confirms
  the account was deleted from the server.
- Implementation: hits our Supabase Edge Function which calls the
  auth admin API to delete the user, then signs out locally.

## Camera & photo library
- The Today tab → "صوّر وجبتك" → triggers either the camera or photo
  picker. Photos are sent to a Supabase Edge Function (`analyze`) which
  forwards to Google Gemini for analysis. Photos are not retained on
  our servers.

## Notifications
- All notifications are scheduled locally via UNUserNotifications.
- No push notifications, no remote server.

## Network
- Backend: `https://cvznuwvwhnujdgfojmsb.supabase.co` (Supabase).
- AI: Google Generative Language API (Gemini), proxied through our
  Supabase Edge Function with a per-user daily cap and refund-on-failure.
- No third-party trackers, no analytics, no ads.

## Required disclaimers
- The app does not provide medical advice, prescribe medication, or
  treat any condition. The disclaimer screen and Settings link reaffirm
  this. The privacy policy at https://tayyibat.ai/privacy.html restates
  it as well.

## Localization
- Arabic primary, English secondary. Layout is RTL throughout.
- iPhone only (we declared portrait orientation; no iPad layout).

## Anything special to test
- Sign in with Apple (Guideline 4.8 compliance).
- Account deletion (App Store Review Guideline 5.1.1(v)).
- Medical disclaimer enforcement (no health claims anywhere).
