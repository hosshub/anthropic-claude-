# Apple Privacy "Nutrition Labels" — answers

App Store Connect → My App → **App Privacy → Edit**.
For every category Apple asks: "Does this app collect any of these data?"
Answer each one in turn.

These answers match the actual production behavior.

## Contact info
- **Email address** → ✅ **Yes, we collect**.
  - Linked to user: **Yes**.
  - Used for tracking: **No**.
  - Purpose: **App Functionality** + **Analytics** → pick **App Functionality** only (we don't analyze it).
- **Name** → ❌ **No**.
- **Phone number, Physical address, Other contact info** → ❌ **No**.

## Health & Fitness
- **Health, Fitness** → ❌ **No** (we are wellness/dietary, not health-data).

## Financial info
- All → ❌ **No**.

## Location
- All → ❌ **No**.

## Sensitive info
- All → ❌ **No**.

## Contacts
- ❌ **No**.

## User Content
- **Photos or Videos** → ✅ **Yes** (meal photos sent for analysis).
  - Linked to user: **Yes** (the request is authenticated).
  - Used for tracking: **No**.
  - Purpose: **App Functionality**.
- **Audio, Customer Support, Gameplay Content, Other** → ❌ **No**.

## Browsing History
- ❌ **No**.

## Search History
- ❌ **No**.

## Identifiers
- **User ID** → ✅ **Yes** (Supabase account uuid).
  - Linked to user: **Yes**.
  - Used for tracking: **No**.
  - Purpose: **App Functionality** (sign-in + daily usage cap).
- **Device ID** → ❌ **No**.
- **Other identifiers** → ❌ **No**.

## Purchases
- ❌ **No**.

## Usage Data
- **Product Interaction** (the daily analysis counter) → ✅ **Yes**.
  - Linked to user: **Yes**.
  - Used for tracking: **No**.
  - Purpose: **App Functionality** (enforce daily limit).
- **Advertising Data, Other Usage Data** → ❌ **No**.

## Diagnostics
- ❌ **No**.

## Other Data
- ❌ **No**.

---

## Tracking
At the top section "Do we use this data to track users across other apps or
websites?" → **No** for every type above.

This means **App Tracking Transparency prompt is NOT required**.

---

## Privacy policy URL
```
https://tayyibat.ai/privacy.html
```

---

## Account Deletion
App Store Connect → **App Privacy** asks: "Does your app provide users with a
way to request deletion of their account?" → ✅ **Yes** (Settings → "حذف الحساب").

This is **required for any app that creates accounts** as of iOS 2022+.
