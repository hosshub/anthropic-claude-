# الطيبات — نسخة Android (Tayyibat for Android)

منفذ أصلي (Native) لتطبيق **الطيبات** على أندرويد، مبني بـ **Kotlin + Jetpack Compose**،
ومطابق وظيفياً لنسخة iOS (SwiftUI). التطبيق **بالعربية أولاً مع RTL كامل**: تحليل
الوجبات بالصورة عبر Google Gemini API، متابعة يومية, تتبّع صيام، دليل للنظام، سجل ورسوم
بيانية، ونظام إشعارات محلية كامل (تذكيرات + نصائح متناوبة).

> ⚠️ **تنبيه طبي:** هذا التطبيق أداة لتتبع نظام غذائي اختاره المستخدم بمحض إرادته.
> لا يقدّم استشارة طبية ولا يدّعي علاج أي مرض. استشر طبيبك أو أخصائي تغذية قبل
> اتباع أي نظام غذائي.

---

## المتطلبات
- **Android Studio** (Koala أو أحدث) أو Android SDK من سطر الأوامر.
- **JDK 17**.
- **Android SDK 34** (compileSdk) و**minSdk 26** (أندرويد 8.0).
- مفتاح **Google Gemini API** (من https://aistudio.google.com/apikey، يُدخل داخل
  التطبيق ويُخزَّن مشفّراً)، أو الاعتماد على وسيط (proxy) كما هو مضبوط في `AppConfig`
  (يحتفظ الوسيط بمفتاح Gemini على خادم Supabase).

## الفتح والتشغيل
```bash
# من جذر مجلد android/
# أنشئ local.properties يحوي مسار SDK، أو افتح المشروع في Android Studio ليُنشئه تلقائياً:
echo "sdk.dir=/path/to/Android/sdk" > local.properties

./gradlew assembleDebug      # بناء حزمة التصحيح
./gradlew installDebug       # التثبيت على جهاز/محاكي متصل
./gradlew test               # اختبارات الوحدة (JVM)
```
في Android Studio: افتح مجلد `android/`، انتظر مزامنة Gradle، ثم Run على جهاز/محاكي
بأندرويد 8.0+.

## البنية
```
app/src/main/java/com/tayyibat/app/
  config/          AppConfig (الوسيط + مفاتيح Supabase)
  data/model/      كيانات Room + التعدادات + AnalysisResult (DTO)
  data/db/         AppDatabase · DAOs · Converters
  data/SecureStore تخزين مشفّر لمفتاح API وجلسة المصادقة (بديل Keychain)
  service/         Gemini API · المصادقة · الإشعارات · النصائح · القواعد · الصيام · النقاط · التصدير
  ui/theme/        الألوان والثيم (RTL + الوضع الليلي) والخطوط
  ui/components/   مكوّنات مشتركة (الأزرار، حلقة النتيجة، الشارات، البطاقات)
  ui/navigation/   AppNavHost + شريط التبويب السفلي
  ui/{today,capture,result,history,guide,settings,onboarding,auth}/  الشاشات
  res/raw/         tayyibat_rules.json · tips_bank.json (قابلة للتعديل)
```

## مقابلات التقنيات (iOS ← Android)
| iOS (SwiftUI) | Android |
| --- | --- |
| SwiftData | Room |
| Keychain | EncryptedSharedPreferences |
| UserNotifications | AlarmManager + BroadcastReceiver |
| AVFoundation/PhotosUI | CameraX + Photo Picker |
| Swift Charts | رسوم Canvas مخصّصة في Compose |
| `Calendar(.islamicUmmAlQura)` | `java.time` + `HijrahChronology` |
| `environment(\.layoutDirection, .rightToLeft)` | `LayoutDirection.Rtl` عبر `TayyibatTheme` |

## ملاحظات
- **الكاميرا والإشعارات** تتطلب اختباراً على جهاز حقيقي.
- مفتاح API يُخزَّن مشفّراً على الجهاز فقط؛ للنشر يُفضَّل وضع الوسيط (proxy).
- ملفا `tayyibat_rules.json` و`tips_bank.json` قابلان للتعديل دون تغيير المنطق.
