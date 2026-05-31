# الطيبات — نسخة Flutter (Phase F4)

نسخة Flutter من تطبيق الطيبات تعمل على **iOS و Android** من قاعدة كود واحدة،
باستخدام نفس الواجهة الخلفية (Supabase + Gemini Edge Function) المستخدمة في نسخة SwiftUI.

## ما هو موجود حتى F4 (تكافؤ مع SwiftUI v2 + ميزات Android)

### الأساس
- ثيم الطيبات بعربية RTL وألوان النظام، **شريط تبويب سفلي بأربع تبويبات**:
  **اليوم / السجل / الدليل / الإعدادات**.
- تسجيل دخول وتسجيل بالبريد عبر Supabase.

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
| **F2.5** | تسجيل الدخول عبر Google و Apple (يحتاج روابط نظام) |
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
```

**Android — في `android/app/src/main/AndroidManifest.xml` داخل `<manifest>`:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
```

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
