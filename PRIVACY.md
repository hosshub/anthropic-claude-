# سياسة الخصوصية — تطبيق الطيبات
*آخر تحديث: 2026-05-29*

نحن نحترم خصوصيتك. تشرح هذه الصفحة البيانات التي يتعامل معها تطبيق **الطيبات**.

## البيانات التي نتعامل معها
- **الحساب وتسجيل الدخول:** عند إنشاء حساب أو تسجيل الدخول عبر **Google** أو
  **Apple** أو البريد الإلكتروني، نستخدم خدمة **Supabase** للمصادقة. نخزّن معرّف
  حسابك وبريدك الإلكتروني لتسجيل دخولك ولتطبيق حدّ الاستخدام اليومي. لا نطّلع على
  كلمة مرورك (تُدار عبر مزوّد الدخول أو Supabase).
- **صور الوجبات:** عند طلبك تحليل وجبة، تُرسَل صورتها إلى خادمنا الوسيط (المُستضاف
  على **Supabase**) ومنه إلى خدمة **Google (Gemini)** لإجراء التحليل، ثم تعود
  النتيجة إليك. لا نحتفظ بالصور على خوادمنا بعد إتمام التحليل.
- **بياناتك على الجهاز:** الاسم، والعمر (اختياري)، والوجبات ونتائجها وصورها،
  والملخصات اليومية، وأيام الصيام — **تُخزَّن محلياً على جهازك فقط** (SwiftData)
  ولا تُرفع إلى خوادمنا.
- **بيانات الاستخدام:** نحتفظ بعدّاد بسيط على خادمنا (معرّف الحساب + التاريخ + عدد
  التحليلات) لغرض واحد هو تطبيق الحدّ اليومي. لا يتضمّن صورك ولا تفاصيل وجباتك.

## ما لا نفعله
- لا نبيع بياناتك ولا نشاركها مع مُعلنين.
- لا نستخدم أدوات تتبّع أو تحليلات لجهات خارجية.
- الإشعارات كلها **محلية** على جهازك؛ لا نرسل إشعارات من خوادمنا.

## مزوّدو الخدمة (الطرف الثالث)
نعتمد على **Supabase** (استضافة الخادم والمصادقة) و**Google** (تحليل صور الوجبات
عبر Gemini). تُعالَج الصور لدى Google ولا تُستخدم لتدريب نماذجها وفق شروط واجهة
Gemini للمطوّرين. راجع سياستَي خصوصية Supabase وGoogle لمزيد من التفاصيل.

## حذف بياناتك
يمكنك حذف كل بيانات المتابعة المحلية من **الإعدادات → حذف كل بيانات المتابعة**،
وحذف التطبيق يزيل جميع البيانات المخزّنة محلياً. لحذف حسابك وبياناته من خادمنا،
راسلنا على **app@tayyibat.ai** وسننفّذ الطلب.

## تنبيه طبي
التطبيق أداة لتتبّع نظام غذائي اختاره المستخدم، ولا يقدّم استشارة طبية ولا يدّعي
علاج أي مرض. غير مخصّص لمن هم دون 18 عاماً.

## التواصل
لأي استفسار حول الخصوصية: **app@tayyibat.ai**

---

# Privacy Policy — Tayyibat
*Last updated: 2026-05-29*

We respect your privacy. This page explains how the **Tayyibat** app handles data.

## Data we handle
- **Account & sign-in:** when you create an account or sign in with **Google**,
  **Apple**, or email, we use **Supabase** for authentication. We store your
  account identifier and email to sign you in and to enforce the daily usage
  limit. We never see your password (handled by the sign-in provider or Supabase).
- **Meal photos:** when you request an analysis, the photo is sent to our backend
  proxy (hosted on **Supabase**) and on to **Google (Gemini)** for processing,
  and the result is returned to you. We do not retain photos after processing.
- **On-device data:** your name, optional age, meals and their results/images,
  daily summaries, and fasting days are **stored only on your device**
  (SwiftData) and are not uploaded to our servers.
- **Usage data:** we keep a small server-side counter (account id + date +
  number of analyses) for the sole purpose of enforcing the daily limit. It
  contains no photos or meal details.

## What we don’t do
- We don’t sell your data or share it with advertisers.
- We use no third-party trackers or analytics.
- All notifications are **local** to your device.

## Service providers (third parties)
We rely on **Supabase** (backend hosting & authentication) and **Google**
(meal-image analysis via Gemini). Photos sent for analysis are processed by
Google and, under the Gemini developer API terms, are not used to train its
models. See the Supabase and Google privacy policies for details.

## Deleting your data
Delete all local tracking data via **Settings → Delete all tracking data**;
deleting the app removes all locally stored data. To delete your account and its
server-side data, email **app@tayyibat.ai** and we will action it.

## Medical disclaimer
The app is a tracking tool for a user-chosen diet. It does not provide medical
advice or claim to treat any condition, and is not intended for users under 18.

## Contact
Privacy questions: **app@tayyibat.ai**
