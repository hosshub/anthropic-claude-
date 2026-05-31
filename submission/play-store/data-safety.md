# Google Play — Data Safety form answers

In Play Console go to **Policy → App content → Data safety → Start**.
Answer in this order — these answers reflect the actual behavior of the
production build.

## Data collection & sharing — top-level

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **Yes** |
| Is all of the user data collected by your app encrypted in transit? | **Yes** (HTTPS to Supabase + Gemini) |
| Do you provide a way for users to request that their data be deleted? | **Yes** — in-app at Settings → "حذف الحساب" |

## Data types collected

### Personal info
- **Email address** — Collected, Required → Used for **Account management**. Not shared.

### App activity
- **Other in-app actions** (the daily-usage counter) — Collected, Required → Used for **App functionality** (daily analysis cap). Not shared.

### Photos and videos
- **Photos** — Collected, Required → Used for **App functionality** (meal analysis). Not shared *with third parties for advertising or analytics*. We disclose that meal photos transit through Google Gemini for processing only; declare that under "Third-party processing" if Play asks.
- Mark **"Data is processed ephemerally"** — Yes (we don't retain photos after analysis).

### Files and docs
- **None**.

### Calendar, Contacts, Messages, Location, Health & fitness, Financial, Web browsing
- **None.**

## Data types shared
**None** — no advertising, analytics, or third-party sharing.

(Server-side processing of photos by Gemini is **processing**, not "sharing", per Play's distinction. If asked: Gemini does not use the photos to train models per the Gemini API developer terms.)

## Security practices
- ✅ Data encrypted in transit
- ✅ Users can request their data be deleted
- ✅ The app follows Play Families Policy → **N/A** (not a family/children's app)
- ✅ Independent security review → **No**

## Privacy policy URL
```
https://tayyibat.ai/privacy.html
```

---

## Content rating questionnaire
Open **Policy → App content → Content rating → Start questionnaire**.
- Category: **Reference, News, or Educational** (closest fit; we aren't a game).
- No violence, no sexual content, no profanity, no gambling, no controlled substances, no user-generated content.
- Expected rating: **Everyone**.

## Target audience and content
- Target age group: **18+** (adults). We intentionally exclude minors because of the medical disclaimer.
- Does your app appeal to children? **No.**

## Ads
- Does your app contain ads? **No.**

## Government apps
- **No.**

## News apps
- **No.**

## COVID-19 / health apps
- **No** — we are wellness/dietary, not a health-condition app, and we make no medical claims.
