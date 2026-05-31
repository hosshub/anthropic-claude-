# الطيبات — نسخة Flutter (Phase F2.5 + F4)

نسخة Flutter من تطبيق الطيبات تعمل على **iOS و Android** من قاعدة كود واحدة،
باستخدام نفس الواجهة الخلفية (Supabase + Gemini Edge Function) المستخدمة في نسخة SwiftUI.

## ما هو موجود حتى F4 (تكافؤ مع SwiftUI v2 + ميزات Android)

### الأساس
- ثيم الطيبات بعربية RTL وألوان النظام، **شريط تبويب سفلي بأربع تبويبات**:
  **اليوم / السجل / الدليل / الإعدادات**.
- تسجيل دخول وتسجيل بالبريد عبر Supabase.
- **تسجيل دخول عبر Google** (تدفّق OAuth بمتصفّح + رابط عائد `tayyibat://login-callback`).
- **تسجيل دخول عبر Apple** (أصلي على iOS، معطّل افتراضياً حتى عضوية Apple Developer
  ثم يُفعّل بقلب `appleSignInEnabled` في `lib/config.dart` إلى `true`).

### التحليل والسجل
- تصوير → تحليل Gemini → **حفظ محلي تلقائي** (SQLite + ملف JPEG على القرص).
- تفاصيل الوجبة بإشارات المناطق (أخضر/أصفر/أحمر) + تنبيه الأصفر.
- شاشة اليوم تعرض حلقة متوسط الالتزام وشريطاً أفقياً لوجبات اليوم.
- تبويب السجل: قائمة كل الوجبات + قسم **"كيف يتجاوب جسمك؟" (Body Intelligence)**.

### متابعة الجسم
- تدفّق صفحات بـ ٥ أسئلة + بطاقة ملخّص في تفاصيل الوجبة.

### Body Intelligence (جديد F3)
- متوسط الشبع ومعدّل الانتفاخ آخر ٣٠ يوم.
- أفضل ٣ وجبات راحة وأثقل ٣ وجبات (مع روابط لتفاصيلها).
- توزيع تأثير الوجبات على النوم.
- نسبة الإشارات في طبقك (آخر ٧ أيام / ٣٠ يوم).

### تبويب الدليل (جديد F3) — فهرس ذكي ٣×٣
- ٠١ فلسفة النظام (٣ بطاقات)
- ٠٢ القواعد الذهبية (٦ قواعد)
- ٠٣ خريطة الأكل (المناطق الثلاث بكل مجموعاتها)
- ٠٤ الممنوعات الصريحة
- ٠٥ طبق الطيبات (الصيغة الأساسية)
- ٠٦ برنامج ١٥ يوم (تفاعلي — انظر أدناه)
- ٠٧ بنك الوجبات (تفاعلي — انظر أدناه)
- ٠٨ التحضير الأسبوعي (٦ مهام)
- ٠٩ الأخطاء الشائعة (٦ أخطاء وتصحيحها)

### بنك الوجبات (جديد F3)
- ٤ بنوك (فطار / غداء / عشاء / سناك) كل عنصر بـ:
  نقطة منطقة، اسم، تركيب، وملاحظة. اضغط أي عنصر → ورقة تفاصيل +
  زر "صوّر هذه الوجبة" يدخلك مباشرةً لتدفّق التحليل.

### برنامج ١٥ يوم (جديد F3)
- مقدمة + معاينة المراحل الأربع، زر "ابدأ البرنامج اليوم".
- بعد البدء: حلقة تقدّم (X/١٥)، ٤ شارات مراحل، شريط أيام أفقي
  (مكتمل/الحالي/قادم)، بطاقة اليوم بفوكسه + وجبة مقترحة + نصيحة.
- زر "صوّر وجبة اليوم" يظهر فقط في اليوم الحالي.
- "أوقف البرنامج" / "ابدأ من جديد" حسب الحالة. التقدّم يومي تلقائي
  (يُحفظ تاريخ البدء في `SharedPreferences`).

### "عندما تحتار" — FAB (جديد F3)
- زر عائم 🤔 في زاوية شاشة اليوم → ورقة بـ ٤ بطاقات ملخّص ذهبية
  (اختر / امنع / اعتدل / راقب) + ٣ إجراءات: افتح بنك الوجبات، اقرأ
  القواعد الذهبية، صوّر ما أمامك.

### الإعدادات
- البريد، **تسجيل الخروج**، **حذف الحساب** (يستدعي دالة Supabase
  `delete-account` ثم يمسح البيانات المحلية).

### الاقتراحات الذكية (جديد F4 — منقول من فرع Android)
- زر **"اقتراحات ذكية"** على شاشة اليوم → شاشة بتبويبين:
  - **اقتراح وجبة**: يطلب من Gemini وجبة طيبة الآن (اسم + مكونات + سبب + الوقت المناسب).
  - **خطة الأسبوع**: ٧ أيام كاملة (سبت → جمعة) بفطور وغداء وعشاء لكل يوم.
- يمرّان عبر دالة Supabase نفسها (`task: "suggest"` و `task: "plan"`) — مع نفس
  مفتاح Gemini والقواعد المضمّنة.
- لا يخضعان للحدّ اليومي (محصور على تحليل الصور)، وفيهما تذكير أمان يمنع أي ادعاءات صحية.

## ما هو **ليس** هنا بعد

| المرحلة | الميزة |
|---|---|
| **مستقبلاً** | إشعارات متابعة الجسم/البرنامج، ميزة الصيام، السجل اليومي بالتقويم |

## الإعداد لأول مرة

تحتاج Flutter ≥ 3.24 مثبت (تحقّق بـ `flutter --version`).

```bash
cd ~/anthropic-claude-/flutter_app

# مرة واحدة: يولّد مجلدات android/ و ios/ بدون أن يلمس lib/ ولا pubspec.yaml
flutter create --org ai.tayyibat --platforms=ios,android .

# يحمّل الاعتمادات (يتضمّن الآن sqflite + path_provider + uuid + shared_preferences)
flutter pub get
```

### إضافات يدوية مطلوبة بعد `flutter create`

**iOS — في `ios/Runner/Info.plist` داخل أعلى `<dict>`:**
```xml
<key>NSCameraUsageDescription</key>
<string>نستخدم الكاميرا لتصوير وجباتك وتحليل مدى توافقها مع نظام الطيبات.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>نطلب الوصول إلى صورك لاختيار صورة وجبة وتحليلها.</string>

<!-- مخطّط tayyibat:// لرابط عودة OAuth (Google) -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>ai.tayyibat.oauth</string>
    <key>CFBundleURLSchemes</key>
    <array><string>tayyibat</string></array>
  </dict>
</array>
```

**Android — في `android/app/src/main/AndroidManifest.xml`:**
```xml
<!-- داخل <manifest> -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />

<!-- داخل <activity android:name=".MainActivity"> -->
<intent-filter android:autoVerify="false">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="tayyibat" android:host="login-callback" />
</intent-filter>
```

**iOS — تعطيل SceneDelegate (مهم لرابط Google العائد):**

نسخ Flutter الحديثة تُنشئ `ios/Runner/SceneDelegate.swift` ومفتاح
`UIApplicationSceneManifest` في `Info.plist`. مع هذا الإطار يبتلع المشهد
روابط النظام ولا يمرّرها للـ AppDelegate، فلا يصل
`tayyibat://login-callback?code=…` إلى ملحق `app_links`، ولا يعود
المستخدم تلقائياً للتطبيق بعد تسجيل دخول Google. الحل تعطيل المشهد:

```bash
cd ~/anthropic-claude-/flutter_app/ios/Runner
/usr/libexec/PlistBuddy -c "Delete :UIApplicationSceneManifest" Info.plist
rm -f SceneDelegate.swift
```

ثم في Xcode افتح `Runner.xcworkspace`، وفي شريط المشروع الأيسر اضغط بزر اليمين
على `SceneDelegate.swift` (لو ظهر بلون أحمر) → Delete → Remove Reference.
لاحقاً نظّف وأعد البناء:

```bash
cd ~/anthropic-claude-/flutter_app
flutter clean && flutter pub get
cd ios && pod install && cd ..
flutter run
```

بعدها يتولّى `AppDelegate` فتح روابط النظام، ويعمل تسجيل Google كما هو متوقّع.

**Sign in with Apple (بعد عضوية Apple Developer فقط):**
1. في Xcode: target → Signing & Capabilities → + Capability → Sign in with Apple.
2. في Supabase → Authentication → Providers → Apple → فعّل، وأضف معرّف الحزمة
   (مثلاً `ai.tayyibat.tayyibat`) في حقل Client IDs.
3. في `lib/config.dart` بدّل `appleSignInEnabled` إلى `true`.

## التشغيل

```bash
flutter pub get          # عند الترقية لـ F3 لأننا أضفنا shared_preferences
flutter run -d "iPhone 16 Pro"
# أو
flutter run -d emulator-5554
```

## بنية المشروع (F3)

```
flutter_app/lib/
├── main.dart                     # Supabase + MultiProvider
├── app.dart                      # auth-gated AppRoot
├── shell/main_shell.dart         # ٤ تبويبات
├── theme/theme.dart
├── data/
│   ├── database.dart             # SQLite + المخطّط
│   ├── meal_repository.dart      # حفظ/قراءة/حذف
│   ├── guide_data.dart           # كل بيانات الدليل ساكنة (نسخة 2)
│   ├── meal_banks_data.dart      # ٤ بنوك بعناصرها
│   └── program_data.dart         # ١٥ يوم + ٤ مراحل + ProgramStatus
├── models/
│   ├── analysis_result.dart      # AnalysisResult + FoodItem + FoodZone
│   ├── meal.dart
│   └── body_response.dart
├── services/
│   ├── auth_service.dart
│   ├── analyze_service.dart
│   └── account_service.dart
├── widgets/
│   ├── card_container.dart
│   ├── primary_button.dart
│   └── zone_badge.dart
└── features/
    ├── auth/auth_screen.dart
    ├── today/
    │   ├── today_screen.dart            # حلقة + شريط + 🤔 FAB
    │   └── when_in_doubt_screen.dart
    ├── capture/
    │   ├── capture_screen.dart
    │   └── result_screen.dart           # غلاف رفيع
    ├── history/
    │   ├── history_screen.dart          # قائمة + Body Intelligence
    │   ├── meal_detail_screen.dart
    │   └── body_intelligence_section.dart
    ├── body_response/
    │   ├── body_response_flow.dart
    │   └── body_response_card.dart
    ├── guide/
    │   ├── guide_screen.dart            # الفهرس ٣×٣
    │   ├── guide_philosophy.dart        # ٠١
    │   ├── guide_golden_rules.dart      # ٠٢
    │   ├── guide_eating_map.dart        # ٠٣
    │   ├── guide_forbidden.dart         # ٠٤
    │   ├── guide_plate.dart             # ٠٥
    │   ├── guide_program_wrapper.dart   # ٠٦ → ProgramScreen
    │   ├── guide_meal_banks_wrapper.dart# ٠٧ → MealBanksScreen
    │   ├── guide_weekly_prep.dart       # ٠٨
    │   └── guide_mistakes.dart          # ٠٩
    ├── meal_banks/meal_banks_screen.dart
    ├── program/program_screen.dart
    └── settings/settings_screen.dart
```
