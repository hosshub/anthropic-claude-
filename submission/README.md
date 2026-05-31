# دليل رفع تطبيق "الطيبات" — App Store & Play Store

كل ما تحتاجه لرفع التطبيق إلى متجري Apple و Google موجود في هذا المجلد.
ملفات النصوص (الوصف، الكلمات المفتاحية، الكلمة الإعلانية، ملاحظات الإصدار)
جاهزة بالعربية والإنجليزية. الصور والفيديو تحتاج التقاطها من الجهاز.

## ترتيب العمل المقترح

نوصي بإرسال **Google Play أولاً** (لا يتطلّب حساباً سنوياً، اعتماده $25 مرة واحدة،
ومراجعته أسرع — يومان عادةً). بعد قبولك في Apple Developer Program ($99/سنة)
انتقل لـ App Store.

| الخطوة | المسار | الوقت المتوقع |
|---|---|---|
| ١. تحضير سياسة الخصوصية الحيّة على tayyibat.ai/privacy.html | (تم — تأكد فقط أن الصفحة تحدّثت بنسخة `web/privacy.html` الجديدة) | ٥ دقائق |
| ٢. التقاط الصور المطلوبة من iPhone و Pixel | راجع `screenshots/README.md` | ٣٠ دقيقة |
| ٣. إنشاء حساب Google Play Console + رفع APK داخلي | راجع `play-store/checklist.md` | ساعة |
| ٤. ملء قسم "Data safety" + التصنيف | راجع `play-store/data-safety.md` | ٢٠ دقيقة |
| ٥. نشر داخلي للأصدقاء (Internal Testing) | راجع `play-store/internal-testing.md` | ١٠ دقائق |
| ٦. اعتماد Apple Developer (لو لم يكتمل بعد) | https://developer.apple.com/programs/enroll/ | ٢-٣ أيام |
| ٧. تفعيل Sign in with Apple (إلزامي قبل المتجر) | راجع `app-store/apple-signin-setup.md` | ٢٠ دقيقة |
| ٨. رفع نسخة TestFlight | راجع `app-store/checklist.md` | ساعتان |
| ٩. ملء App Store Connect (الوصف، الصور، الخصوصية) | راجع `app-store/listing-ar.md` و `listing-en.md` | ٤٥ دقيقة |
| ١٠. إرسال للمراجعة | App Store Connect → Submit for Review | يومان مراجعة |

## ملفات هذا المجلد

```
submission/
├── README.md                  # هذا الملف
├── play-store/
│   ├── checklist.md          # خطوات Play Console كاملة
│   ├── listing-ar.md         # الاسم/الوصف/الكلمات بالعربية
│   ├── listing-en.md         # English
│   ├── data-safety.md        # إجابات قسم Data Safety
│   ├── internal-testing.md   # مسار النشر الداخلي للأصدقاء
│   └── release-notes.md      # ملاحظات إصدار 1.0.0
├── app-store/
│   ├── checklist.md          # خطوات App Store Connect كاملة
│   ├── listing-ar.md         # الاسم/الوصف/الكلمات بالعربية
│   ├── listing-en.md         # English
│   ├── privacy-labels.md     # خريطة Apple Privacy Nutrition Labels
│   ├── apple-signin-setup.md # تفعيل Sign in with Apple
│   ├── review-notes.md       # ملاحظات لمراجع Apple + حساب تجريبي
│   └── release-notes.md      # What's New بالعربية والإنجليزية
└── screenshots/
    └── README.md             # المقاسات المطلوبة لكل متجر
```

## نقاط مهمّة لا تنسها

- **Apple Sign in:** متجر Apple يرفض تطبيقاً يقدّم تسجيل Google ولا يقدّم Apple.
  لذا قبل الإرسال لـ App Store **يجب** تفعيل `appleSignInEnabled = true` في
  `lib/config.dart` بعد إعداده على Supabase. تفاصيل في `app-store/apple-signin-setup.md`.
- **عمر المستخدم:** التطبيق ١٧+ على iOS (لا يقدّم نصائح طبية ولا محتوى حساس،
  لكن الالتزام الغذائي يحتاج إدراك بالغ). على Google Play: Everyone، مع تحذير
  طبي عام في الوصف.
- **سياسة الخصوصية:** كلا المتجرين يطلبان رابطاً علنياً. عنوانه:
  https://tayyibat.ai/privacy.html
- **التواصل:** بريد الدعم app@tayyibat.ai (مذكور في الخصوصية ومُستخدَم لطلبات
  حذف الحساب الخارجية، رغم أن الحذف من داخل التطبيق يعمل).
