# الطيبات — نسخة Flutter (Phase F1)

نسخة Flutter من تطبيق الطيبات تعمل على **iOS و Android** من قاعدة كود واحدة، باستخدام
نفس الواجهة الخلفية (Supabase + Gemini Edge Function) المستخدمة في نسخة SwiftUI.

> **F1 = شريحة عمودية فقط.** الهدف من هذه المرحلة هو التحقق من جودة الانتقال ومن
> أن الـ stack يعمل من البداية للنهاية. بقية الميزات تأتي في مراحل لاحقة.

## ما هو موجود في F1
- ✅ ثيم الطيبات (RTL عربي + ألوان النظام + نظام تصميم أساسي)
- ✅ التسجيل وتسجيل الدخول بالبريد الإلكتروني عبر Supabase
- ✅ تصوير وجبة (كاميرا أو معرض) → الوسيط على Supabase → تحليل Gemini
- ✅ شاشة النتيجة مع نقاط الإشارات (أخضر/أصفر/أحمر) + تنبيه الأصفر

## ما هو **ليس** هنا بعد (مراحل لاحقة)
- ❌ الحفظ المحلي والسجل (Phase F2)
- ❌ متابعة الجسم بعد الوجبة (Phase F2)
- ❌ تبويب الدليل بفهرس ٣×٣ (Phase F3)
- ❌ بنك الوجبات و FAB "عندما تحتار" (Phase F3)
- ❌ برنامج ١٥ يوم (Phase F3)
- ❌ إحصائيات Body Intelligence (Phase F3)
- ❌ تسجيل الدخول عبر Google و Apple (Phase F2 — يحتاج روابط نظام)
- ❌ حذف الحساب والإعدادات (Phase F2)
- ❌ الاقتراحات الذكية + الخطة الأسبوعية بـ Gemini (Phase F4 — من فرع Android)

## الإعداد لأول مرة

تحتاج Flutter ≥ 3.24 مثبت (تحقّق بـ `flutter --version`).

```bash
cd ~/anthropic-claude-/flutter_app

# يولّد مجلدات android/ و ios/ (يحترم lib/ و pubspec.yaml الموجودَين هنا)
flutter create --org ai.tayyibat --platforms=ios,android .

# يحمّل الاعتمادات
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
# iOS Simulator (يفترض Xcode مثبت)
flutter run -d "iPhone 16 Pro"

# Android Emulator
flutter run -d emulator-5554

# لائحة الأجهزة المتاحة
flutter devices
```

أول إقلاع يأخذ بضع دقائق لتنزيل أدوات المنصة.

## نقاط الاتصال (ثوابت Supabase + الوسيط)

موجودة كثوابت في الكود — يمكن نقلها لاحقاً إلى `--dart-define` أو ملف بيئة:

| الموقع | ما يحويه |
|---|---|
| `lib/main.dart` | عنوان Supabase + المفتاح العام (anon) — نفس قيم SwiftUI |
| `lib/services/analyze_service.dart` | عنوان دالة التحليل (`functions/v1/analyze`) |
| `lib/theme/theme.dart` | ألوان النظام والإشارات الثلاث |

## بنية المشروع (F1)

```
flutter_app/
├── pubspec.yaml
├── analysis_options.yaml
└── lib/
    ├── main.dart           # تهيئة Supabase + إقلاع التطبيق
    ├── app.dart            # بوّابة المصادقة (auth-gated)
    ├── theme/theme.dart    # ألوان وثيم النظام
    ├── models/
    │   └── analysis_result.dart   # FoodZone + FoodItem + AnalysisResult
    ├── services/
    │   ├── auth_service.dart      # ChangeNotifier فوق supabase_flutter
    │   └── analyze_service.dart   # POST للوسيط + تحويل JSON
    ├── widgets/
    │   ├── card_container.dart
    │   ├── primary_button.dart
    │   └── zone_badge.dart        # النقطة الملوّنة + اسم المنطقة
    └── features/
        ├── auth/auth_screen.dart
        ├── today/today_screen.dart
        └── capture/
            ├── capture_screen.dart   # ImagePicker → analyze
            └── result_screen.dart    # عرض النتيجة بالإشارات
```
