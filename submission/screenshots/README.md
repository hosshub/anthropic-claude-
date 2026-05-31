# Screenshots — what to capture for each store

You need screenshots at specific dimensions for each store. Easiest path:
take them on a real device (iPhone 17 Pro Max and any modern Android),
then optionally use a screenshot frame tool later.

## Required dimensions

### Google Play (Phone)
- Min: 320px on short side
- Max: 3840px on long side
- Aspect ratio: 16:9 or 9:16
- Format: PNG or JPEG, 24-bit, no alpha
- Count: 2-8

Native iPhone Pro Max / Pixel 8 Pro screenshots already meet this — no resizing.

### App Store (iPhone)

| Device | Required dimensions | Required? |
|---|---|---|
| 6.9-inch (iPhone 17 Pro Max) | **1320 × 2868** | ✅ Yes |
| 6.7-inch (iPhone 14/15 Pro Max) | 1290 × 2796 | Reuses 6.9" if you don't supply |
| 6.5-inch (iPhone XS Max / 11 Pro Max) | 1242 × 2688 | No (auto-scales) |
| 5.5-inch (iPhone 8 Plus) | 1242 × 2208 | Only required if you have nothing else |
| iPad | various | Skip (iPhone-only app) |

Count: **3 to 10 per locale** (Arabic + English).

## The 6 screens to capture (in order)

These tell the value story in 6 frames. Capture each twice (Arabic locale
+ English locale) for a complete bilingual listing.

| # | Screen | What to show | Headline (for marketing overlay) |
|---|---|---|---|
| 1 | Today tab with a meal logged | Score ring at ~75%, one meal in the row | "صوّر وجبتك واعرف تقييمها فوراً" / "Photograph any meal — score it instantly" |
| 2 | Result screen of a single meal | 90% green score + items list with zone badges | "كل عنصر بإشارته" / "Every item gets a zone" |
| 3 | Guide → Eating Map → green zone | The new tabbed eating map with chips | "خريطة أكل واضحة" / "A clear eating map" |
| 4 | Suggestions screen → Weekly Plan tab generated | The 7-day plan cards | "خطة أسبوع بالذكاء الاصطناعي" / "AI weekly plan" |
| 5 | History → Calendar view | Calendar with several colored dots, day summary open | "تقويم التزام شهري" / "Monthly compliance calendar" |
| 6 | Body Intelligence with the trend chart | The 30-day line chart + sleep distribution | "Body Intelligence — منحنى ٣٠ يوم" / "Body Intelligence — 30-day trend" |

## How to capture them (iPhone)

1. Make sure your iPhone is in **light mode** (Settings → Display & Brightness).
2. Make sure the status bar shows full battery, full signal, and
   `9:41 AM` is **NOT** required — but Apple recommends a clean status bar.
3. Take screenshot with Side + Volume Up button.
4. AirDrop to your Mac.
5. Save into `submission/screenshots/ios/ar/` and `.../en/`.

For Arabic locale screenshots, set system language to Arabic temporarily
(Settings → General → Language & Region → Arabic). The app's strings
are already Arabic regardless, but the iOS chrome (status bar text,
clock) will localize too.

## How to capture them (Android)
- Use Android emulator (Pixel 8 Pro AVD) with display set to
  1080 × 2400 — that hits Play's recommended ratio.
- `adb exec-out screencap -p > screen.png` for clean captures, OR
- Power + Volume Down on the emulator window.
- Save into `submission/screenshots/android/ar/` and `.../en/`.

## (Optional) framing
Apple and Google **don't** require device frames — bare screenshots are
fine and convert better. If you want to add a marketing border with a
short headline, use **Screenshots.pro**, **AppLaunchpad**, or
**Figma** with a phone mockup template.

## Submission folders (create on your Mac after capturing)

```
submission/screenshots/
├── ios/
│   ├── ar/                # 1-6 .png
│   └── en/                # 1-6 .png
└── android/
    ├── ar/                # 1-6 .png
    └── en/                # 1-6 .png
```

These don't need to be committed to git — they're only needed at upload
time. Add them to `.gitignore` if you'd like.
