# الطيبات (Tayyibat)

تطبيق iOS أصلي (SwiftUI) لتتبع الالتزام بنظام "الطيبات" الغذائي، ميزته الأساسية
تحليل الوجبات بالصورة عبر Claude API، مع متابعة يومية، تتبّع صيام، دليل للنظام،
سجل ورسوم بيانية، ونظام إشعارات محلية كامل (تذكيرات + نصائح متناوبة). التطبيق
**بالعربية أولاً مع RTL كامل**.

> ⚠️ **تنبيه طبي:** هذا التطبيق أداة لتتبع نظام غذائي اختاره المستخدم بمحض إرادته.
> لا يقدّم استشارة طبية ولا يدّعي علاج أي مرض. استشر طبيبك أو أخصائي تغذية قبل
> اتباع أي نظام غذائي.

---

## المتطلبات
- macOS مع **Xcode 16+**
- iOS 17 كحد أدنى
- مفتاح **Anthropic Claude API** (يُدخل داخل التطبيق ويُخزَّن في Keychain)

## فتح المشروع
في هذا المستودع طريقتان (المستخدم اختار توفيرهما معاً):

### 1) عبر XcodeGen (المصدر الأساسي — موصى به)
```bash
brew install xcodegen
xcodegen generate
open Tayyibat.xcodeproj
```
`project.yml` هو المصدر الموثوق لإعدادات المشروع. أعد توليد المشروع بهذا الأمر
كلما تغيّرت الإعدادات أو ظهرت مشكلة في ملف `.xcodeproj` المرفق.

### 2) فتح المشروع المرفق مباشرةً
```bash
open Tayyibat.xcodeproj
```
ملف `Tayyibat.xcodeproj` مرفق مسبقاً ويستخدم **مجموعات المزامنة مع نظام الملفات**
(`PBXFileSystemSynchronizedRootGroup` في Xcode 16) فلا يلزم سرد كل ملف يدوياً —
يضيف Xcode الملفات تلقائياً من مجلد `Tayyibat/`. إن واجهت أي خلل، استخدم XcodeGen
أعلاه لإعادة التوليد.

## التشغيل
1. اختر هدف **Tayyibat** ومحاكي iOS 17+، ثم Build & Run.
2. مرّر شاشة التنبيه الطبي بالكامل ووافق (إلزامي عند أول تشغيل).
3. من **الإعدادات** أدخل مفتاح Claude API (يُخزَّن في Keychain).
4. من الرئيسية اضغط "📸 صور وجبتك" أو اختر صورة، وانتظر التحليل.

## الاختبارات
```bash
# داخل Xcode: Cmd+U
```
تغطي وحدات منطقية خالصة: حساب النقاط، تدوير النصائح بدون تكرار، حساب أيام الصيام
الهجرية، وفك ترميز JSON القادم من Claude.

## ملاحظات مهمة
- **الإشعارات والكاميرا تتطلب اختباراً على جهاز حقيقي** — جدولة الإشعارات في
  المحاكي غير موثوقة.
- مفتاح API يُخزَّن على الجهاز (Keychain). هذا مقبول للاستخدام الشخصي، لكنه غير
  مناسب للتوزيع عبر App Store دون وسيط (proxy) خلفي.
- ملفا `Tayyibat/Resources/tayyibat_rules.json` و`tips_bank.json` قابلان للتعديل
  دون إعادة بناء المنطق.

## البنية
```
project.yml                       # XcodeGen manifest (المصدر الموثوق)
Tayyibat.xcodeproj/               # مشروع مرفق (folder-synced)
Tayyibat/
  App/         نقطة الدخول، الجذر، ModelContainer، RTL/locale
  Models/      نماذج SwiftData + AnalysisResult (DTO)
  Services/    Claude API، Keychain، الإشعارات، النصائح، القواعد، الصيام، النقاط
  Features/    Onboarding · Today · Capture · Result · History · Guide · Settings
  Navigation/  MainTabView
  DesignSystem/ الألوان، الخطوط، المكوّنات
  Localization/ Localizable.xcstrings
  Resources/   tayyibat_rules.json · tips_bank.json · Assets.xcassets
TayyibatTests/ اختبارات وحدة
```
