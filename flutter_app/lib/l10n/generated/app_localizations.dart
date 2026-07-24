import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'الطيبات'**
  String get appTitle;

  /// No description provided for @common_ok.
  ///
  /// In ar, this message translates to:
  /// **'حسناً'**
  String get common_ok;

  /// No description provided for @common_cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In ar, this message translates to:
  /// **'احفظ'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get common_delete;

  /// No description provided for @common_close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get common_close;

  /// No description provided for @common_next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get common_next;

  /// No description provided for @common_previous.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get common_previous;

  /// No description provided for @common_yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get common_no;

  /// No description provided for @common_done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get common_done;

  /// No description provided for @common_later.
  ///
  /// In ar, this message translates to:
  /// **'لاحقاً'**
  String get common_later;

  /// No description provided for @common_skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطّي'**
  String get common_skip;

  /// No description provided for @common_retry.
  ///
  /// In ar, this message translates to:
  /// **'حاول مجدداً'**
  String get common_retry;

  /// No description provided for @common_or.
  ///
  /// In ar, this message translates to:
  /// **'أو'**
  String get common_or;

  /// No description provided for @tab_today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get tab_today;

  /// No description provided for @tab_history.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get tab_history;

  /// No description provided for @tab_guide.
  ///
  /// In ar, this message translates to:
  /// **'الدليل'**
  String get tab_guide;

  /// No description provided for @tab_settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get tab_settings;

  /// No description provided for @auth_signIn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get auth_signIn;

  /// No description provided for @auth_signUp.
  ///
  /// In ar, this message translates to:
  /// **'حساب جديد'**
  String get auth_signUp;

  /// No description provided for @auth_signInTagline.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول للمتابعة'**
  String get auth_signInTagline;

  /// No description provided for @auth_signUpTagline.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ حساباً للبدء'**
  String get auth_signUpTagline;

  /// No description provided for @auth_email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور (٦ أحرف فأكثر)'**
  String get auth_password;

  /// No description provided for @auth_createAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب'**
  String get auth_createAccount;

  /// No description provided for @auth_continueWithGoogle.
  ///
  /// In ar, this message translates to:
  /// **'متابعة بحساب Google'**
  String get auth_continueWithGoogle;

  /// No description provided for @auth_signInWithApple.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول عبر Apple'**
  String get auth_signInWithApple;

  /// No description provided for @auth_invalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'بريد غير صالح'**
  String get auth_invalidEmail;

  /// No description provided for @auth_passwordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور قصيرة جداً'**
  String get auth_passwordTooShort;

  /// No description provided for @auth_signUpEmailSent.
  ///
  /// In ar, this message translates to:
  /// **'أنشأنا حسابك. تحقّق من بريدك لتأكيد الحساب، ثم سجّل الدخول.'**
  String get auth_signUpEmailSent;

  /// No description provided for @auth_appleCredentialFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الحصول على بيانات Apple.'**
  String get auth_appleCredentialFailed;

  /// No description provided for @auth_appleSignInCancelled.
  ///
  /// In ar, this message translates to:
  /// **'أُلغي تسجيل الدخول.'**
  String get auth_appleSignInCancelled;

  /// No description provided for @analyze_dailyCapReached.
  ///
  /// In ar, this message translates to:
  /// **'بلغت الحد اليومي للتحليلات.'**
  String get analyze_dailyCapReached;

  /// No description provided for @analyze_failedWithCode.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر التحليل ({code}).'**
  String analyze_failedWithCode(String code);

  /// No description provided for @analyze_badResponse.
  ///
  /// In ar, this message translates to:
  /// **'استجابة غير متوقعة من الوسيط.'**
  String get analyze_badResponse;

  /// No description provided for @suggest_failedWithCode.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الطلب ({code}).'**
  String suggest_failedWithCode(String code);

  /// No description provided for @suggest_badResponse.
  ///
  /// In ar, this message translates to:
  /// **'استجابة غير متوقعة من الوسيط.'**
  String get suggest_badResponse;

  /// No description provided for @account_deleteNotDeployed.
  ///
  /// In ar, this message translates to:
  /// **'خدمة حذف الحساب غير منشورة على الخادم. أبلغ المطوّر.'**
  String get account_deleteNotDeployed;

  /// No description provided for @account_deleteFailedWithCode.
  ///
  /// In ar, this message translates to:
  /// **'فشل حذف الحساب (رمز {code}).'**
  String account_deleteFailedWithCode(String code);

  /// No description provided for @result_captureAnother.
  ///
  /// In ar, this message translates to:
  /// **'صوّر وجبة أخرى'**
  String get result_captureAnother;

  /// No description provided for @common_listSeparator.
  ///
  /// In ar, this message translates to:
  /// **'، '**
  String get common_listSeparator;

  /// No description provided for @common_percentValue.
  ///
  /// In ar, this message translates to:
  /// **'{value}٪'**
  String common_percentValue(int value);

  /// No description provided for @today_greetingWithName.
  ///
  /// In ar, this message translates to:
  /// **'{greeting}، {name}'**
  String today_greetingWithName(String greeting, String name);

  /// No description provided for @history_calendar_month.
  ///
  /// In ar, this message translates to:
  /// **'شهر'**
  String get history_calendar_month;

  /// No description provided for @disclaimer_welcome.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك في الطيبات'**
  String get disclaimer_welcome;

  /// No description provided for @disclaimer_intro.
  ///
  /// In ar, this message translates to:
  /// **'قبل البدء، اقرأ التنبيه التالي حتى النهاية.'**
  String get disclaimer_intro;

  /// No description provided for @disclaimer_screenTitle.
  ///
  /// In ar, this message translates to:
  /// **'التنبيه الطبي'**
  String get disclaimer_screenTitle;

  /// No description provided for @disclaimer_title.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه طبي مهم'**
  String get disclaimer_title;

  /// No description provided for @disclaimer_intro_body.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق \"الطيبات\" أداة معلوماتية تساعدك على متابعة وعيك الغذائي وفق مبادئ نظام طبيعي وقفت عليها بنفسك. لا يقدّم التطبيق استشارة طبية، ولا يصف علاجاً، ولا يشخّص مرضاً، ولا يحلّ محل الطبيب أو أخصائي التغذية.'**
  String get disclaimer_intro_body;

  /// No description provided for @disclaimer_section_what.
  ///
  /// In ar, this message translates to:
  /// **'ما هذا التطبيق؟'**
  String get disclaimer_section_what;

  /// No description provided for @disclaimer_section_what_body.
  ///
  /// In ar, this message translates to:
  /// **'أداة تذكير ومتابعة لأنماط أكلك، تعطيك إشارات (أخضر/أصفر/أحمر) وملخّصات لمساعدتك في الانتباه لما تأكل. الإشارات لأغراض المتابعة الذاتية فقط — لا تفسّرها على أنها حكم طبي.'**
  String get disclaimer_section_what_body;

  /// No description provided for @disclaimer_section_whatNot.
  ///
  /// In ar, this message translates to:
  /// **'ما هذا التطبيق ليس به؟'**
  String get disclaimer_section_whatNot;

  /// No description provided for @disclaimer_whatNot_1.
  ///
  /// In ar, this message translates to:
  /// **'لا يصف دواءً أو يطلب إيقاف أي دواء.'**
  String get disclaimer_whatNot_1;

  /// No description provided for @disclaimer_whatNot_2.
  ///
  /// In ar, this message translates to:
  /// **'لا يشخّص أمراضاً ولا يقترح علاجات.'**
  String get disclaimer_whatNot_2;

  /// No description provided for @disclaimer_whatNot_3.
  ///
  /// In ar, this message translates to:
  /// **'لا يقدّم نصيحة غذائية مخصّصة لحالتك الصحية.'**
  String get disclaimer_whatNot_3;

  /// No description provided for @disclaimer_whatNot_4.
  ///
  /// In ar, this message translates to:
  /// **'لا يحلّ محل زيارة الطبيب أو أخصائي التغذية.'**
  String get disclaimer_whatNot_4;

  /// No description provided for @disclaimer_section_whenDoctor.
  ///
  /// In ar, this message translates to:
  /// **'متى يجب استشارة طبيب؟'**
  String get disclaimer_section_whenDoctor;

  /// No description provided for @disclaimer_section_whenDoctor_body.
  ///
  /// In ar, this message translates to:
  /// **'إذا كان لديك حالة صحية مزمنة (سكري، ضغط، أمراض كلى، أمراض قلب، حساسية غذائية، اضطرابات هضمية)، أو إذا كنتِ حاملاً أو مرضعاً، أو إذا كنت تتناول أدوية، فعليك مراجعة طبيبك قبل تغيير نظامك الغذائي بناءً على ما يعرضه هذا التطبيق.'**
  String get disclaimer_section_whenDoctor_body;

  /// No description provided for @disclaimer_section_responsibility.
  ///
  /// In ar, this message translates to:
  /// **'مسؤوليتك الشخصية'**
  String get disclaimer_section_responsibility;

  /// No description provided for @disclaimer_section_responsibility_body.
  ///
  /// In ar, this message translates to:
  /// **'باستخدامك التطبيق، تقرّ بأنك:'**
  String get disclaimer_section_responsibility_body;

  /// No description provided for @disclaimer_responsibility_1.
  ///
  /// In ar, this message translates to:
  /// **'قرأت هذا التنبيه وفهمته.'**
  String get disclaimer_responsibility_1;

  /// No description provided for @disclaimer_responsibility_2.
  ///
  /// In ar, this message translates to:
  /// **'تتحمّل المسؤولية الكاملة عن قراراتك الغذائية.'**
  String get disclaimer_responsibility_2;

  /// No description provided for @disclaimer_responsibility_3.
  ///
  /// In ar, this message translates to:
  /// **'لن تستخدم التطبيق بديلاً عن الرعاية الطبية المتخصّصة.'**
  String get disclaimer_responsibility_3;

  /// No description provided for @disclaimer_responsibility_4.
  ///
  /// In ar, this message translates to:
  /// **'تعفي مطوّر التطبيق من أي ضرر مباشر أو غير مباشر ينجم عن القرارات الشخصية التي تتخذها بناءً على ما يعرضه التطبيق.'**
  String get disclaimer_responsibility_4;

  /// No description provided for @disclaimer_section_data.
  ///
  /// In ar, this message translates to:
  /// **'بيانات وجباتك'**
  String get disclaimer_section_data;

  /// No description provided for @disclaimer_section_data_body.
  ///
  /// In ar, this message translates to:
  /// **'تُحفظ صور وجباتك وملاحظاتك على جهازك بشكل أساسي. لا تُرسل بياناتك الصحية لأي طرف ثالث للتسويق. التحليل يمرّ بنموذج ذكاء اصطناعي (Gemini) عبر خادم وسيط لا يحتفظ بالصور.'**
  String get disclaimer_section_data_body;

  /// No description provided for @disclaimer_section_emergency.
  ///
  /// In ar, this message translates to:
  /// **'في حالة الطوارئ'**
  String get disclaimer_section_emergency;

  /// No description provided for @disclaimer_section_emergency_body.
  ///
  /// In ar, this message translates to:
  /// **'إذا واجهت أعراضاً صحية حادة، اتصل بخدمات الطوارئ فوراً. هذا التطبيق ليس مخصّصاً للاستخدام في الحالات الطارئة.'**
  String get disclaimer_section_emergency_body;

  /// No description provided for @disclaimer_readyHint.
  ///
  /// In ar, this message translates to:
  /// **'بقراءتك حتى هنا، أنت جاهز للموافقة. يمكنك دائماً إعادة قراءة هذا التنبيه من الإعدادات.'**
  String get disclaimer_readyHint;

  /// No description provided for @disclaimer_scrollPrompt.
  ///
  /// In ar, this message translates to:
  /// **'مرّر القراءة حتى نهاية النص لتفعيل زر الموافقة.'**
  String get disclaimer_scrollPrompt;

  /// No description provided for @disclaimer_action.
  ///
  /// In ar, this message translates to:
  /// **'أوافق وأتحمّل المسؤولية'**
  String get disclaimer_action;

  /// No description provided for @onboarding_welcome_title.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك في الطيبات'**
  String get onboarding_welcome_title;

  /// No description provided for @onboarding_welcome_body.
  ///
  /// In ar, this message translates to:
  /// **'رفيق هادئ للأكل الواعي — صوّر وجبتك واعرف موقعها من النظام.'**
  String get onboarding_welcome_body;

  /// No description provided for @onboarding_feature_capture_title.
  ///
  /// In ar, this message translates to:
  /// **'صوّر وجبتك'**
  String get onboarding_feature_capture_title;

  /// No description provided for @onboarding_feature_capture_body.
  ///
  /// In ar, this message translates to:
  /// **'يقرأ الذكاء الاصطناعي طبقك ويقيّمه وفق نظام الطيبات في ثوانٍ.'**
  String get onboarding_feature_capture_body;

  /// No description provided for @onboarding_feature_zones_title.
  ///
  /// In ar, this message translates to:
  /// **'ثلاث مناطق واضحة'**
  String get onboarding_feature_zones_title;

  /// No description provided for @onboarding_feature_zones_body.
  ///
  /// In ar, this message translates to:
  /// **'الأخضر أساسك، والأصفر بحساب، والأحمر يُتجنّب. بلا هوس بالسعرات.'**
  String get onboarding_feature_zones_body;

  /// No description provided for @onboarding_feature_listen_title.
  ///
  /// In ar, this message translates to:
  /// **'أنصت لجسدك'**
  String get onboarding_feature_listen_title;

  /// No description provided for @onboarding_feature_listen_body.
  ///
  /// In ar, this message translates to:
  /// **'سجّل شعورك بعد كل وجبة، وسيُظهر لك التطبيق ما يناسبك فعلاً.'**
  String get onboarding_feature_listen_body;

  /// No description provided for @onboarding_about_title.
  ///
  /// In ar, this message translates to:
  /// **'اجعله تطبيقك'**
  String get onboarding_about_title;

  /// No description provided for @onboarding_about_body.
  ///
  /// In ar, this message translates to:
  /// **'كلاهما اختياري ويبقى على جهازك — يُستخدمان لتخصيص التحية فقط.'**
  String get onboarding_about_body;

  /// No description provided for @onboarding_name_hint.
  ///
  /// In ar, this message translates to:
  /// **'اسمك'**
  String get onboarding_name_hint;

  /// No description provided for @onboarding_age_hint.
  ///
  /// In ar, this message translates to:
  /// **'عمرك'**
  String get onboarding_age_hint;

  /// No description provided for @onboarding_done_title.
  ///
  /// In ar, this message translates to:
  /// **'كل شيء جاهز'**
  String get onboarding_done_title;

  /// No description provided for @onboarding_done_body.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ من وجبتك القادمة — صوّرها وراقب الإشارة.'**
  String get onboarding_done_body;

  /// No description provided for @onboarding_start.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get onboarding_start;

  /// No description provided for @settings_name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get settings_name;

  /// No description provided for @settings_firstName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأول'**
  String get settings_firstName;

  /// No description provided for @settings_lastName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأخير'**
  String get settings_lastName;

  /// No description provided for @settings_nickname.
  ///
  /// In ar, this message translates to:
  /// **'اللقب'**
  String get settings_nickname;

  /// No description provided for @settings_name_dialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'اسمك'**
  String get settings_name_dialogTitle;

  /// No description provided for @onboarding_firstName_hint.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأول'**
  String get onboarding_firstName_hint;

  /// No description provided for @onboarding_lastName_hint.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأخير'**
  String get onboarding_lastName_hint;

  /// No description provided for @onboarding_nickname_hint.
  ///
  /// In ar, this message translates to:
  /// **'اللقب (اختياري)'**
  String get onboarding_nickname_hint;

  /// No description provided for @settings_displayName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم المعروض'**
  String get settings_displayName;

  /// No description provided for @settings_displayName_dialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الاسم المعروض'**
  String get settings_displayName_dialogTitle;

  /// No description provided for @settings_displayName_note.
  ///
  /// In ar, this message translates to:
  /// **'يظهر في تحية شاشة اليوم، ويبقى على جهازك.'**
  String get settings_displayName_note;

  /// No description provided for @settings_displayName_empty.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get settings_displayName_empty;

  /// No description provided for @foodBank_title.
  ///
  /// In ar, this message translates to:
  /// **'بنك الطعام'**
  String get foodBank_title;

  /// No description provided for @foodBank_searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن صنف أو مكوّن…'**
  String get foodBank_searchHint;

  /// No description provided for @foodBank_empty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أصناف تطابق بحثك.'**
  String get foodBank_empty;

  /// No description provided for @foodBank_cat_all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get foodBank_cat_all;

  /// No description provided for @foodBank_cat_breakfast.
  ///
  /// In ar, this message translates to:
  /// **'فطور'**
  String get foodBank_cat_breakfast;

  /// No description provided for @foodBank_cat_lunch.
  ///
  /// In ar, this message translates to:
  /// **'غداء'**
  String get foodBank_cat_lunch;

  /// No description provided for @foodBank_cat_dinner.
  ///
  /// In ar, this message translates to:
  /// **'عشاء'**
  String get foodBank_cat_dinner;

  /// No description provided for @foodBank_cat_street.
  ///
  /// In ar, this message translates to:
  /// **'أكل شارع'**
  String get foodBank_cat_street;

  /// No description provided for @foodBank_cat_drink.
  ///
  /// In ar, this message translates to:
  /// **'مشروبات'**
  String get foodBank_cat_drink;

  /// No description provided for @foodBank_cat_sweet.
  ///
  /// In ar, this message translates to:
  /// **'حلويات'**
  String get foodBank_cat_sweet;

  /// No description provided for @foodBank_log.
  ///
  /// In ar, this message translates to:
  /// **'سجّل هذه الوجبة'**
  String get foodBank_log;

  /// No description provided for @foodBank_logged.
  ///
  /// In ar, this message translates to:
  /// **'تم التسجيل في اليوم.'**
  String get foodBank_logged;

  /// No description provided for @foodBank_portions.
  ///
  /// In ar, this message translates to:
  /// **'عدد الحصص'**
  String get foodBank_portions;

  /// No description provided for @foodBank_approxNote.
  ///
  /// In ar, this message translates to:
  /// **'قيم تقريبية لحصة متوسطة.'**
  String get foodBank_approxNote;

  /// No description provided for @today_logFromBank.
  ///
  /// In ar, this message translates to:
  /// **'سجّل من بنك الطعام'**
  String get today_logFromBank;

  /// No description provided for @today_greetingMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get today_greetingMorning;

  /// No description provided for @today_greetingEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get today_greetingEvening;

  /// No description provided for @today_score.
  ///
  /// In ar, this message translates to:
  /// **'طيب اليوم'**
  String get today_score;

  /// No description provided for @today_noMealsYet.
  ///
  /// In ar, this message translates to:
  /// **'لم تسجّل وجبات اليوم بعد'**
  String get today_noMealsYet;

  /// No description provided for @today_averageToday.
  ///
  /// In ar, this message translates to:
  /// **'متوسط {avg}٪ اليوم'**
  String today_averageToday(int avg);

  /// No description provided for @today_log.
  ///
  /// In ar, this message translates to:
  /// **'سجل اليوم'**
  String get today_log;

  /// No description provided for @today_streakTitle.
  ///
  /// In ar, this message translates to:
  /// **'سلسلة التسجيل'**
  String get today_streakTitle;

  /// No description provided for @today_streakDays.
  ///
  /// In ar, this message translates to:
  /// **'{n, plural, =1{يوم واحد} =2{يومان} few{{n} أيام} many{{n} يوماً} other{{n} يوم}}'**
  String today_streakDays(num n);

  /// No description provided for @today_streakKeepAlive.
  ///
  /// In ar, this message translates to:
  /// **'سجّل وجبة اليوم لتحافظ على سلسلتك.'**
  String get today_streakKeepAlive;

  /// No description provided for @today_photoYourMeal.
  ///
  /// In ar, this message translates to:
  /// **'صوّر وجبتك'**
  String get today_photoYourMeal;

  /// No description provided for @today_suggestions.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات'**
  String get today_suggestions;

  /// No description provided for @today_fasting.
  ///
  /// In ar, this message translates to:
  /// **'صيام'**
  String get today_fasting;

  /// No description provided for @today_whenInDoubtTooltip.
  ///
  /// In ar, this message translates to:
  /// **'عندما تحتار'**
  String get today_whenInDoubtTooltip;

  /// No description provided for @whenInDoubt_title.
  ///
  /// In ar, this message translates to:
  /// **'عندما تحتار'**
  String get whenInDoubt_title;

  /// No description provided for @whenInDoubt_choose.
  ///
  /// In ar, this message translates to:
  /// **'اختر'**
  String get whenInDoubt_choose;

  /// No description provided for @whenInDoubt_choose_body.
  ///
  /// In ar, this message translates to:
  /// **'أرز أو بطاطس + بروتين مناسب + دهون طبيعية.'**
  String get whenInDoubt_choose_body;

  /// No description provided for @whenInDoubt_avoid.
  ///
  /// In ar, this message translates to:
  /// **'امنع تماماً'**
  String get whenInDoubt_avoid;

  /// No description provided for @whenInDoubt_avoid_body.
  ///
  /// In ar, this message translates to:
  /// **'الفراخ والبيض، الحليب ومشتقاته، البقوليات، المُصنّع، الزيوت الصناعية.'**
  String get whenInDoubt_avoid_body;

  /// No description provided for @whenInDoubt_moderate.
  ///
  /// In ar, this message translates to:
  /// **'استخدم باعتدال'**
  String get whenInDoubt_moderate;

  /// No description provided for @whenInDoubt_moderate_body.
  ///
  /// In ar, this message translates to:
  /// **'الأجبان المعتقة، الفاكهة، العسل، التمر، القهوة، والشاي المحدود.'**
  String get whenInDoubt_moderate_body;

  /// No description provided for @whenInDoubt_watch.
  ///
  /// In ar, this message translates to:
  /// **'راقب'**
  String get whenInDoubt_watch;

  /// No description provided for @whenInDoubt_watch_body.
  ///
  /// In ar, this message translates to:
  /// **'الهضم، الطاقة، النوم، والشبع.'**
  String get whenInDoubt_watch_body;

  /// No description provided for @whenInDoubt_openMealBanks.
  ///
  /// In ar, this message translates to:
  /// **'افتح بنك الوجبات'**
  String get whenInDoubt_openMealBanks;

  /// No description provided for @whenInDoubt_openMealBanks_sub.
  ///
  /// In ar, this message translates to:
  /// **'أفكار جاهزة حسب وقت اليوم'**
  String get whenInDoubt_openMealBanks_sub;

  /// No description provided for @whenInDoubt_readRules.
  ///
  /// In ar, this message translates to:
  /// **'اقرأ القواعد الذهبية'**
  String get whenInDoubt_readRules;

  /// No description provided for @whenInDoubt_readRules_sub.
  ///
  /// In ar, this message translates to:
  /// **'ست قواعد تُبقي النظام واضحاً'**
  String get whenInDoubt_readRules_sub;

  /// No description provided for @whenInDoubt_photoNow.
  ///
  /// In ar, this message translates to:
  /// **'صوّر ما أمامك'**
  String get whenInDoubt_photoNow;

  /// No description provided for @whenInDoubt_photoNow_sub.
  ///
  /// In ar, this message translates to:
  /// **'نحلّل وجبتك ونعطيك الإشارة'**
  String get whenInDoubt_photoNow_sub;

  /// No description provided for @capture_title.
  ///
  /// In ar, this message translates to:
  /// **'تحليل وجبة'**
  String get capture_title;

  /// No description provided for @capture_analyzingHint.
  ///
  /// In ar, this message translates to:
  /// **'يقرأ الذكاء الاصطناعي طبقك الآن — يستغرق الأمر ثوانٍ قليلة عادةً.'**
  String get capture_analyzingHint;

  /// No description provided for @capture_analyzing.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحليل الوجبة…'**
  String get capture_analyzing;

  /// No description provided for @capture_hint.
  ///
  /// In ar, this message translates to:
  /// **'صوّر وجبتك أو اختر صورة من المعرض، وسنحلّلها فوراً.'**
  String get capture_hint;

  /// No description provided for @capture_camera.
  ///
  /// In ar, this message translates to:
  /// **'التقط بالكاميرا'**
  String get capture_camera;

  /// No description provided for @capture_gallery.
  ///
  /// In ar, this message translates to:
  /// **'اختر من المعرض'**
  String get capture_gallery;

  /// No description provided for @capture_unexpectedError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع'**
  String get capture_unexpectedError;

  /// No description provided for @history_title.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get history_title;

  /// No description provided for @history_list.
  ///
  /// In ar, this message translates to:
  /// **'قائمة'**
  String get history_list;

  /// No description provided for @history_calendar.
  ///
  /// In ar, this message translates to:
  /// **'تقويم'**
  String get history_calendar;

  /// No description provided for @history_searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في الوجبات…'**
  String get history_searchHint;

  /// No description provided for @history_searchEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد وجبات تطابق بحثك.'**
  String get history_searchEmpty;

  /// No description provided for @history_empty_title.
  ///
  /// In ar, this message translates to:
  /// **'لا سجلّات بعد'**
  String get history_empty_title;

  /// No description provided for @history_empty_hint.
  ///
  /// In ar, this message translates to:
  /// **'صوّر أول وجبة من تبويب اليوم لتبدأ المتابعة.'**
  String get history_empty_hint;

  /// No description provided for @history_bodyTrackingLogged.
  ///
  /// In ar, this message translates to:
  /// **'متابعة جسم مسجّلة'**
  String get history_bodyTrackingLogged;

  /// No description provided for @history_today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get history_today;

  /// No description provided for @history_yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get history_yesterday;

  /// No description provided for @history_noMealsThatDay.
  ///
  /// In ar, this message translates to:
  /// **'لم تسجّل وجبات في هذا اليوم.'**
  String get history_noMealsThatDay;

  /// No description provided for @history_mealsAvg.
  ///
  /// In ar, this message translates to:
  /// **'{count} {meals} • متوسط {avg}٪'**
  String history_mealsAvg(int count, String meals, int avg);

  /// No description provided for @history_mealsOne.
  ///
  /// In ar, this message translates to:
  /// **'وجبة'**
  String get history_mealsOne;

  /// No description provided for @history_mealsMany.
  ///
  /// In ar, this message translates to:
  /// **'وجبات'**
  String get history_mealsMany;

  /// No description provided for @history_noMealsLabel.
  ///
  /// In ar, this message translates to:
  /// **'بلا وجبات'**
  String get history_noMealsLabel;

  /// No description provided for @mealDetail_title.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الوجبة'**
  String get mealDetail_title;

  /// No description provided for @mealDetail_items.
  ///
  /// In ar, this message translates to:
  /// **'العناصر'**
  String get mealDetail_items;

  /// No description provided for @mealDetail_logBodyResponse.
  ///
  /// In ar, this message translates to:
  /// **'سجّل كيف شعرت بعد هذه الوجبة'**
  String get mealDetail_logBodyResponse;

  /// No description provided for @mealDetail_suggestions.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات للتحسين'**
  String get mealDetail_suggestions;

  /// No description provided for @mealDetail_deleteMeal.
  ///
  /// In ar, this message translates to:
  /// **'حذف الوجبة'**
  String get mealDetail_deleteMeal;

  /// No description provided for @mealDetail_deleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذه الوجبة؟'**
  String get mealDetail_deleteTitle;

  /// No description provided for @mealDetail_deleteBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُحذف سجل الوجبة وملاحظاتها نهائياً.'**
  String get mealDetail_deleteBody;

  /// No description provided for @mealDetail_notFound.
  ///
  /// In ar, this message translates to:
  /// **'لم تعد هذه الوجبة موجودة.'**
  String get mealDetail_notFound;

  /// No description provided for @mealDetail_footerDisclaimer.
  ///
  /// In ar, this message translates to:
  /// **'هذا التطبيق لا يقدّم استشارة طبية. النتائج لأغراض المتابعة فقط.'**
  String get mealDetail_footerDisclaimer;

  /// No description provided for @mealDetail_editedBadge.
  ///
  /// In ar, this message translates to:
  /// **'مُعدَّلة'**
  String get mealDetail_editedBadge;

  /// No description provided for @mealDetail_logAgain.
  ///
  /// In ar, this message translates to:
  /// **'سجّل هذه الوجبة من جديد'**
  String get mealDetail_logAgain;

  /// No description provided for @mealDetail_logAgainDone.
  ///
  /// In ar, this message translates to:
  /// **'سُجّلت من جديد كوجبة جديدة.'**
  String get mealDetail_logAgainDone;

  /// No description provided for @mealDetail_editItems.
  ///
  /// In ar, this message translates to:
  /// **'تعديل العناصر'**
  String get mealDetail_editItems;

  /// No description provided for @editItems_title.
  ///
  /// In ar, this message translates to:
  /// **'تعديل عناصر الوجبة'**
  String get editItems_title;

  /// No description provided for @editItems_hint.
  ///
  /// In ar, this message translates to:
  /// **'صحّح اسماً خاطئاً، أو غيّر منطقة عنصر، أو احذف عنصراً أخطأ الذكاء الاصطناعي في قراءته — وتتحدّث النتيجة فوراً.'**
  String get editItems_hint;

  /// No description provided for @editItems_nameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم العنصر'**
  String get editItems_nameLabel;

  /// No description provided for @editItems_removeTooltip.
  ///
  /// In ar, this message translates to:
  /// **'حذف العنصر'**
  String get editItems_removeTooltip;

  /// No description provided for @editItems_newScore.
  ///
  /// In ar, this message translates to:
  /// **'النتيجة الجديدة'**
  String get editItems_newScore;

  /// No description provided for @editItems_empty.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج الوجبة إلى عنصر واحد على الأقل.'**
  String get editItems_empty;

  /// No description provided for @editItems_saved.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الوجبة.'**
  String get editItems_saved;

  /// No description provided for @scoreBand_excellent.
  ///
  /// In ar, this message translates to:
  /// **'ممتاز'**
  String get scoreBand_excellent;

  /// No description provided for @scoreBand_good.
  ///
  /// In ar, this message translates to:
  /// **'جيد'**
  String get scoreBand_good;

  /// No description provided for @scoreBand_average.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get scoreBand_average;

  /// No description provided for @scoreBand_weak.
  ///
  /// In ar, this message translates to:
  /// **'ضعيف'**
  String get scoreBand_weak;

  /// No description provided for @settings_title.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings_title;

  /// No description provided for @settings_account.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get settings_account;

  /// No description provided for @settings_signOut.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get settings_signOut;

  /// No description provided for @settings_signedOut.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الخروج.'**
  String get settings_signedOut;

  /// No description provided for @settings_deleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get settings_deleteAccount;

  /// No description provided for @settings_deleteAccount_confirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب نهائياً؟'**
  String get settings_deleteAccount_confirmTitle;

  /// No description provided for @settings_deleteAccount_confirmBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُحذف حسابك وبياناته من الخادم، وكذلك كل بيانات المتابعة على هذا الجهاز. لا يمكن التراجع.'**
  String get settings_deleteAccount_confirmBody;

  /// No description provided for @settings_deleteAccount_successTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف حسابك'**
  String get settings_deleteAccount_successTitle;

  /// No description provided for @settings_deleteAccount_successBody.
  ///
  /// In ar, this message translates to:
  /// **'تم محو حسابك وبياناته من الخادم نهائياً.\n\nلو سجّلت دخولاً مجدداً ببريد Google أو Apple نفسه، فسيُنشأ حساب جديد تماماً بلا أي بيانات سابقة.'**
  String get settings_deleteAccount_successBody;

  /// No description provided for @settings_deleteAccount_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حذف الحساب: {error}'**
  String settings_deleteAccount_failed(String error);

  /// No description provided for @settings_reminders.
  ///
  /// In ar, this message translates to:
  /// **'التذكيرات'**
  String get settings_reminders;

  /// No description provided for @settings_notificationSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الإشعارات'**
  String get settings_notificationSettings;

  /// No description provided for @settings_safetyLegal.
  ///
  /// In ar, this message translates to:
  /// **'الأمان والقانون'**
  String get settings_safetyLegal;

  /// No description provided for @settings_reReadDisclaimer.
  ///
  /// In ar, this message translates to:
  /// **'إعادة قراءة التنبيه الطبي'**
  String get settings_reReadDisclaimer;

  /// No description provided for @settings_language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settings_language;

  /// No description provided for @settings_language_arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get settings_language_arabic;

  /// No description provided for @settings_language_english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get settings_language_english;

  /// No description provided for @settings_about.
  ///
  /// In ar, this message translates to:
  /// **'حول'**
  String get settings_about;

  /// No description provided for @settings_about_body.
  ///
  /// In ar, this message translates to:
  /// **'الطيبات — تطبيق وعي غذائي. يستخدم نموذج Gemini للتحليل عبر خادم آمن. لا يقدّم استشارة طبية ولا يحلّ محل الطبيب أو أخصائي التغذية.'**
  String get settings_about_body;

  /// No description provided for @settings_partialEnglishNote.
  ///
  /// In ar, this message translates to:
  /// **'كل المحتوى متوفر بالعربية والإنجليزية. اللغة تطبَّق فوراً بعد التبديل.'**
  String get settings_partialEnglishNote;

  /// No description provided for @bodyResponse_title.
  ///
  /// In ar, this message translates to:
  /// **'كيف شعرت بعد الوجبة؟'**
  String get bodyResponse_title;

  /// No description provided for @bodyResponse_save.
  ///
  /// In ar, this message translates to:
  /// **'احفظ'**
  String get bodyResponse_save;

  /// No description provided for @bodyResponse_finish.
  ///
  /// In ar, this message translates to:
  /// **'أنهِ'**
  String get bodyResponse_finish;

  /// No description provided for @bodyResponse_couldNotSave.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الحفظ: {error}'**
  String bodyResponse_couldNotSave(String error);

  /// No description provided for @bodyResponse_q1_title.
  ///
  /// In ar, this message translates to:
  /// **'هل شعرت بشبع مريح؟'**
  String get bodyResponse_q1_title;

  /// No description provided for @bodyResponse_q1_h1.
  ///
  /// In ar, this message translates to:
  /// **'لم أشعر بشبع'**
  String get bodyResponse_q1_h1;

  /// No description provided for @bodyResponse_q1_h2.
  ///
  /// In ar, this message translates to:
  /// **'شبع خفيف'**
  String get bodyResponse_q1_h2;

  /// No description provided for @bodyResponse_q1_h3.
  ///
  /// In ar, this message translates to:
  /// **'شبع مريح'**
  String get bodyResponse_q1_h3;

  /// No description provided for @bodyResponse_q1_h4.
  ///
  /// In ar, this message translates to:
  /// **'شبع كامل'**
  String get bodyResponse_q1_h4;

  /// No description provided for @bodyResponse_q1_h5.
  ///
  /// In ar, this message translates to:
  /// **'ممتلئ جداً'**
  String get bodyResponse_q1_h5;

  /// No description provided for @bodyResponse_q2_title.
  ///
  /// In ar, this message translates to:
  /// **'هل حدث انتفاخ أو ثقل؟'**
  String get bodyResponse_q2_title;

  /// No description provided for @bodyResponse_q2_h_comfortable.
  ///
  /// In ar, this message translates to:
  /// **'مرتاح تماماً'**
  String get bodyResponse_q2_h_comfortable;

  /// No description provided for @bodyResponse_q2_h_lightHeavy.
  ///
  /// In ar, this message translates to:
  /// **'ثقل خفيف'**
  String get bodyResponse_q2_h_lightHeavy;

  /// No description provided for @bodyResponse_q2_h_bloating.
  ///
  /// In ar, this message translates to:
  /// **'انتفاخ ملحوظ'**
  String get bodyResponse_q2_h_bloating;

  /// No description provided for @bodyResponse_q2_h_clearHeavy.
  ///
  /// In ar, this message translates to:
  /// **'ثقل واضح'**
  String get bodyResponse_q2_h_clearHeavy;

  /// No description provided for @bodyResponse_q2_h_severeHeavy.
  ///
  /// In ar, this message translates to:
  /// **'ثقل شديد'**
  String get bodyResponse_q2_h_severeHeavy;

  /// No description provided for @bodyResponse_q2_axisStart.
  ///
  /// In ar, this message translates to:
  /// **'٠ مرتاح'**
  String get bodyResponse_q2_axisStart;

  /// No description provided for @bodyResponse_q2_axisEnd.
  ///
  /// In ar, this message translates to:
  /// **'٥ ثقل شديد'**
  String get bodyResponse_q2_axisEnd;

  /// No description provided for @bodyResponse_q3_title.
  ///
  /// In ar, this message translates to:
  /// **'كيف كانت طاقتك بعد الأكل؟'**
  String get bodyResponse_q3_title;

  /// No description provided for @bodyResponse_q3_l1.
  ///
  /// In ar, this message translates to:
  /// **'نعسان جداً'**
  String get bodyResponse_q3_l1;

  /// No description provided for @bodyResponse_q3_l2.
  ///
  /// In ar, this message translates to:
  /// **'خامل'**
  String get bodyResponse_q3_l2;

  /// No description provided for @bodyResponse_q3_l3.
  ///
  /// In ar, this message translates to:
  /// **'عادي'**
  String get bodyResponse_q3_l3;

  /// No description provided for @bodyResponse_q3_l4.
  ///
  /// In ar, this message translates to:
  /// **'نشيط'**
  String get bodyResponse_q3_l4;

  /// No description provided for @bodyResponse_q3_l5.
  ///
  /// In ar, this message translates to:
  /// **'نشيط جداً'**
  String get bodyResponse_q3_l5;

  /// No description provided for @bodyResponse_q4_title.
  ///
  /// In ar, this message translates to:
  /// **'كيف كان نومك بعد الوجبة؟'**
  String get bodyResponse_q4_title;

  /// No description provided for @bodyResponse_q4_hint.
  ///
  /// In ar, this message translates to:
  /// **'اختياري — يمكنك تركها على \"لا أعلم\" والعودة لاحقاً.'**
  String get bodyResponse_q4_hint;

  /// No description provided for @bodyResponse_q5_title.
  ///
  /// In ar, this message translates to:
  /// **'هل تستحق هذه الوجبة التكرار؟'**
  String get bodyResponse_q5_title;

  /// No description provided for @bodyResponse_q5_hint.
  ///
  /// In ar, this message translates to:
  /// **'هذه الإجابة تساعد التطبيق يقترح ما يناسب جسمك.'**
  String get bodyResponse_q5_hint;

  /// No description provided for @bodyResponse_q5_whyOptional.
  ///
  /// In ar, this message translates to:
  /// **'لماذا؟ (اختياري)'**
  String get bodyResponse_q5_whyOptional;

  /// No description provided for @bodyResponse_thanks_title.
  ///
  /// In ar, this message translates to:
  /// **'شكراً لك'**
  String get bodyResponse_thanks_title;

  /// No description provided for @bodyResponse_thanks_body.
  ///
  /// In ar, this message translates to:
  /// **'هذه الملاحظات تساعدك تعرف جسمك أكثر، ومع الوقت يساعدك التطبيق على اقتراح ما يناسبك.'**
  String get bodyResponse_thanks_body;

  /// No description provided for @fasting_title.
  ///
  /// In ar, this message translates to:
  /// **'الصيام'**
  String get fasting_title;

  /// No description provided for @fasting_history_empty.
  ///
  /// In ar, this message translates to:
  /// **'لم تسجّل أي يوم صيام بعد.'**
  String get fasting_history_empty;

  /// No description provided for @notif_title.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notif_title;

  /// No description provided for @notif_kinds_title.
  ///
  /// In ar, this message translates to:
  /// **'أنواع التذكيرات'**
  String get notif_kinds_title;

  /// No description provided for @notif_grantedBanner.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات مفعّلة من النظام.'**
  String get notif_grantedBanner;

  /// No description provided for @notif_notGrantedTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات لم تُفعّل بعد من النظام.'**
  String get notif_notGrantedTitle;

  /// No description provided for @notif_notGrantedBody.
  ///
  /// In ar, this message translates to:
  /// **'لتصلك التذكيرات، نحتاج إذن النظام مرة واحدة.'**
  String get notif_notGrantedBody;

  /// No description provided for @notif_allowButton.
  ///
  /// In ar, this message translates to:
  /// **'السماح بالإشعارات'**
  String get notif_allowButton;

  /// No description provided for @notif_testButton.
  ///
  /// In ar, this message translates to:
  /// **'أرسل إشعار اختباري'**
  String get notif_testButton;

  /// No description provided for @notif_antiRepeatNote.
  ///
  /// In ar, this message translates to:
  /// **'النصائح تختلف يومياً — التطبيق يتجنّب إعادة آخر ١٠ نصائح لكل وقت حتى لا تشعر بالتكرار.'**
  String get notif_antiRepeatNote;

  /// No description provided for @error_couldNotReachServer.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الوصول للخادم. تأكّد من اتصالك بالإنترنت. ({error})'**
  String error_couldNotReachServer(String error);

  /// No description provided for @error_network.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الوصول للخادم. تأكّد من اتصالك بالإنترنت وحاول مرة أخرى.'**
  String get error_network;

  /// No description provided for @error_unexpected.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع. حاول مرة أخرى.'**
  String get error_unexpected;

  /// No description provided for @error_noSession.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد جلسة مفتوحة.'**
  String get error_noSession;

  /// No description provided for @bodyResponse_later.
  ///
  /// In ar, this message translates to:
  /// **'لاحقاً'**
  String get bodyResponse_later;

  /// No description provided for @bodyResponse_discardTitle.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل الإجابات؟'**
  String get bodyResponse_discardTitle;

  /// No description provided for @bodyResponse_discardBody.
  ///
  /// In ar, this message translates to:
  /// **'لم تُحفظ بعد. هل تريد الخروج بدون حفظ متابعة الجسم؟'**
  String get bodyResponse_discardBody;

  /// No description provided for @bodyResponse_discardConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get bodyResponse_discardConfirm;

  /// No description provided for @bodyResponse_stepIndicator.
  ///
  /// In ar, this message translates to:
  /// **'{step} / {total}'**
  String bodyResponse_stepIndicator(int step, int total);

  /// No description provided for @bodyResponseCard_title.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الجسم'**
  String get bodyResponseCard_title;

  /// No description provided for @bodyResponseCard_edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get bodyResponseCard_edit;

  /// No description provided for @bodyResponseCard_satietyLabel.
  ///
  /// In ar, this message translates to:
  /// **'الشبع'**
  String get bodyResponseCard_satietyLabel;

  /// No description provided for @bodyResponseCard_satietyNone.
  ///
  /// In ar, this message translates to:
  /// **'لا شبع'**
  String get bodyResponseCard_satietyNone;

  /// No description provided for @bodyResponseCard_satietyLight.
  ///
  /// In ar, this message translates to:
  /// **'خفيف'**
  String get bodyResponseCard_satietyLight;

  /// No description provided for @bodyResponseCard_satietyComfortable.
  ///
  /// In ar, this message translates to:
  /// **'مريح'**
  String get bodyResponseCard_satietyComfortable;

  /// No description provided for @bodyResponseCard_satietyFull.
  ///
  /// In ar, this message translates to:
  /// **'كامل'**
  String get bodyResponseCard_satietyFull;

  /// No description provided for @bodyResponseCard_satietyOverfull.
  ///
  /// In ar, this message translates to:
  /// **'ممتلئ جداً'**
  String get bodyResponseCard_satietyOverfull;

  /// No description provided for @bodyResponseCard_bloatingLabel.
  ///
  /// In ar, this message translates to:
  /// **'الانتفاخ'**
  String get bodyResponseCard_bloatingLabel;

  /// No description provided for @bodyResponseCard_bloatingComfortable.
  ///
  /// In ar, this message translates to:
  /// **'مرتاح'**
  String get bodyResponseCard_bloatingComfortable;

  /// No description provided for @bodyResponseCard_bloatingLight.
  ///
  /// In ar, this message translates to:
  /// **'خفيف'**
  String get bodyResponseCard_bloatingLight;

  /// No description provided for @bodyResponseCard_bloatingNoticeable.
  ///
  /// In ar, this message translates to:
  /// **'ملحوظ'**
  String get bodyResponseCard_bloatingNoticeable;

  /// No description provided for @bodyResponseCard_bloatingClear.
  ///
  /// In ar, this message translates to:
  /// **'واضح'**
  String get bodyResponseCard_bloatingClear;

  /// No description provided for @bodyResponseCard_bloatingSevere.
  ///
  /// In ar, this message translates to:
  /// **'شديد'**
  String get bodyResponseCard_bloatingSevere;

  /// No description provided for @bodyResponseCard_energyLabel.
  ///
  /// In ar, this message translates to:
  /// **'الطاقة'**
  String get bodyResponseCard_energyLabel;

  /// No description provided for @bodyResponseCard_energySleepy.
  ///
  /// In ar, this message translates to:
  /// **'نعسان'**
  String get bodyResponseCard_energySleepy;

  /// No description provided for @bodyResponseCard_energySluggish.
  ///
  /// In ar, this message translates to:
  /// **'خامل'**
  String get bodyResponseCard_energySluggish;

  /// No description provided for @bodyResponseCard_energyNormal.
  ///
  /// In ar, this message translates to:
  /// **'عادي'**
  String get bodyResponseCard_energyNormal;

  /// No description provided for @bodyResponseCard_energyEnergetic.
  ///
  /// In ar, this message translates to:
  /// **'نشيط'**
  String get bodyResponseCard_energyEnergetic;

  /// No description provided for @bodyResponseCard_energyVeryEnergetic.
  ///
  /// In ar, this message translates to:
  /// **'نشيط جداً'**
  String get bodyResponseCard_energyVeryEnergetic;

  /// No description provided for @bodyResponseCard_loggedAfter.
  ///
  /// In ar, this message translates to:
  /// **'سُجّلت بعد {hours} ساعة من الوجبة'**
  String bodyResponseCard_loggedAfter(int hours);

  /// No description provided for @sleep_positive.
  ///
  /// In ar, this message translates to:
  /// **'نوم مريح'**
  String get sleep_positive;

  /// No description provided for @sleep_neutral.
  ///
  /// In ar, this message translates to:
  /// **'لم ألاحظ فرقاً'**
  String get sleep_neutral;

  /// No description provided for @sleep_negative.
  ///
  /// In ar, this message translates to:
  /// **'تأثر سلباً'**
  String get sleep_negative;

  /// No description provided for @sleep_unknown.
  ///
  /// In ar, this message translates to:
  /// **'لا أعلم'**
  String get sleep_unknown;

  /// No description provided for @worth_yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم، أحبها'**
  String get worth_yes;

  /// No description provided for @worth_maybe.
  ///
  /// In ar, this message translates to:
  /// **'ربما'**
  String get worth_maybe;

  /// No description provided for @worth_no.
  ///
  /// In ar, this message translates to:
  /// **'لا، تجنّبها'**
  String get worth_no;

  /// No description provided for @notif_kind_morning.
  ///
  /// In ar, this message translates to:
  /// **'نصيحة الصباح'**
  String get notif_kind_morning;

  /// No description provided for @notif_kind_lunch.
  ///
  /// In ar, this message translates to:
  /// **'تذكير الغداء'**
  String get notif_kind_lunch;

  /// No description provided for @notif_kind_evening.
  ///
  /// In ar, this message translates to:
  /// **'نصيحة المساء'**
  String get notif_kind_evening;

  /// No description provided for @notif_kind_endOfDay.
  ///
  /// In ar, this message translates to:
  /// **'سجّل وجباتك'**
  String get notif_kind_endOfDay;

  /// No description provided for @notif_kind_weeklyPrep.
  ///
  /// In ar, this message translates to:
  /// **'تحضير الأسبوع'**
  String get notif_kind_weeklyPrep;

  /// No description provided for @notif_kind_morning_desc.
  ///
  /// In ar, this message translates to:
  /// **'تذكير صباحي بنصيحة من نظام الطيبات.'**
  String get notif_kind_morning_desc;

  /// No description provided for @notif_kind_lunch_desc.
  ///
  /// In ar, this message translates to:
  /// **'تذكير بوقت الغداء وقاعدة ذهبية تختلف يومياً.'**
  String get notif_kind_lunch_desc;

  /// No description provided for @notif_kind_evening_desc.
  ///
  /// In ar, this message translates to:
  /// **'نصيحة المساء قبل العشاء.'**
  String get notif_kind_evening_desc;

  /// No description provided for @notif_kind_endOfDay_desc.
  ///
  /// In ar, this message translates to:
  /// **'تذكير بتسجيل ما أكلت اليوم.'**
  String get notif_kind_endOfDay_desc;

  /// No description provided for @notif_kind_weeklyPrep_desc.
  ///
  /// In ar, this message translates to:
  /// **'كل سبت صباحاً — قائمة تحضير الأسبوع.'**
  String get notif_kind_weeklyPrep_desc;

  /// No description provided for @notif_bodyFollowup_title.
  ///
  /// In ar, this message translates to:
  /// **'تذكير متابعة الجسم'**
  String get notif_bodyFollowup_title;

  /// No description provided for @notif_bodyFollowup_subtitle.
  ///
  /// In ar, this message translates to:
  /// **'بعد ٣ ساعات من كل وجبة'**
  String get notif_bodyFollowup_subtitle;

  /// No description provided for @notif_dailyAt.
  ///
  /// In ar, this message translates to:
  /// **'يومياً {time}'**
  String notif_dailyAt(String time);

  /// No description provided for @notif_everySaturdayAt.
  ///
  /// In ar, this message translates to:
  /// **'كل سبت {time}'**
  String notif_everySaturdayAt(String time);

  /// No description provided for @notif_testBody.
  ///
  /// In ar, this message translates to:
  /// **'هذا إشعار اختباري. لو وصلك معناه التذكيرات شغّالة.'**
  String get notif_testBody;

  /// No description provided for @fasting_today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get fasting_today;

  /// No description provided for @fasting_fastingToday.
  ///
  /// In ar, this message translates to:
  /// **'أنت صائم اليوم'**
  String get fasting_fastingToday;

  /// No description provided for @fasting_markFasting.
  ///
  /// In ar, this message translates to:
  /// **'سجّل أنني صائم اليوم'**
  String get fasting_markFasting;

  /// No description provided for @fasting_unmarkFasting.
  ///
  /// In ar, this message translates to:
  /// **'ألغِ تسجيل الصيام'**
  String get fasting_unmarkFasting;

  /// No description provided for @fasting_kind_monday.
  ///
  /// In ar, this message translates to:
  /// **'اثنين'**
  String get fasting_kind_monday;

  /// No description provided for @fasting_kind_thursday.
  ///
  /// In ar, this message translates to:
  /// **'خميس'**
  String get fasting_kind_thursday;

  /// No description provided for @fasting_kind_white13.
  ///
  /// In ar, this message translates to:
  /// **'الأيام البيض — ١٣'**
  String get fasting_kind_white13;

  /// No description provided for @fasting_kind_white14.
  ///
  /// In ar, this message translates to:
  /// **'الأيام البيض — ١٤'**
  String get fasting_kind_white14;

  /// No description provided for @fasting_kind_white15.
  ///
  /// In ar, this message translates to:
  /// **'الأيام البيض — ١٥'**
  String get fasting_kind_white15;

  /// No description provided for @fasting_kind_general.
  ///
  /// In ar, this message translates to:
  /// **'صيام تطوّع'**
  String get fasting_kind_general;

  /// No description provided for @fasting_hint_weeklyMustahab.
  ///
  /// In ar, this message translates to:
  /// **'مستحب لمن استطاع — رحمة لا فرض.'**
  String get fasting_hint_weeklyMustahab;

  /// No description provided for @fasting_hint_white.
  ///
  /// In ar, this message translates to:
  /// **'الأيام البيض من السنن المؤكدة.'**
  String get fasting_hint_white;

  /// No description provided for @fasting_hint_general.
  ///
  /// In ar, this message translates to:
  /// **'يوم صيام إضافي اخترته أنت.'**
  String get fasting_hint_general;

  /// No description provided for @fasting_log.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get fasting_log;

  /// No description provided for @fasting_nextSuggestion.
  ///
  /// In ar, this message translates to:
  /// **'أقرب يوم صيام مرشّح: {when}'**
  String fasting_nextSuggestion(String when);

  /// No description provided for @fasting_tomorrow.
  ///
  /// In ar, this message translates to:
  /// **'غداً'**
  String get fasting_tomorrow;

  /// No description provided for @fasting_inDays.
  ///
  /// In ar, this message translates to:
  /// **'بعد {n} أيام'**
  String fasting_inDays(int n);

  /// No description provided for @suggestions_title.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات ذكية'**
  String get suggestions_title;

  /// No description provided for @suggestions_tab_single.
  ///
  /// In ar, this message translates to:
  /// **'اقتراح وجبة'**
  String get suggestions_tab_single;

  /// No description provided for @suggestions_tab_weekly.
  ///
  /// In ar, this message translates to:
  /// **'خطة الأسبوع'**
  String get suggestions_tab_weekly;

  /// No description provided for @suggestions_single_intro.
  ///
  /// In ar, this message translates to:
  /// **'احصل على ٣ أفكار وجبات طيبة دفعة واحدة — من المنطقة الخضراء، مع لمسات صفراء بحساب، وبدون أي عنصر ممنوع.'**
  String get suggestions_single_intro;

  /// No description provided for @suggestions_single_button_first.
  ///
  /// In ar, this message translates to:
  /// **'اقترح ٣ وجبات'**
  String get suggestions_single_button_first;

  /// No description provided for @suggestions_single_button_again.
  ///
  /// In ar, this message translates to:
  /// **'اقترح ٣ وجبات أخرى'**
  String get suggestions_single_button_again;

  /// No description provided for @suggestions_components.
  ///
  /// In ar, this message translates to:
  /// **'المكونات'**
  String get suggestions_components;

  /// No description provided for @suggestions_anyTime.
  ///
  /// In ar, this message translates to:
  /// **'أي وقت'**
  String get suggestions_anyTime;

  /// No description provided for @suggestions_optionN.
  ///
  /// In ar, this message translates to:
  /// **'خيار {n}'**
  String suggestions_optionN(int n);

  /// No description provided for @suggestions_plan_intro.
  ///
  /// In ar, this message translates to:
  /// **'ولّد خطة وجبات لسبعة أيام مرتّبة (سبت ← جمعة) مع الفطور والغداء والعشاء لكل يوم — من الطيبات فقط.'**
  String get suggestions_plan_intro;

  /// No description provided for @suggestions_plan_button_first.
  ///
  /// In ar, this message translates to:
  /// **'ولّد خطة الأسبوع'**
  String get suggestions_plan_button_first;

  /// No description provided for @suggestions_plan_button_again.
  ///
  /// In ar, this message translates to:
  /// **'ولّد خطة جديدة'**
  String get suggestions_plan_button_again;

  /// No description provided for @plan_savedAuto.
  ///
  /// In ar, this message translates to:
  /// **'خطتك محفوظة على جهازك — أشّر على كل وجبة عند إنجازها.'**
  String get plan_savedAuto;

  /// No description provided for @plan_progress.
  ///
  /// In ar, this message translates to:
  /// **'أنجزت {done} من {total} وجبة'**
  String plan_progress(int done, int total);

  /// No description provided for @plan_replaceTitle.
  ///
  /// In ar, this message translates to:
  /// **'توليد خطة جديدة؟'**
  String get plan_replaceTitle;

  /// No description provided for @plan_replaceBody.
  ///
  /// In ar, this message translates to:
  /// **'سيحل هذا محل خطتك الحالية وتقدّمك فيها.'**
  String get plan_replaceBody;

  /// No description provided for @plan_generate.
  ///
  /// In ar, this message translates to:
  /// **'ولّد'**
  String get plan_generate;

  /// No description provided for @intel_title.
  ///
  /// In ar, this message translates to:
  /// **'كيف يتجاوب جسمك؟'**
  String get intel_title;

  /// No description provided for @intel_avgSatiety.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الشبع'**
  String get intel_avgSatiety;

  /// No description provided for @intel_avgBloating.
  ///
  /// In ar, this message translates to:
  /// **'معدّل الانتفاخ'**
  String get intel_avgBloating;

  /// No description provided for @intel_outOf5.
  ///
  /// In ar, this message translates to:
  /// **'/ ٥'**
  String get intel_outOf5;

  /// No description provided for @intel_last30days.
  ///
  /// In ar, this message translates to:
  /// **'آخر ٣٠ يوماً'**
  String get intel_last30days;

  /// No description provided for @intel_empty.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بتسجيل متابعة الجسم بعد وجباتك حتى يعرف التطبيق ما يناسبك ويظهر أنماطك هنا.'**
  String get intel_empty;

  /// No description provided for @intel_topComforting.
  ///
  /// In ar, this message translates to:
  /// **'وجبات أعطتك راحة وشبعاً'**
  String get intel_topComforting;

  /// No description provided for @intel_heaviest.
  ///
  /// In ar, this message translates to:
  /// **'وجبات أثقلت جسمك'**
  String get intel_heaviest;

  /// No description provided for @intel_satietyBadge.
  ///
  /// In ar, this message translates to:
  /// **'{n} / ٥ شبع'**
  String intel_satietyBadge(int n);

  /// No description provided for @intel_bloatingBadge.
  ///
  /// In ar, this message translates to:
  /// **'انتفاخ {n} / ٥'**
  String intel_bloatingBadge(int n);

  /// No description provided for @intel_sleepTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأثير الوجبات على نومك'**
  String get intel_sleepTitle;

  /// No description provided for @intel_zoneShareTitle.
  ///
  /// In ar, this message translates to:
  /// **'توزّع الإشارات في طبقك'**
  String get intel_zoneShareTitle;

  /// No description provided for @intel_last7days.
  ///
  /// In ar, this message translates to:
  /// **'آخر ٧ أيام'**
  String get intel_last7days;

  /// No description provided for @intel_noDataYet.
  ///
  /// In ar, this message translates to:
  /// **'لا بيانات بعد'**
  String get intel_noDataYet;

  /// No description provided for @intel_zonePercent.
  ///
  /// In ar, this message translates to:
  /// **'{pct}٪ {label}'**
  String intel_zonePercent(int pct, String label);

  /// No description provided for @intel_zoneGreen.
  ///
  /// In ar, this message translates to:
  /// **'أخضر'**
  String get intel_zoneGreen;

  /// No description provided for @intel_zoneYellow.
  ///
  /// In ar, this message translates to:
  /// **'أصفر'**
  String get intel_zoneYellow;

  /// No description provided for @intel_zoneRed.
  ///
  /// In ar, this message translates to:
  /// **'أحمر'**
  String get intel_zoneRed;

  /// No description provided for @intel_trendTitle.
  ///
  /// In ar, this message translates to:
  /// **'منحنى الالتزام'**
  String get intel_trendTitle;

  /// No description provided for @intel_trendAvg.
  ///
  /// In ar, this message translates to:
  /// **'متوسط {pct}٪'**
  String intel_trendAvg(int pct);

  /// No description provided for @intel_trendSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'آخر ٣٠ يوماً — متوسط درجة وجبات كل يوم.'**
  String get intel_trendSubtitle;

  /// No description provided for @intel_trendNeedMore.
  ///
  /// In ar, this message translates to:
  /// **'يلزم على الأقل وجبتان لرسم المنحنى.'**
  String get intel_trendNeedMore;

  /// No description provided for @intel_trendToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get intel_trendToday;

  /// No description provided for @intel_trend30daysAgo.
  ///
  /// In ar, this message translates to:
  /// **'٣٠ يوم'**
  String get intel_trend30daysAgo;

  /// No description provided for @intel_tooltipPercent.
  ///
  /// In ar, this message translates to:
  /// **'{pct}٪'**
  String intel_tooltipPercent(int pct);

  /// No description provided for @guide_index_title.
  ///
  /// In ar, this message translates to:
  /// **'الفهرس الذكي'**
  String get guide_index_title;

  /// No description provided for @guide_index_subtitle.
  ///
  /// In ar, this message translates to:
  /// **'الدليل في ١٠ أقسام'**
  String get guide_index_subtitle;

  /// No description provided for @guide_section_guidebook.
  ///
  /// In ar, this message translates to:
  /// **'دليل الوجبات'**
  String get guide_section_guidebook;

  /// No description provided for @guidebook_title.
  ///
  /// In ar, this message translates to:
  /// **'دليل الوجبات الكامل'**
  String get guidebook_title;

  /// No description provided for @guidebook_searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن وجبة أو مكوّن…'**
  String get guidebook_searchHint;

  /// No description provided for @guidebook_empty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد وجبات تطابق بحثك.'**
  String get guidebook_empty;

  /// No description provided for @guidebook_cat_all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get guidebook_cat_all;

  /// No description provided for @guidebook_cat_breakfast.
  ///
  /// In ar, this message translates to:
  /// **'فطور'**
  String get guidebook_cat_breakfast;

  /// No description provided for @guidebook_cat_lunch.
  ///
  /// In ar, this message translates to:
  /// **'غداء'**
  String get guidebook_cat_lunch;

  /// No description provided for @guidebook_cat_dinner.
  ///
  /// In ar, this message translates to:
  /// **'عشاء'**
  String get guidebook_cat_dinner;

  /// No description provided for @guidebook_cat_snack.
  ///
  /// In ar, this message translates to:
  /// **'سناك'**
  String get guidebook_cat_snack;

  /// No description provided for @guidebook_cat_fasting.
  ///
  /// In ar, this message translates to:
  /// **'أيام الصيام'**
  String get guidebook_cat_fasting;

  /// No description provided for @guidebook_components.
  ///
  /// In ar, this message translates to:
  /// **'المكوّنات'**
  String get guidebook_components;

  /// No description provided for @guidebook_prep.
  ///
  /// In ar, this message translates to:
  /// **'طريقة التحضير'**
  String get guidebook_prep;

  /// No description provided for @guidebook_approxNutrition.
  ///
  /// In ar, this message translates to:
  /// **'تقديرات غذائية'**
  String get guidebook_approxNutrition;

  /// No description provided for @nutrition_title.
  ///
  /// In ar, this message translates to:
  /// **'القيم الغذائية'**
  String get nutrition_title;

  /// No description provided for @nutrition_kcalValue.
  ///
  /// In ar, this message translates to:
  /// **'{value} سعرة'**
  String nutrition_kcalValue(int value);

  /// No description provided for @nutrition_kcalUnit.
  ///
  /// In ar, this message translates to:
  /// **'سعرة'**
  String get nutrition_kcalUnit;

  /// No description provided for @nutrition_gramsValue.
  ///
  /// In ar, this message translates to:
  /// **'{value} غ'**
  String nutrition_gramsValue(String value);

  /// No description provided for @nutrition_protein.
  ///
  /// In ar, this message translates to:
  /// **'بروتين'**
  String get nutrition_protein;

  /// No description provided for @nutrition_carbs.
  ///
  /// In ar, this message translates to:
  /// **'كارب'**
  String get nutrition_carbs;

  /// No description provided for @nutrition_fat.
  ///
  /// In ar, this message translates to:
  /// **'دهون'**
  String get nutrition_fat;

  /// No description provided for @nutrition_estimateNote.
  ///
  /// In ar, this message translates to:
  /// **'تقديرات بصرية من الصورة — للوعي العام، وليست قياساً دقيقاً.'**
  String get nutrition_estimateNote;

  /// No description provided for @today_caloriesTitle.
  ///
  /// In ar, this message translates to:
  /// **'سعرات اليوم'**
  String get today_caloriesTitle;

  /// No description provided for @today_caloriesOf.
  ///
  /// In ar, this message translates to:
  /// **'{consumed} / {goal} سعرة'**
  String today_caloriesOf(int consumed, int goal);

  /// No description provided for @today_caloriesRemaining.
  ///
  /// In ar, this message translates to:
  /// **'باقٍ {value} سعرة من هدفك اليومي'**
  String today_caloriesRemaining(int value);

  /// No description provided for @today_caloriesOver.
  ///
  /// In ar, this message translates to:
  /// **'تجاوزت هدفك اليومي بـ {value} سعرة'**
  String today_caloriesOver(int value);

  /// No description provided for @settings_nutrition.
  ///
  /// In ar, this message translates to:
  /// **'التغذية'**
  String get settings_nutrition;

  /// No description provided for @settings_calorieGoal.
  ///
  /// In ar, this message translates to:
  /// **'هدف السعرات اليومي'**
  String get settings_calorieGoal;

  /// No description provided for @settings_calorieGoal_dialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'هدف السعرات اليومي'**
  String get settings_calorieGoal_dialogTitle;

  /// No description provided for @settings_calorieGoal_note.
  ///
  /// In ar, this message translates to:
  /// **'رقم مرجعي شخصي تختاره بنفسك. التطبيق لا يحسب احتياجك ولا يقدّم توصيات غذائية.'**
  String get settings_calorieGoal_note;

  /// No description provided for @guide_section_philosophy.
  ///
  /// In ar, this message translates to:
  /// **'فلسفة النظام'**
  String get guide_section_philosophy;

  /// No description provided for @guide_section_goldenRules.
  ///
  /// In ar, this message translates to:
  /// **'القواعد الذهبية'**
  String get guide_section_goldenRules;

  /// No description provided for @guide_section_eatingMap.
  ///
  /// In ar, this message translates to:
  /// **'خريطة الأكل'**
  String get guide_section_eatingMap;

  /// No description provided for @guide_section_forbidden.
  ///
  /// In ar, this message translates to:
  /// **'الممنوعات الصريحة'**
  String get guide_section_forbidden;

  /// No description provided for @guide_section_plate.
  ///
  /// In ar, this message translates to:
  /// **'طبق الطيبات'**
  String get guide_section_plate;

  /// No description provided for @guide_section_program15.
  ///
  /// In ar, this message translates to:
  /// **'برنامج ١٥ يوم'**
  String get guide_section_program15;

  /// No description provided for @guide_section_mealBanks.
  ///
  /// In ar, this message translates to:
  /// **'بنك الوجبات'**
  String get guide_section_mealBanks;

  /// No description provided for @guide_section_weeklyPrep.
  ///
  /// In ar, this message translates to:
  /// **'التحضير الأسبوعي'**
  String get guide_section_weeklyPrep;

  /// No description provided for @guide_section_mistakes.
  ///
  /// In ar, this message translates to:
  /// **'الأخطاء الشائعة'**
  String get guide_section_mistakes;

  /// No description provided for @guide_eatingMap_zoneGreen.
  ///
  /// In ar, this message translates to:
  /// **'أخضر'**
  String get guide_eatingMap_zoneGreen;

  /// No description provided for @guide_eatingMap_zoneYellow.
  ///
  /// In ar, this message translates to:
  /// **'أصفر'**
  String get guide_eatingMap_zoneYellow;

  /// No description provided for @guide_eatingMap_zoneRed.
  ///
  /// In ar, this message translates to:
  /// **'أحمر'**
  String get guide_eatingMap_zoneRed;

  /// No description provided for @guide_eatingMap_verdictEat.
  ///
  /// In ar, this message translates to:
  /// **'كُل بثقة'**
  String get guide_eatingMap_verdictEat;

  /// No description provided for @guide_eatingMap_verdictModerate.
  ///
  /// In ar, this message translates to:
  /// **'باعتدال'**
  String get guide_eatingMap_verdictModerate;

  /// No description provided for @guide_eatingMap_verdictAvoid.
  ///
  /// In ar, this message translates to:
  /// **'تجنّب'**
  String get guide_eatingMap_verdictAvoid;

  /// No description provided for @guide_eatingMap_footerGreen.
  ///
  /// In ar, this message translates to:
  /// **'هذه المنطقة هي الأساس. لا حدّ على الكميات إلا الشبع المريح.'**
  String get guide_eatingMap_footerGreen;

  /// No description provided for @guide_eatingMap_footerYellow.
  ///
  /// In ar, this message translates to:
  /// **'العلامة الصفراء ليست تحريماً — هي دعوة للانتباه. راقب جسمك وقلّل عند الحاجة.'**
  String get guide_eatingMap_footerYellow;

  /// No description provided for @guide_eatingMap_footerRed.
  ///
  /// In ar, this message translates to:
  /// **'هذه المنطقة ممنوعة في هذا النظام. عند الشك بمكوّن، افتح \"عندما تحتار\" من شاشة اليوم.'**
  String get guide_eatingMap_footerRed;

  /// No description provided for @guide_plate_baseFormula.
  ///
  /// In ar, this message translates to:
  /// **'الصيغة الأساسية'**
  String get guide_plate_baseFormula;

  /// No description provided for @guide_plate_formula.
  ///
  /// In ar, this message translates to:
  /// **'أرز أو بطاطس + بروتين مناسب + دهون طبيعية'**
  String get guide_plate_formula;

  /// No description provided for @guide_plate_starch_title.
  ///
  /// In ar, this message translates to:
  /// **'نشويات'**
  String get guide_plate_starch_title;

  /// No description provided for @guide_plate_starch_body.
  ///
  /// In ar, this message translates to:
  /// **'اختر بين الأرز أو البطاطس بأي طريقة تحبها (مسلوقة، مشوية، مقلية…).'**
  String get guide_plate_starch_body;

  /// No description provided for @guide_plate_protein_title.
  ///
  /// In ar, this message translates to:
  /// **'بروتين'**
  String get guide_plate_protein_title;

  /// No description provided for @guide_plate_protein_body.
  ///
  /// In ar, this message translates to:
  /// **'لحم أحمر، كبدة، كوارع، أرنب، حمام، أو سمك مستوٍ تماماً. تجنّب الدواجن والبيض.'**
  String get guide_plate_protein_body;

  /// No description provided for @guide_plate_fats_title.
  ///
  /// In ar, this message translates to:
  /// **'دهون طبيعية'**
  String get guide_plate_fats_title;

  /// No description provided for @guide_plate_fats_body.
  ///
  /// In ar, this message translates to:
  /// **'سمن بلدي، زبدة طبيعية، زيت زيتون، أو زيتون — باعتدال.'**
  String get guide_plate_fats_body;

  /// No description provided for @guide_plate_goldenRule_title.
  ///
  /// In ar, this message translates to:
  /// **'القاعدة الذهبية'**
  String get guide_plate_goldenRule_title;

  /// No description provided for @guide_plate_goldenRule_body.
  ///
  /// In ar, this message translates to:
  /// **'بسّط مكونات الوجبة، وتوقّف قبل الامتلاء، وراقب استجابة جسمك.'**
  String get guide_plate_goldenRule_body;

  /// No description provided for @guide_weeklyPrep_reset.
  ///
  /// In ar, this message translates to:
  /// **'تصفير الأسبوع'**
  String get guide_weeklyPrep_reset;

  /// No description provided for @guide_weeklyPrep_hint.
  ///
  /// In ar, this message translates to:
  /// **'علّم كل مهمة بعد إنجازها. القائمة تتصفّر تلقائياً مع بداية كل سبت.'**
  String get guide_weeklyPrep_hint;

  /// No description provided for @guide_weeklyPrep_minutes.
  ///
  /// In ar, this message translates to:
  /// **'{n} د'**
  String guide_weeklyPrep_minutes(int n);

  /// No description provided for @guide_weeklyPrep_validDays.
  ///
  /// In ar, this message translates to:
  /// **'صالح {n} يوم'**
  String guide_weeklyPrep_validDays(int n);

  /// No description provided for @guide_weeklyPrep_weekOf.
  ///
  /// In ar, this message translates to:
  /// **'أسبوع {day} {month}'**
  String guide_weeklyPrep_weekOf(int day, String month);

  /// No description provided for @mealBanks_intro.
  ///
  /// In ar, this message translates to:
  /// **'أفكار وجبات مرتّبة حسب الوقت — اختر فكرة، اقرأ التفاصيل، ثم صوّرها لتُسجَّل.'**
  String get mealBanks_intro;

  /// No description provided for @mealBanks_composition.
  ///
  /// In ar, this message translates to:
  /// **'التكوين'**
  String get mealBanks_composition;

  /// No description provided for @mealBanks_note.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة'**
  String get mealBanks_note;

  /// No description provided for @mealBanks_capture.
  ///
  /// In ar, this message translates to:
  /// **'صوّر هذه الوجبة'**
  String get mealBanks_capture;

  /// No description provided for @program_phases_title.
  ///
  /// In ar, this message translates to:
  /// **'مراحل الرحلة'**
  String get program_phases_title;

  /// No description provided for @program_start.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ البرنامج اليوم'**
  String get program_start;

  /// No description provided for @program_stop.
  ///
  /// In ar, this message translates to:
  /// **'أوقف البرنامج'**
  String get program_stop;

  /// No description provided for @program_restart.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ من جديد'**
  String get program_restart;

  /// No description provided for @program_currentDay.
  ///
  /// In ar, this message translates to:
  /// **'اليوم الحالي'**
  String get program_currentDay;

  /// No description provided for @program_completed_badge.
  ///
  /// In ar, this message translates to:
  /// **'اكتمل'**
  String get program_completed_badge;

  /// No description provided for @program_dayHeader.
  ///
  /// In ar, this message translates to:
  /// **'اليوم {n}'**
  String program_dayHeader(String n);

  /// No description provided for @program_suggestedMeal.
  ///
  /// In ar, this message translates to:
  /// **'وجبة مقترحة'**
  String get program_suggestedMeal;

  /// No description provided for @program_dailyTip.
  ///
  /// In ar, this message translates to:
  /// **'نصيحة اليوم'**
  String get program_dailyTip;

  /// No description provided for @program_captureToday.
  ///
  /// In ar, this message translates to:
  /// **'صوّر وجبة اليوم'**
  String get program_captureToday;

  /// No description provided for @program_completed_title.
  ///
  /// In ar, this message translates to:
  /// **'أكملت البرنامج 🎉'**
  String get program_completed_title;

  /// No description provided for @program_completed_body.
  ///
  /// In ar, this message translates to:
  /// **'اعرف الآن أي وجبات تعطيك راحة وشبعاً بدون ثقل. كرّر أفضل ٥ منها كقاعدة لك.'**
  String get program_completed_body;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
