# الطيبات — نسخة Flutter (Phase F2)

نسخة Flutter من تطبيق الطيبات تعمل على **iOS و Android** من قاعدة كود واحدة،
باستخدام نفس الواجهة الخلفية (Supabase + Gemini Edge Function) المستخدمة في نسخة SwiftUI.

## ما هو موجود حتى F2

### تفاصيل المصادقة وتجربة المستخدم
- ثيم الطيبات (RTL عربي + ألوان النظام + نظام تصميم أساسي).
- تسجيل دخول / تسجيل بالبريد عبر Supabase.
- شريط تبويب سفلي بـ ٣ تبويبات: **اليوم**، **السجل**، **الإعدادات**.

### تدفّق التحليل
- تصوير وجبة (كاميرا أو معرض) → الوسيط على Supabase → تحليل Gemini.
- **حفظ محلي تلقائي** للوجبة في SQLite (`sqflite`) بعد التحليل، مع كتابة الصورة على القرص.
- شاشة تفاصيل الوجبة بإشارات الألوان (أخضر/أصفر/أحمر) + تنبيه الأصفر.

### السجل
- قائمة كل الوجبات مرتّبة حسب التاريخ، مع صور مصغّرة، تسميات نسبية ("اليوم"، "أمس")،
  وشارة النتيجة بلون نطاقها.
- شاشة اليوم تعرض شريطاً أفقياً بصور وجبات اليوم وحلقة متوسط الالتزام محسوبة محلياً.

### متابعة الجسم بعد الوجبة (الميزة الموقّعة)
- تدفّق صفحات بـ ٥ أسئلة: الشبع، الانتفاخ، الطاقة، النوم، التكرار.
- يظهر كزر **"سجّل كيف شعرت بعد هذه الوجبة"** على تفاصيل الوجبة، وتظهر بطاقة موجزة
  عند وجود متابعة (مع زر تعديل لإعادة فتح التدفّق).
- يُحفظ في جدول `body_responses` بعلاقة ١-١ مع الوجبة.

### الإعدادات وحذف الحساب
- بريد المستخدم، **تسجيل الخروج**، و**حذف الحساب** (يستدعي دالة `delete-account` على
  Supabase، ثم يمسح كل البيانات المحلية).

## ما هو **ليس** هنا بعد

| المرحلة | الميزة |
|---|---|
| **F2.5** | تسجيل الدخول عبر Google و Apple (يحتاج روابط نظام) |
| **F3** | تبويب الدليل بفهرس ٣×٣، بنك الوجبات، FAB "عندما تحتار"، برنامج ١٥ يوم، إحصائيات Body Intelligence |
| **F4** | الاقتراحات الذكية والخطة الأسبوعية بـ Gemini (نُقل من فرع Android) |

## الإعداد لأول مرة

تحتاج Flutter ≥ 3.24 مثبت (تحقّق بـ `flutter --version`).

```bash
cd ~/anthropic-claude-/flutter_app

# مرة واحدة: يولّد مجلدات android/ و ios/ بدون أن يلمس lib/ ولا pubspec.yaml
flutter create --org ai.tayyibat --platforms=ios,android .

# يحمّل الاعتمادات (يتضمّن الآن sqflite, path_provider, uuid)
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

**Android — في `android/app/src/main/AndroidManifest.xml` داخل `<manifest>` قبل `<application>`:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
```

## التشغيل

```bash
# iOS Simulator
flutter run -d "iPhone 16 Pro"

# Android Emulator
flutter run -d emulator-5554

# لائحة الأجهزة المتاحة
flutter devices
```

عند الترقية من F1 إلى F2 لا تنسَ `flutter pub get` — أضفنا اعتمادات `sqflite` و
`path_provider` و `path` و `uuid`.

## بنية المشروع (F2)

```
flutter_app/lib/
├── main.dart                 # Supabase + MultiProvider
├── app.dart                  # auth-gated AppRoot
├── shell/main_shell.dart     # شريط التبويب السفلي
├── theme/theme.dart          # ألوان + ثيم Material 3
├── data/
│   ├── database.dart         # افتتاح SQLite + المخطّط
│   └── meal_repository.dart  # ChangeNotifier — حفظ/قراءة/حذف
├── models/
│   ├── analysis_result.dart  # AnalysisResult + FoodItem + FoodZone
│   ├── meal.dart             # وجبة محفوظة (مع imagePath + bodyResponse)
│   └── body_response.dart    # BodyResponse + SleepImpact + WorthRepeating
├── services/
│   ├── auth_service.dart     # ChangeNotifier فوق supabase_flutter
│   ├── analyze_service.dart  # POST للوسيط (image_base64 + Authorization)
│   └── account_service.dart  # حذف الحساب → مسح محلي
├── widgets/
│   ├── card_container.dart
│   ├── primary_button.dart
│   └── zone_badge.dart
└── features/
    ├── auth/auth_screen.dart
    ├── today/today_screen.dart       # حلقة المتوسط + شريط وجبات اليوم
    ├── capture/
    │   ├── capture_screen.dart       # ImagePicker → analyze → save → push
    │   └── result_screen.dart        # غلاف رفيع حول MealDetailScreen
    ├── history/
    │   ├── history_screen.dart       # قائمة كل الوجبات
    │   └── meal_detail_screen.dart   # تفاصيل + متابعة الجسم + حذف
    ├── body_response/
    │   ├── body_response_flow.dart   # تدفّق ٥ أسئلة
    │   └── body_response_card.dart   # بطاقة الملخّص
    └── settings/settings_screen.dart # خروج + حذف الحساب
```
