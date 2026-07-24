// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'الطيبات';

  @override
  String get common_ok => 'حسناً';

  @override
  String get common_cancel => 'إلغاء';

  @override
  String get common_save => 'احفظ';

  @override
  String get common_delete => 'حذف';

  @override
  String get common_close => 'إغلاق';

  @override
  String get common_next => 'التالي';

  @override
  String get common_previous => 'السابق';

  @override
  String get common_yes => 'نعم';

  @override
  String get common_no => 'لا';

  @override
  String get common_done => 'تم';

  @override
  String get common_later => 'لاحقاً';

  @override
  String get common_skip => 'تخطّي';

  @override
  String get common_retry => 'حاول مجدداً';

  @override
  String get common_or => 'أو';

  @override
  String get tab_today => 'اليوم';

  @override
  String get tab_history => 'السجل';

  @override
  String get tab_guide => 'الدليل';

  @override
  String get tab_settings => 'الإعدادات';

  @override
  String get auth_signIn => 'تسجيل الدخول';

  @override
  String get auth_signUp => 'حساب جديد';

  @override
  String get auth_signInTagline => 'سجّل الدخول للمتابعة';

  @override
  String get auth_signUpTagline => 'أنشئ حساباً للبدء';

  @override
  String get auth_email => 'البريد الإلكتروني';

  @override
  String get auth_password => 'كلمة المرور (٦ أحرف فأكثر)';

  @override
  String get auth_createAccount => 'إنشاء الحساب';

  @override
  String get auth_continueWithGoogle => 'متابعة بحساب Google';

  @override
  String get auth_signInWithApple => 'تسجيل الدخول عبر Apple';

  @override
  String get auth_invalidEmail => 'بريد غير صالح';

  @override
  String get auth_passwordTooShort => 'كلمة المرور قصيرة جداً';

  @override
  String get auth_signUpEmailSent =>
      'أنشأنا حسابك. تحقّق من بريدك لتأكيد الحساب، ثم سجّل الدخول.';

  @override
  String get auth_appleCredentialFailed => 'تعذّر الحصول على بيانات Apple.';

  @override
  String get auth_appleSignInCancelled => 'أُلغي تسجيل الدخول.';

  @override
  String get analyze_dailyCapReached => 'بلغت الحد اليومي للتحليلات.';

  @override
  String analyze_failedWithCode(String code) {
    return 'تعذّر التحليل ($code).';
  }

  @override
  String get analyze_badResponse => 'استجابة غير متوقعة من الوسيط.';

  @override
  String suggest_failedWithCode(String code) {
    return 'تعذّر الطلب ($code).';
  }

  @override
  String get suggest_badResponse => 'استجابة غير متوقعة من الوسيط.';

  @override
  String get account_deleteNotDeployed =>
      'خدمة حذف الحساب غير منشورة على الخادم. أبلغ المطوّر.';

  @override
  String account_deleteFailedWithCode(String code) {
    return 'فشل حذف الحساب (رمز $code).';
  }

  @override
  String get result_captureAnother => 'صوّر وجبة أخرى';

  @override
  String get common_listSeparator => '، ';

  @override
  String common_percentValue(int value) {
    return '$value٪';
  }

  @override
  String today_greetingWithName(String greeting, String name) {
    return '$greeting، $name';
  }

  @override
  String get history_calendar_month => 'شهر';

  @override
  String get disclaimer_welcome => 'أهلاً بك في الطيبات';

  @override
  String get disclaimer_intro => 'قبل البدء، اقرأ التنبيه التالي حتى النهاية.';

  @override
  String get disclaimer_screenTitle => 'التنبيه الطبي';

  @override
  String get disclaimer_title => 'تنبيه طبي مهم';

  @override
  String get disclaimer_intro_body =>
      'تطبيق \"الطيبات\" أداة معلوماتية تساعدك على متابعة وعيك الغذائي وفق مبادئ نظام طبيعي وقفت عليها بنفسك. لا يقدّم التطبيق استشارة طبية، ولا يصف علاجاً، ولا يشخّص مرضاً، ولا يحلّ محل الطبيب أو أخصائي التغذية.';

  @override
  String get disclaimer_section_what => 'ما هذا التطبيق؟';

  @override
  String get disclaimer_section_what_body =>
      'أداة تذكير ومتابعة لأنماط أكلك، تعطيك إشارات (أخضر/أصفر/أحمر) وملخّصات لمساعدتك في الانتباه لما تأكل. الإشارات لأغراض المتابعة الذاتية فقط — لا تفسّرها على أنها حكم طبي.';

  @override
  String get disclaimer_section_whatNot => 'ما هذا التطبيق ليس به؟';

  @override
  String get disclaimer_whatNot_1 => 'لا يصف دواءً أو يطلب إيقاف أي دواء.';

  @override
  String get disclaimer_whatNot_2 => 'لا يشخّص أمراضاً ولا يقترح علاجات.';

  @override
  String get disclaimer_whatNot_3 =>
      'لا يقدّم نصيحة غذائية مخصّصة لحالتك الصحية.';

  @override
  String get disclaimer_whatNot_4 =>
      'لا يحلّ محل زيارة الطبيب أو أخصائي التغذية.';

  @override
  String get disclaimer_section_whenDoctor => 'متى يجب استشارة طبيب؟';

  @override
  String get disclaimer_section_whenDoctor_body =>
      'إذا كان لديك حالة صحية مزمنة (سكري، ضغط، أمراض كلى، أمراض قلب، حساسية غذائية، اضطرابات هضمية)، أو إذا كنتِ حاملاً أو مرضعاً، أو إذا كنت تتناول أدوية، فعليك مراجعة طبيبك قبل تغيير نظامك الغذائي بناءً على ما يعرضه هذا التطبيق.';

  @override
  String get disclaimer_section_responsibility => 'مسؤوليتك الشخصية';

  @override
  String get disclaimer_section_responsibility_body =>
      'باستخدامك التطبيق، تقرّ بأنك:';

  @override
  String get disclaimer_responsibility_1 => 'قرأت هذا التنبيه وفهمته.';

  @override
  String get disclaimer_responsibility_2 =>
      'تتحمّل المسؤولية الكاملة عن قراراتك الغذائية.';

  @override
  String get disclaimer_responsibility_3 =>
      'لن تستخدم التطبيق بديلاً عن الرعاية الطبية المتخصّصة.';

  @override
  String get disclaimer_responsibility_4 =>
      'تعفي مطوّر التطبيق من أي ضرر مباشر أو غير مباشر ينجم عن القرارات الشخصية التي تتخذها بناءً على ما يعرضه التطبيق.';

  @override
  String get disclaimer_section_data => 'بيانات وجباتك';

  @override
  String get disclaimer_section_data_body =>
      'تُحفظ صور وجباتك وملاحظاتك على جهازك بشكل أساسي. لا تُرسل بياناتك الصحية لأي طرف ثالث للتسويق. التحليل يمرّ بنموذج ذكاء اصطناعي (Gemini) عبر خادم وسيط لا يحتفظ بالصور.';

  @override
  String get disclaimer_section_emergency => 'في حالة الطوارئ';

  @override
  String get disclaimer_section_emergency_body =>
      'إذا واجهت أعراضاً صحية حادة، اتصل بخدمات الطوارئ فوراً. هذا التطبيق ليس مخصّصاً للاستخدام في الحالات الطارئة.';

  @override
  String get disclaimer_readyHint =>
      'بقراءتك حتى هنا، أنت جاهز للموافقة. يمكنك دائماً إعادة قراءة هذا التنبيه من الإعدادات.';

  @override
  String get disclaimer_scrollPrompt =>
      'مرّر القراءة حتى نهاية النص لتفعيل زر الموافقة.';

  @override
  String get disclaimer_action => 'أوافق وأتحمّل المسؤولية';

  @override
  String get onboarding_welcome_title => 'أهلاً بك في الطيبات';

  @override
  String get onboarding_welcome_body =>
      'رفيق هادئ للأكل الواعي — صوّر وجبتك واعرف موقعها من النظام.';

  @override
  String get onboarding_feature_capture_title => 'صوّر وجبتك';

  @override
  String get onboarding_feature_capture_body =>
      'يقرأ الذكاء الاصطناعي طبقك ويقيّمه وفق نظام الطيبات في ثوانٍ.';

  @override
  String get onboarding_feature_zones_title => 'ثلاث مناطق واضحة';

  @override
  String get onboarding_feature_zones_body =>
      'الأخضر أساسك، والأصفر بحساب، والأحمر يُتجنّب. بلا هوس بالسعرات.';

  @override
  String get onboarding_feature_listen_title => 'أنصت لجسدك';

  @override
  String get onboarding_feature_listen_body =>
      'سجّل شعورك بعد كل وجبة، وسيُظهر لك التطبيق ما يناسبك فعلاً.';

  @override
  String get onboarding_about_title => 'اجعله تطبيقك';

  @override
  String get onboarding_about_body =>
      'كلاهما اختياري ويبقى على جهازك — يُستخدمان لتخصيص التحية فقط.';

  @override
  String get onboarding_name_hint => 'اسمك';

  @override
  String get onboarding_age_hint => 'عمرك';

  @override
  String get onboarding_done_title => 'كل شيء جاهز';

  @override
  String get onboarding_done_body =>
      'ابدأ من وجبتك القادمة — صوّرها وراقب الإشارة.';

  @override
  String get onboarding_start => 'ابدأ الآن';

  @override
  String get settings_name => 'الاسم';

  @override
  String get settings_firstName => 'الاسم الأول';

  @override
  String get settings_lastName => 'الاسم الأخير';

  @override
  String get settings_nickname => 'اللقب';

  @override
  String get settings_name_dialogTitle => 'اسمك';

  @override
  String get onboarding_firstName_hint => 'الاسم الأول';

  @override
  String get onboarding_lastName_hint => 'الاسم الأخير';

  @override
  String get onboarding_nickname_hint => 'اللقب (اختياري)';

  @override
  String get settings_displayName => 'الاسم المعروض';

  @override
  String get settings_displayName_dialogTitle => 'تعديل الاسم المعروض';

  @override
  String get settings_displayName_note =>
      'يظهر في تحية شاشة اليوم، ويبقى على جهازك.';

  @override
  String get settings_displayName_empty => 'غير محدد';

  @override
  String get foodBank_title => 'بنك الطعام';

  @override
  String get foodBank_searchHint => 'ابحث عن صنف أو مكوّن…';

  @override
  String get foodBank_empty => 'لا توجد أصناف تطابق بحثك.';

  @override
  String get foodBank_cat_all => 'الكل';

  @override
  String get foodBank_cat_breakfast => 'فطور';

  @override
  String get foodBank_cat_lunch => 'غداء';

  @override
  String get foodBank_cat_dinner => 'عشاء';

  @override
  String get foodBank_cat_street => 'أكل شارع';

  @override
  String get foodBank_cat_drink => 'مشروبات';

  @override
  String get foodBank_cat_sweet => 'حلويات';

  @override
  String get foodBank_log => 'سجّل هذه الوجبة';

  @override
  String get foodBank_logged => 'تم التسجيل في اليوم.';

  @override
  String get foodBank_portions => 'عدد الحصص';

  @override
  String get foodBank_approxNote => 'قيم تقريبية لحصة متوسطة.';

  @override
  String get today_logFromBank => 'سجّل من بنك الطعام';

  @override
  String get today_greetingMorning => 'صباح الخير';

  @override
  String get today_greetingEvening => 'مساء الخير';

  @override
  String get today_score => 'طيب اليوم';

  @override
  String get today_noMealsYet => 'لم تسجّل وجبات اليوم بعد';

  @override
  String today_averageToday(int avg) {
    return 'متوسط $avg٪ اليوم';
  }

  @override
  String get today_log => 'سجل اليوم';

  @override
  String get today_streakTitle => 'سلسلة التسجيل';

  @override
  String today_streakDays(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n يوم',
      many: '$n يوماً',
      few: '$n أيام',
      two: 'يومان',
      one: 'يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get today_streakKeepAlive => 'سجّل وجبة اليوم لتحافظ على سلسلتك.';

  @override
  String get today_photoYourMeal => 'صوّر وجبتك';

  @override
  String get today_suggestions => 'اقتراحات';

  @override
  String get today_fasting => 'صيام';

  @override
  String get today_whenInDoubtTooltip => 'عندما تحتار';

  @override
  String get whenInDoubt_title => 'عندما تحتار';

  @override
  String get whenInDoubt_choose => 'اختر';

  @override
  String get whenInDoubt_choose_body =>
      'أرز أو بطاطس + بروتين مناسب + دهون طبيعية.';

  @override
  String get whenInDoubt_avoid => 'امنع تماماً';

  @override
  String get whenInDoubt_avoid_body =>
      'الفراخ والبيض، الحليب ومشتقاته، البقوليات، المُصنّع، الزيوت الصناعية.';

  @override
  String get whenInDoubt_moderate => 'استخدم باعتدال';

  @override
  String get whenInDoubt_moderate_body =>
      'الأجبان المعتقة، الفاكهة، العسل، التمر، القهوة، والشاي المحدود.';

  @override
  String get whenInDoubt_watch => 'راقب';

  @override
  String get whenInDoubt_watch_body => 'الهضم، الطاقة، النوم، والشبع.';

  @override
  String get whenInDoubt_openMealBanks => 'افتح بنك الوجبات';

  @override
  String get whenInDoubt_openMealBanks_sub => 'أفكار جاهزة حسب وقت اليوم';

  @override
  String get whenInDoubt_readRules => 'اقرأ القواعد الذهبية';

  @override
  String get whenInDoubt_readRules_sub => 'ست قواعد تُبقي النظام واضحاً';

  @override
  String get whenInDoubt_photoNow => 'صوّر ما أمامك';

  @override
  String get whenInDoubt_photoNow_sub => 'نحلّل وجبتك ونعطيك الإشارة';

  @override
  String get capture_title => 'تحليل وجبة';

  @override
  String get capture_analyzingHint =>
      'يقرأ الذكاء الاصطناعي طبقك الآن — يستغرق الأمر ثوانٍ قليلة عادةً.';

  @override
  String get capture_analyzing => 'جارٍ تحليل الوجبة…';

  @override
  String get capture_hint =>
      'صوّر وجبتك أو اختر صورة من المعرض، وسنحلّلها فوراً.';

  @override
  String get capture_camera => 'التقط بالكاميرا';

  @override
  String get capture_gallery => 'اختر من المعرض';

  @override
  String get capture_unexpectedError => 'حدث خطأ غير متوقع';

  @override
  String get history_title => 'السجل';

  @override
  String get history_list => 'قائمة';

  @override
  String get history_calendar => 'تقويم';

  @override
  String get history_searchHint => 'ابحث في الوجبات…';

  @override
  String get history_searchEmpty => 'لا توجد وجبات تطابق بحثك.';

  @override
  String get history_empty_title => 'لا سجلّات بعد';

  @override
  String get history_empty_hint =>
      'صوّر أول وجبة من تبويب اليوم لتبدأ المتابعة.';

  @override
  String get history_bodyTrackingLogged => 'متابعة جسم مسجّلة';

  @override
  String get history_today => 'اليوم';

  @override
  String get history_yesterday => 'أمس';

  @override
  String get history_noMealsThatDay => 'لم تسجّل وجبات في هذا اليوم.';

  @override
  String history_mealsAvg(int count, String meals, int avg) {
    return '$count $meals • متوسط $avg٪';
  }

  @override
  String get history_mealsOne => 'وجبة';

  @override
  String get history_mealsMany => 'وجبات';

  @override
  String get history_noMealsLabel => 'بلا وجبات';

  @override
  String get mealDetail_title => 'تفاصيل الوجبة';

  @override
  String get mealDetail_items => 'العناصر';

  @override
  String get mealDetail_logBodyResponse => 'سجّل كيف شعرت بعد هذه الوجبة';

  @override
  String get mealDetail_suggestions => 'اقتراحات للتحسين';

  @override
  String get mealDetail_deleteMeal => 'حذف الوجبة';

  @override
  String get mealDetail_deleteTitle => 'حذف هذه الوجبة؟';

  @override
  String get mealDetail_deleteBody => 'سيُحذف سجل الوجبة وملاحظاتها نهائياً.';

  @override
  String get mealDetail_notFound => 'لم تعد هذه الوجبة موجودة.';

  @override
  String get mealDetail_footerDisclaimer =>
      'هذا التطبيق لا يقدّم استشارة طبية. النتائج لأغراض المتابعة فقط.';

  @override
  String get mealDetail_editedBadge => 'مُعدَّلة';

  @override
  String get mealDetail_logAgain => 'سجّل هذه الوجبة من جديد';

  @override
  String get mealDetail_logAgainDone => 'سُجّلت من جديد كوجبة جديدة.';

  @override
  String get mealDetail_editItems => 'تعديل العناصر';

  @override
  String get editItems_title => 'تعديل عناصر الوجبة';

  @override
  String get editItems_hint =>
      'صحّح اسماً خاطئاً، أو غيّر منطقة عنصر، أو احذف عنصراً أخطأ الذكاء الاصطناعي في قراءته — وتتحدّث النتيجة فوراً.';

  @override
  String get editItems_nameLabel => 'اسم العنصر';

  @override
  String get editItems_removeTooltip => 'حذف العنصر';

  @override
  String get editItems_newScore => 'النتيجة الجديدة';

  @override
  String get editItems_empty => 'تحتاج الوجبة إلى عنصر واحد على الأقل.';

  @override
  String get editItems_saved => 'تم تحديث الوجبة.';

  @override
  String get scoreBand_excellent => 'ممتاز';

  @override
  String get scoreBand_good => 'جيد';

  @override
  String get scoreBand_average => 'متوسط';

  @override
  String get scoreBand_weak => 'ضعيف';

  @override
  String get settings_title => 'الإعدادات';

  @override
  String get settings_account => 'الحساب';

  @override
  String get settings_signOut => 'تسجيل الخروج';

  @override
  String get settings_signedOut => 'تم تسجيل الخروج.';

  @override
  String get settings_deleteAccount => 'حذف الحساب';

  @override
  String get settings_deleteAccount_confirmTitle => 'حذف الحساب نهائياً؟';

  @override
  String get settings_deleteAccount_confirmBody =>
      'سيُحذف حسابك وبياناته من الخادم، وكذلك كل بيانات المتابعة على هذا الجهاز. لا يمكن التراجع.';

  @override
  String get settings_deleteAccount_successTitle => 'تم حذف حسابك';

  @override
  String get settings_deleteAccount_successBody =>
      'تم محو حسابك وبياناته من الخادم نهائياً.\n\nلو سجّلت دخولاً مجدداً ببريد Google أو Apple نفسه، فسيُنشأ حساب جديد تماماً بلا أي بيانات سابقة.';

  @override
  String settings_deleteAccount_failed(String error) {
    return 'تعذّر حذف الحساب: $error';
  }

  @override
  String get settings_reminders => 'التذكيرات';

  @override
  String get settings_notificationSettings => 'إعدادات الإشعارات';

  @override
  String get settings_safetyLegal => 'الأمان والقانون';

  @override
  String get settings_reReadDisclaimer => 'إعادة قراءة التنبيه الطبي';

  @override
  String get settings_language => 'اللغة';

  @override
  String get settings_language_arabic => 'العربية';

  @override
  String get settings_language_english => 'English';

  @override
  String get settings_about => 'حول';

  @override
  String get settings_about_body =>
      'الطيبات — تطبيق وعي غذائي. يستخدم نموذج Gemini للتحليل عبر خادم آمن. لا يقدّم استشارة طبية ولا يحلّ محل الطبيب أو أخصائي التغذية.';

  @override
  String get settings_partialEnglishNote =>
      'كل المحتوى متوفر بالعربية والإنجليزية. اللغة تطبَّق فوراً بعد التبديل.';

  @override
  String get bodyResponse_title => 'كيف شعرت بعد الوجبة؟';

  @override
  String get bodyResponse_save => 'احفظ';

  @override
  String get bodyResponse_finish => 'أنهِ';

  @override
  String bodyResponse_couldNotSave(String error) {
    return 'تعذّر الحفظ: $error';
  }

  @override
  String get bodyResponse_q1_title => 'هل شعرت بشبع مريح؟';

  @override
  String get bodyResponse_q1_h1 => 'لم أشعر بشبع';

  @override
  String get bodyResponse_q1_h2 => 'شبع خفيف';

  @override
  String get bodyResponse_q1_h3 => 'شبع مريح';

  @override
  String get bodyResponse_q1_h4 => 'شبع كامل';

  @override
  String get bodyResponse_q1_h5 => 'ممتلئ جداً';

  @override
  String get bodyResponse_q2_title => 'هل حدث انتفاخ أو ثقل؟';

  @override
  String get bodyResponse_q2_h_comfortable => 'مرتاح تماماً';

  @override
  String get bodyResponse_q2_h_lightHeavy => 'ثقل خفيف';

  @override
  String get bodyResponse_q2_h_bloating => 'انتفاخ ملحوظ';

  @override
  String get bodyResponse_q2_h_clearHeavy => 'ثقل واضح';

  @override
  String get bodyResponse_q2_h_severeHeavy => 'ثقل شديد';

  @override
  String get bodyResponse_q2_axisStart => '٠ مرتاح';

  @override
  String get bodyResponse_q2_axisEnd => '٥ ثقل شديد';

  @override
  String get bodyResponse_q3_title => 'كيف كانت طاقتك بعد الأكل؟';

  @override
  String get bodyResponse_q3_l1 => 'نعسان جداً';

  @override
  String get bodyResponse_q3_l2 => 'خامل';

  @override
  String get bodyResponse_q3_l3 => 'عادي';

  @override
  String get bodyResponse_q3_l4 => 'نشيط';

  @override
  String get bodyResponse_q3_l5 => 'نشيط جداً';

  @override
  String get bodyResponse_q4_title => 'كيف كان نومك بعد الوجبة؟';

  @override
  String get bodyResponse_q4_hint =>
      'اختياري — يمكنك تركها على \"لا أعلم\" والعودة لاحقاً.';

  @override
  String get bodyResponse_q5_title => 'هل تستحق هذه الوجبة التكرار؟';

  @override
  String get bodyResponse_q5_hint =>
      'هذه الإجابة تساعد التطبيق يقترح ما يناسب جسمك.';

  @override
  String get bodyResponse_q5_whyOptional => 'لماذا؟ (اختياري)';

  @override
  String get bodyResponse_thanks_title => 'شكراً لك';

  @override
  String get bodyResponse_thanks_body =>
      'هذه الملاحظات تساعدك تعرف جسمك أكثر، ومع الوقت يساعدك التطبيق على اقتراح ما يناسبك.';

  @override
  String get fasting_title => 'الصيام';

  @override
  String get fasting_history_empty => 'لم تسجّل أي يوم صيام بعد.';

  @override
  String get notif_title => 'الإشعارات';

  @override
  String get notif_kinds_title => 'أنواع التذكيرات';

  @override
  String get notif_grantedBanner => 'الإشعارات مفعّلة من النظام.';

  @override
  String get notif_notGrantedTitle => 'الإشعارات لم تُفعّل بعد من النظام.';

  @override
  String get notif_notGrantedBody =>
      'لتصلك التذكيرات، نحتاج إذن النظام مرة واحدة.';

  @override
  String get notif_allowButton => 'السماح بالإشعارات';

  @override
  String get notif_testButton => 'أرسل إشعار اختباري';

  @override
  String get notif_antiRepeatNote =>
      'النصائح تختلف يومياً — التطبيق يتجنّب إعادة آخر ١٠ نصائح لكل وقت حتى لا تشعر بالتكرار.';

  @override
  String error_couldNotReachServer(String error) {
    return 'تعذّر الوصول للخادم. تأكّد من اتصالك بالإنترنت. ($error)';
  }

  @override
  String get error_network =>
      'تعذّر الوصول للخادم. تأكّد من اتصالك بالإنترنت وحاول مرة أخرى.';

  @override
  String get error_unexpected => 'حدث خطأ غير متوقع. حاول مرة أخرى.';

  @override
  String get error_noSession => 'لا توجد جلسة مفتوحة.';

  @override
  String get bodyResponse_later => 'لاحقاً';

  @override
  String get bodyResponse_discardTitle => 'تجاهل الإجابات؟';

  @override
  String get bodyResponse_discardBody =>
      'لم تُحفظ بعد. هل تريد الخروج بدون حفظ متابعة الجسم؟';

  @override
  String get bodyResponse_discardConfirm => 'تجاهل';

  @override
  String bodyResponse_stepIndicator(int step, int total) {
    return '$step / $total';
  }

  @override
  String get bodyResponseCard_title => 'متابعة الجسم';

  @override
  String get bodyResponseCard_edit => 'تعديل';

  @override
  String get bodyResponseCard_satietyLabel => 'الشبع';

  @override
  String get bodyResponseCard_satietyNone => 'لا شبع';

  @override
  String get bodyResponseCard_satietyLight => 'خفيف';

  @override
  String get bodyResponseCard_satietyComfortable => 'مريح';

  @override
  String get bodyResponseCard_satietyFull => 'كامل';

  @override
  String get bodyResponseCard_satietyOverfull => 'ممتلئ جداً';

  @override
  String get bodyResponseCard_bloatingLabel => 'الانتفاخ';

  @override
  String get bodyResponseCard_bloatingComfortable => 'مرتاح';

  @override
  String get bodyResponseCard_bloatingLight => 'خفيف';

  @override
  String get bodyResponseCard_bloatingNoticeable => 'ملحوظ';

  @override
  String get bodyResponseCard_bloatingClear => 'واضح';

  @override
  String get bodyResponseCard_bloatingSevere => 'شديد';

  @override
  String get bodyResponseCard_energyLabel => 'الطاقة';

  @override
  String get bodyResponseCard_energySleepy => 'نعسان';

  @override
  String get bodyResponseCard_energySluggish => 'خامل';

  @override
  String get bodyResponseCard_energyNormal => 'عادي';

  @override
  String get bodyResponseCard_energyEnergetic => 'نشيط';

  @override
  String get bodyResponseCard_energyVeryEnergetic => 'نشيط جداً';

  @override
  String bodyResponseCard_loggedAfter(int hours) {
    return 'سُجّلت بعد $hours ساعة من الوجبة';
  }

  @override
  String get sleep_positive => 'نوم مريح';

  @override
  String get sleep_neutral => 'لم ألاحظ فرقاً';

  @override
  String get sleep_negative => 'تأثر سلباً';

  @override
  String get sleep_unknown => 'لا أعلم';

  @override
  String get worth_yes => 'نعم، أحبها';

  @override
  String get worth_maybe => 'ربما';

  @override
  String get worth_no => 'لا، تجنّبها';

  @override
  String get notif_kind_morning => 'نصيحة الصباح';

  @override
  String get notif_kind_lunch => 'تذكير الغداء';

  @override
  String get notif_kind_evening => 'نصيحة المساء';

  @override
  String get notif_kind_endOfDay => 'سجّل وجباتك';

  @override
  String get notif_kind_weeklyPrep => 'تحضير الأسبوع';

  @override
  String get notif_kind_morning_desc => 'تذكير صباحي بنصيحة من نظام الطيبات.';

  @override
  String get notif_kind_lunch_desc =>
      'تذكير بوقت الغداء وقاعدة ذهبية تختلف يومياً.';

  @override
  String get notif_kind_evening_desc => 'نصيحة المساء قبل العشاء.';

  @override
  String get notif_kind_endOfDay_desc => 'تذكير بتسجيل ما أكلت اليوم.';

  @override
  String get notif_kind_weeklyPrep_desc =>
      'كل سبت صباحاً — قائمة تحضير الأسبوع.';

  @override
  String get notif_bodyFollowup_title => 'تذكير متابعة الجسم';

  @override
  String get notif_bodyFollowup_subtitle => 'بعد ٣ ساعات من كل وجبة';

  @override
  String notif_dailyAt(String time) {
    return 'يومياً $time';
  }

  @override
  String notif_everySaturdayAt(String time) {
    return 'كل سبت $time';
  }

  @override
  String get notif_testBody =>
      'هذا إشعار اختباري. لو وصلك معناه التذكيرات شغّالة.';

  @override
  String get fasting_today => 'اليوم';

  @override
  String get fasting_fastingToday => 'أنت صائم اليوم';

  @override
  String get fasting_markFasting => 'سجّل أنني صائم اليوم';

  @override
  String get fasting_unmarkFasting => 'ألغِ تسجيل الصيام';

  @override
  String get fasting_kind_monday => 'اثنين';

  @override
  String get fasting_kind_thursday => 'خميس';

  @override
  String get fasting_kind_white13 => 'الأيام البيض — ١٣';

  @override
  String get fasting_kind_white14 => 'الأيام البيض — ١٤';

  @override
  String get fasting_kind_white15 => 'الأيام البيض — ١٥';

  @override
  String get fasting_kind_general => 'صيام تطوّع';

  @override
  String get fasting_hint_weeklyMustahab => 'مستحب لمن استطاع — رحمة لا فرض.';

  @override
  String get fasting_hint_white => 'الأيام البيض من السنن المؤكدة.';

  @override
  String get fasting_hint_general => 'يوم صيام إضافي اخترته أنت.';

  @override
  String get fasting_log => 'السجل';

  @override
  String fasting_nextSuggestion(String when) {
    return 'أقرب يوم صيام مرشّح: $when';
  }

  @override
  String get fasting_tomorrow => 'غداً';

  @override
  String fasting_inDays(int n) {
    return 'بعد $n أيام';
  }

  @override
  String get suggestions_title => 'اقتراحات ذكية';

  @override
  String get suggestions_tab_single => 'اقتراح وجبة';

  @override
  String get suggestions_tab_weekly => 'خطة الأسبوع';

  @override
  String get suggestions_single_intro =>
      'احصل على ٣ أفكار وجبات طيبة دفعة واحدة — من المنطقة الخضراء، مع لمسات صفراء بحساب، وبدون أي عنصر ممنوع.';

  @override
  String get suggestions_single_button_first => 'اقترح ٣ وجبات';

  @override
  String get suggestions_single_button_again => 'اقترح ٣ وجبات أخرى';

  @override
  String get suggestions_components => 'المكونات';

  @override
  String suggestions_optionN(int n) {
    return 'خيار $n';
  }

  @override
  String get suggestions_plan_intro =>
      'ولّد خطة وجبات لسبعة أيام مرتّبة (سبت ← جمعة) مع الفطور والغداء والعشاء لكل يوم — من الطيبات فقط.';

  @override
  String get suggestions_plan_button_first => 'ولّد خطة الأسبوع';

  @override
  String get suggestions_plan_button_again => 'ولّد خطة جديدة';

  @override
  String get plan_savedAuto =>
      'خطتك محفوظة على جهازك — أشّر على كل وجبة عند إنجازها.';

  @override
  String plan_progress(int done, int total) {
    return 'أنجزت $done من $total وجبة';
  }

  @override
  String get plan_replaceTitle => 'توليد خطة جديدة؟';

  @override
  String get plan_replaceBody => 'سيحل هذا محل خطتك الحالية وتقدّمك فيها.';

  @override
  String get plan_generate => 'ولّد';

  @override
  String get intel_title => 'كيف يتجاوب جسمك؟';

  @override
  String get intel_avgSatiety => 'متوسط الشبع';

  @override
  String get intel_avgBloating => 'معدّل الانتفاخ';

  @override
  String get intel_outOf5 => '/ ٥';

  @override
  String get intel_last30days => 'آخر ٣٠ يوماً';

  @override
  String get intel_empty =>
      'ابدأ بتسجيل متابعة الجسم بعد وجباتك حتى يعرف التطبيق ما يناسبك ويظهر أنماطك هنا.';

  @override
  String get intel_topComforting => 'وجبات أعطتك راحة وشبعاً';

  @override
  String get intel_heaviest => 'وجبات أثقلت جسمك';

  @override
  String intel_satietyBadge(int n) {
    return '$n / ٥ شبع';
  }

  @override
  String intel_bloatingBadge(int n) {
    return 'انتفاخ $n / ٥';
  }

  @override
  String get intel_sleepTitle => 'تأثير الوجبات على نومك';

  @override
  String get intel_zoneShareTitle => 'توزّع الإشارات في طبقك';

  @override
  String get intel_last7days => 'آخر ٧ أيام';

  @override
  String get intel_noDataYet => 'لا بيانات بعد';

  @override
  String intel_zonePercent(int pct, String label) {
    return '$pct٪ $label';
  }

  @override
  String get intel_zoneGreen => 'أخضر';

  @override
  String get intel_zoneYellow => 'أصفر';

  @override
  String get intel_zoneRed => 'أحمر';

  @override
  String get intel_trendTitle => 'منحنى الالتزام';

  @override
  String intel_trendAvg(int pct) {
    return 'متوسط $pct٪';
  }

  @override
  String get intel_trendSubtitle => 'آخر ٣٠ يوماً — متوسط درجة وجبات كل يوم.';

  @override
  String get intel_trendNeedMore => 'يلزم على الأقل وجبتان لرسم المنحنى.';

  @override
  String get intel_trendToday => 'اليوم';

  @override
  String get intel_trend30daysAgo => '٣٠ يوم';

  @override
  String intel_tooltipPercent(int pct) {
    return '$pct٪';
  }

  @override
  String get guide_index_title => 'الفهرس الذكي';

  @override
  String get guide_index_subtitle => 'الدليل في ١٠ أقسام';

  @override
  String get guide_section_guidebook => 'دليل الوجبات';

  @override
  String get guidebook_title => 'دليل الوجبات الكامل';

  @override
  String get guidebook_searchHint => 'ابحث عن وجبة أو مكوّن…';

  @override
  String get guidebook_empty => 'لا توجد وجبات تطابق بحثك.';

  @override
  String get guidebook_cat_all => 'الكل';

  @override
  String get guidebook_cat_breakfast => 'فطور';

  @override
  String get guidebook_cat_lunch => 'غداء';

  @override
  String get guidebook_cat_dinner => 'عشاء';

  @override
  String get guidebook_cat_snack => 'سناك';

  @override
  String get guidebook_cat_fasting => 'أيام الصيام';

  @override
  String get guidebook_components => 'المكوّنات';

  @override
  String get guidebook_prep => 'طريقة التحضير';

  @override
  String get guidebook_approxNutrition => 'تقديرات غذائية';

  @override
  String get nutrition_title => 'القيم الغذائية';

  @override
  String nutrition_kcalValue(int value) {
    return '$value سعرة';
  }

  @override
  String get nutrition_kcalUnit => 'سعرة';

  @override
  String nutrition_gramsValue(String value) {
    return '$value غ';
  }

  @override
  String get nutrition_protein => 'بروتين';

  @override
  String get nutrition_carbs => 'كارب';

  @override
  String get nutrition_fat => 'دهون';

  @override
  String get nutrition_estimateNote =>
      'تقديرات بصرية من الصورة — للوعي العام، وليست قياساً دقيقاً.';

  @override
  String get today_caloriesTitle => 'سعرات اليوم';

  @override
  String today_caloriesOf(int consumed, int goal) {
    return '$consumed / $goal سعرة';
  }

  @override
  String today_caloriesRemaining(int value) {
    return 'باقٍ $value سعرة من هدفك اليومي';
  }

  @override
  String today_caloriesOver(int value) {
    return 'تجاوزت هدفك اليومي بـ $value سعرة';
  }

  @override
  String get settings_nutrition => 'التغذية';

  @override
  String get settings_calorieGoal => 'هدف السعرات اليومي';

  @override
  String get settings_calorieGoal_dialogTitle => 'هدف السعرات اليومي';

  @override
  String get settings_calorieGoal_note =>
      'رقم مرجعي شخصي تختاره بنفسك. التطبيق لا يحسب احتياجك ولا يقدّم توصيات غذائية.';

  @override
  String get guide_section_philosophy => 'فلسفة النظام';

  @override
  String get guide_section_goldenRules => 'القواعد الذهبية';

  @override
  String get guide_section_eatingMap => 'خريطة الأكل';

  @override
  String get guide_section_forbidden => 'الممنوعات الصريحة';

  @override
  String get guide_section_plate => 'طبق الطيبات';

  @override
  String get guide_section_program15 => 'برنامج ١٥ يوم';

  @override
  String get guide_section_mealBanks => 'بنك الوجبات';

  @override
  String get guide_section_weeklyPrep => 'التحضير الأسبوعي';

  @override
  String get guide_section_mistakes => 'الأخطاء الشائعة';

  @override
  String get guide_eatingMap_zoneGreen => 'أخضر';

  @override
  String get guide_eatingMap_zoneYellow => 'أصفر';

  @override
  String get guide_eatingMap_zoneRed => 'أحمر';

  @override
  String get guide_eatingMap_verdictEat => 'كُل بثقة';

  @override
  String get guide_eatingMap_verdictModerate => 'باعتدال';

  @override
  String get guide_eatingMap_verdictAvoid => 'تجنّب';

  @override
  String get guide_eatingMap_footerGreen =>
      'هذه المنطقة هي الأساس. لا حدّ على الكميات إلا الشبع المريح.';

  @override
  String get guide_eatingMap_footerYellow =>
      'العلامة الصفراء ليست تحريماً — هي دعوة للانتباه. راقب جسمك وقلّل عند الحاجة.';

  @override
  String get guide_eatingMap_footerRed =>
      'هذه المنطقة ممنوعة في هذا النظام. عند الشك بمكوّن، افتح \"عندما تحتار\" من شاشة اليوم.';

  @override
  String get guide_plate_baseFormula => 'الصيغة الأساسية';

  @override
  String get guide_plate_formula => 'أرز أو بطاطس + بروتين مناسب + دهون طبيعية';

  @override
  String get guide_plate_starch_title => 'نشويات';

  @override
  String get guide_plate_starch_body =>
      'اختر بين الأرز أو البطاطس بأي طريقة تحبها (مسلوقة، مشوية، مقلية…).';

  @override
  String get guide_plate_protein_title => 'بروتين';

  @override
  String get guide_plate_protein_body =>
      'لحم أحمر، كبدة، كوارع، أرنب، حمام، أو سمك مستوٍ تماماً. تجنّب الدواجن والبيض.';

  @override
  String get guide_plate_fats_title => 'دهون طبيعية';

  @override
  String get guide_plate_fats_body =>
      'سمن بلدي، زبدة طبيعية، زيت زيتون، أو زيتون — باعتدال.';

  @override
  String get guide_plate_goldenRule_title => 'القاعدة الذهبية';

  @override
  String get guide_plate_goldenRule_body =>
      'بسّط مكونات الوجبة، وتوقّف قبل الامتلاء، وراقب استجابة جسمك.';

  @override
  String get guide_weeklyPrep_reset => 'تصفير الأسبوع';

  @override
  String get guide_weeklyPrep_hint =>
      'علّم كل مهمة بعد إنجازها. القائمة تتصفّر تلقائياً مع بداية كل سبت.';

  @override
  String guide_weeklyPrep_minutes(int n) {
    return '$n د';
  }

  @override
  String guide_weeklyPrep_validDays(int n) {
    return 'صالح $n يوم';
  }

  @override
  String guide_weeklyPrep_weekOf(int day, String month) {
    return 'أسبوع $day $month';
  }

  @override
  String get mealBanks_intro =>
      'أفكار وجبات مرتّبة حسب الوقت — اختر فكرة، اقرأ التفاصيل، ثم صوّرها لتُسجَّل.';

  @override
  String get mealBanks_composition => 'التكوين';

  @override
  String get mealBanks_note => 'ملاحظة';

  @override
  String get mealBanks_capture => 'صوّر هذه الوجبة';

  @override
  String get program_phases_title => 'مراحل الرحلة';

  @override
  String get program_start => 'ابدأ البرنامج اليوم';

  @override
  String get program_stop => 'أوقف البرنامج';

  @override
  String get program_restart => 'ابدأ من جديد';

  @override
  String get program_currentDay => 'اليوم الحالي';

  @override
  String get program_completed_badge => 'اكتمل';

  @override
  String program_dayHeader(String n) {
    return 'اليوم $n';
  }

  @override
  String get program_suggestedMeal => 'وجبة مقترحة';

  @override
  String get program_dailyTip => 'نصيحة اليوم';

  @override
  String get program_captureToday => 'صوّر وجبة اليوم';

  @override
  String get program_completed_title => 'أكملت البرنامج 🎉';

  @override
  String get program_completed_body =>
      'اعرف الآن أي وجبات تعطيك راحة وشبعاً بدون ثقل. كرّر أفضل ٥ منها كقاعدة لك.';
}
