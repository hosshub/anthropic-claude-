// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tayyibat';

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_close => 'Close';

  @override
  String get common_next => 'Next';

  @override
  String get common_previous => 'Previous';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get common_done => 'Done';

  @override
  String get common_later => 'Later';

  @override
  String get common_skip => 'Skip';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_or => 'or';

  @override
  String get tab_today => 'Today';

  @override
  String get tab_history => 'History';

  @override
  String get tab_guide => 'Guide';

  @override
  String get tab_settings => 'Settings';

  @override
  String get auth_signIn => 'Sign In';

  @override
  String get auth_signUp => 'New Account';

  @override
  String get auth_signInTagline => 'Sign in to continue';

  @override
  String get auth_signUpTagline => 'Create an account to begin';

  @override
  String get auth_email => 'Email';

  @override
  String get auth_password => 'Password (6+ characters)';

  @override
  String get auth_createAccount => 'Create Account';

  @override
  String get auth_continueWithGoogle => 'Continue with Google';

  @override
  String get auth_signInWithApple => 'Sign in with Apple';

  @override
  String get auth_invalidEmail => 'Invalid email';

  @override
  String get auth_passwordTooShort => 'Password is too short';

  @override
  String get auth_signUpEmailSent =>
      'Account created. Check your email to confirm, then sign in.';

  @override
  String get auth_appleCredentialFailed =>
      'Couldn\'t get your Apple credentials.';

  @override
  String get auth_appleSignInCancelled => 'Sign-in was cancelled.';

  @override
  String get analyze_dailyCapReached => 'You\'ve hit today\'s analysis limit.';

  @override
  String analyze_failedWithCode(String code) {
    return 'Couldn\'t analyze ($code).';
  }

  @override
  String get analyze_badResponse => 'Unexpected response from the server.';

  @override
  String suggest_failedWithCode(String code) {
    return 'Request failed ($code).';
  }

  @override
  String get suggest_badResponse => 'Unexpected response from the server.';

  @override
  String get account_deleteNotDeployed =>
      'The account-deletion service isn\'t deployed on the server. Please contact the developer.';

  @override
  String account_deleteFailedWithCode(String code) {
    return 'Couldn\'t delete account (code $code).';
  }

  @override
  String get result_captureAnother => 'Capture another';

  @override
  String get common_listSeparator => ', ';

  @override
  String common_percentValue(int value) {
    return '$value%';
  }

  @override
  String today_greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get history_calendar_month => 'Month';

  @override
  String get disclaimer_welcome => 'Welcome to Tayyibat';

  @override
  String get disclaimer_intro =>
      'Before you begin, read the following notice to the end.';

  @override
  String get disclaimer_screenTitle => 'Medical Disclaimer';

  @override
  String get disclaimer_title => 'Important Medical Disclaimer';

  @override
  String get disclaimer_intro_body =>
      'Tayyibat is an informational tool that helps you track mindful eating against a natural-foods system you\'ve chosen yourself. It does not provide medical advice, prescribe treatment, diagnose any condition, or replace a doctor or dietitian.';

  @override
  String get disclaimer_section_what => 'What this app is';

  @override
  String get disclaimer_section_what_body =>
      'A reminder + tracking tool for your eating patterns. It gives you signals (green / yellow / red) and summaries to help you pay attention to what you eat. The signals are for self-tracking only — do not interpret them as a medical judgment.';

  @override
  String get disclaimer_section_whatNot => 'What this app is NOT';

  @override
  String get disclaimer_whatNot_1 =>
      'It does not prescribe medication or ask you to stop any medication.';

  @override
  String get disclaimer_whatNot_2 =>
      'It does not diagnose conditions or recommend treatments.';

  @override
  String get disclaimer_whatNot_3 =>
      'It does not provide nutrition advice tailored to your medical condition.';

  @override
  String get disclaimer_whatNot_4 =>
      'It does not replace a visit to a doctor or dietitian.';

  @override
  String get disclaimer_section_whenDoctor =>
      'When should you consult a doctor?';

  @override
  String get disclaimer_section_whenDoctor_body =>
      'If you have a chronic condition (diabetes, hypertension, kidney disease, heart disease, food allergies, digestive disorders), or if you are pregnant or breastfeeding, or if you take medications — consult your doctor before changing your diet based on what this app shows.';

  @override
  String get disclaimer_section_responsibility =>
      'Your personal responsibility';

  @override
  String get disclaimer_section_responsibility_body =>
      'By using the app, you acknowledge that you:';

  @override
  String get disclaimer_responsibility_1 =>
      'Have read and understood this notice.';

  @override
  String get disclaimer_responsibility_2 =>
      'Take full responsibility for your dietary decisions.';

  @override
  String get disclaimer_responsibility_3 =>
      'Will not use the app as a substitute for specialized medical care.';

  @override
  String get disclaimer_responsibility_4 =>
      'Release the app\'s developer from any direct or indirect harm resulting from personal decisions you make based on what the app shows.';

  @override
  String get disclaimer_section_data => 'Your meal data';

  @override
  String get disclaimer_section_data_body =>
      'Your meal photos and notes are stored primarily on your device. Your health data is not sold to any third party for marketing. Analysis passes through an AI model (Gemini) via a proxy server that does not retain the images.';

  @override
  String get disclaimer_section_emergency => 'In case of emergency';

  @override
  String get disclaimer_section_emergency_body =>
      'If you experience acute symptoms, contact emergency services immediately. This app is not intended for use in emergencies.';

  @override
  String get disclaimer_readyHint =>
      'By reading this far you\'re ready to agree. You can always re-read this notice from Settings.';

  @override
  String get disclaimer_scrollPrompt =>
      'Scroll to the end of the text to enable the agreement button.';

  @override
  String get disclaimer_action => 'I Agree and Accept Responsibility';

  @override
  String get onboarding_welcome_title => 'Welcome to Tayyibat';

  @override
  String get onboarding_welcome_body =>
      'A calm companion for mindful eating — photograph your meal and see where it stands.';

  @override
  String get onboarding_feature_capture_title => 'Photograph your meal';

  @override
  String get onboarding_feature_capture_body =>
      'AI reads your plate and scores it against the Tayyibat system in seconds.';

  @override
  String get onboarding_feature_zones_title => 'Three clear zones';

  @override
  String get onboarding_feature_zones_body =>
      'Green is your foundation, yellow is measured, red is avoided. No calorie obsession.';

  @override
  String get onboarding_feature_listen_title => 'Listen to your body';

  @override
  String get onboarding_feature_listen_body =>
      'Log how meals make you feel, and the app surfaces what truly suits you.';

  @override
  String get onboarding_about_title => 'Make it yours';

  @override
  String get onboarding_about_body =>
      'Both are optional and stay on your device — they only personalize your greeting.';

  @override
  String get onboarding_name_hint => 'Your name';

  @override
  String get onboarding_age_hint => 'Your age';

  @override
  String get onboarding_done_title => 'You\'re all set';

  @override
  String get onboarding_done_body =>
      'Start with your next meal — photograph it and watch the signal.';

  @override
  String get onboarding_start => 'Get started';

  @override
  String get settings_name => 'Name';

  @override
  String get settings_firstName => 'First name';

  @override
  String get settings_lastName => 'Last name';

  @override
  String get settings_nickname => 'Nickname';

  @override
  String get settings_name_dialogTitle => 'Your name';

  @override
  String get onboarding_firstName_hint => 'First name';

  @override
  String get onboarding_lastName_hint => 'Last name';

  @override
  String get onboarding_nickname_hint => 'Nickname (optional)';

  @override
  String get settings_displayName => 'Display name';

  @override
  String get settings_displayName_dialogTitle => 'Edit display name';

  @override
  String get settings_displayName_note =>
      'Shown in the Today greeting. Stays on your device.';

  @override
  String get settings_displayName_empty => 'Not set';

  @override
  String get foodBank_title => 'Food bank';

  @override
  String get foodBank_searchHint => 'Search dishes or ingredients…';

  @override
  String get foodBank_empty => 'No dishes match your search.';

  @override
  String get foodBank_cat_all => 'All';

  @override
  String get foodBank_cat_breakfast => 'Breakfast';

  @override
  String get foodBank_cat_lunch => 'Lunch';

  @override
  String get foodBank_cat_dinner => 'Dinner';

  @override
  String get foodBank_cat_street => 'Street food';

  @override
  String get foodBank_cat_drink => 'Drinks';

  @override
  String get foodBank_cat_sweet => 'Sweets';

  @override
  String get foodBank_log => 'Log this meal';

  @override
  String get foodBank_logged => 'Logged to today.';

  @override
  String get foodBank_portions => 'Portions';

  @override
  String get foodBank_approxNote => 'Approximate values for a medium portion.';

  @override
  String get today_logFromBank => 'Log from the food bank';

  @override
  String get today_greetingMorning => 'Good morning';

  @override
  String get today_greetingEvening => 'Good evening';

  @override
  String get today_score => 'Today\'s score';

  @override
  String get today_noMealsYet => 'No meals logged today yet';

  @override
  String today_averageToday(int avg) {
    return '$avg% average today';
  }

  @override
  String get today_log => 'Today\'s log';

  @override
  String get today_streakTitle => 'Logging streak';

  @override
  String today_streakDays(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get today_streakKeepAlive => 'Log a meal today to keep your streak.';

  @override
  String get today_photoYourMeal => 'Photograph your meal';

  @override
  String get today_suggestions => 'Suggestions';

  @override
  String get today_fasting => 'Fasting';

  @override
  String get today_whenInDoubtTooltip => 'When in doubt';

  @override
  String get whenInDoubt_title => 'When in doubt';

  @override
  String get whenInDoubt_choose => 'Choose';

  @override
  String get whenInDoubt_choose_body =>
      'Rice or potatoes + suitable protein + natural fats.';

  @override
  String get whenInDoubt_avoid => 'Avoid completely';

  @override
  String get whenInDoubt_avoid_body =>
      'Poultry and eggs, milk and its derivatives, legumes, ultra-processed foods, industrial oils.';

  @override
  String get whenInDoubt_moderate => 'Use in moderation';

  @override
  String get whenInDoubt_moderate_body =>
      'Aged cheeses, fruits, honey, dates, coffee, and limited tea.';

  @override
  String get whenInDoubt_watch => 'Watch';

  @override
  String get whenInDoubt_watch_body => 'Digestion, energy, sleep, and satiety.';

  @override
  String get whenInDoubt_openMealBanks => 'Open Meal Banks';

  @override
  String get whenInDoubt_openMealBanks_sub => 'Ideas ready by time of day';

  @override
  String get whenInDoubt_readRules => 'Read the Golden Rules';

  @override
  String get whenInDoubt_readRules_sub =>
      'Six rules that keep the system clear';

  @override
  String get whenInDoubt_photoNow => 'Photograph what\'s in front of you';

  @override
  String get whenInDoubt_photoNow_sub =>
      'We\'ll analyze your meal and give you the signal';

  @override
  String get capture_title => 'Meal Analysis';

  @override
  String get capture_analyzingHint =>
      'The AI is reading your plate — this usually takes a few seconds.';

  @override
  String get capture_analyzing => 'Analyzing the meal…';

  @override
  String get capture_hint =>
      'Photograph your meal or pick from the gallery — we\'ll analyze it instantly.';

  @override
  String get capture_camera => 'Capture with Camera';

  @override
  String get capture_gallery => 'Pick from Gallery';

  @override
  String get capture_unexpectedError => 'An unexpected error occurred';

  @override
  String get history_title => 'History';

  @override
  String get history_list => 'List';

  @override
  String get history_calendar => 'Calendar';

  @override
  String get history_searchHint => 'Search meals…';

  @override
  String get history_searchEmpty => 'No meals match your search.';

  @override
  String get history_empty_title => 'No records yet';

  @override
  String get history_empty_hint =>
      'Photograph your first meal from the Today tab to start tracking.';

  @override
  String get history_bodyTrackingLogged => 'Body tracking recorded';

  @override
  String get history_today => 'Today';

  @override
  String get history_yesterday => 'Yesterday';

  @override
  String get history_noMealsThatDay => 'No meals logged that day.';

  @override
  String history_mealsAvg(int count, String meals, int avg) {
    return '$count $meals • $avg% average';
  }

  @override
  String get history_mealsOne => 'meal';

  @override
  String get history_mealsMany => 'meals';

  @override
  String get history_noMealsLabel => 'No meals';

  @override
  String get mealDetail_title => 'Meal details';

  @override
  String get mealDetail_items => 'Items';

  @override
  String get mealDetail_logBodyResponse => 'Log how you felt after this meal';

  @override
  String get mealDetail_suggestions => 'Improvement suggestions';

  @override
  String get mealDetail_deleteMeal => 'Delete meal';

  @override
  String get mealDetail_deleteTitle => 'Delete this meal?';

  @override
  String get mealDetail_deleteBody =>
      'The meal record and notes will be permanently deleted.';

  @override
  String get mealDetail_notFound => 'This meal no longer exists.';

  @override
  String get mealDetail_footerDisclaimer =>
      'This app does not provide medical advice. Results are for tracking purposes only.';

  @override
  String get mealDetail_editedBadge => 'Edited';

  @override
  String get mealDetail_logAgain => 'Log this meal again';

  @override
  String get mealDetail_logAgainDone => 'Logged again as a new entry.';

  @override
  String get mealDetail_editItems => 'Edit items';

  @override
  String get editItems_title => 'Edit meal items';

  @override
  String get editItems_hint =>
      'Fix a wrong name, change an item\'s zone, or remove an item the AI misread — the score updates instantly.';

  @override
  String get editItems_nameLabel => 'Item name';

  @override
  String get editItems_removeTooltip => 'Remove item';

  @override
  String get editItems_newScore => 'New score';

  @override
  String get editItems_empty => 'A meal needs at least one item.';

  @override
  String get editItems_saved => 'Meal updated.';

  @override
  String get scoreBand_excellent => 'Excellent';

  @override
  String get scoreBand_good => 'Good';

  @override
  String get scoreBand_average => 'Average';

  @override
  String get scoreBand_weak => 'Weak';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_account => 'Account';

  @override
  String get settings_signOut => 'Sign Out';

  @override
  String get settings_signedOut => 'You\'ve been signed out.';

  @override
  String get settings_deleteAccount => 'Delete Account';

  @override
  String get settings_deleteAccount_confirmTitle =>
      'Delete account permanently?';

  @override
  String get settings_deleteAccount_confirmBody =>
      'Your account and its data will be deleted from the server, and all tracking data on this device. Cannot be undone.';

  @override
  String get settings_deleteAccount_successTitle =>
      'Your account has been deleted';

  @override
  String get settings_deleteAccount_successBody =>
      'Your account and data have been permanently erased from the server.\n\nIf you sign in again with the same Google or Apple email, it will be a brand-new account with no prior data.';

  @override
  String settings_deleteAccount_failed(String error) {
    return 'Could not delete account: $error';
  }

  @override
  String get settings_reminders => 'Reminders';

  @override
  String get settings_notificationSettings => 'Notification Settings';

  @override
  String get settings_safetyLegal => 'Safety & Legal';

  @override
  String get settings_reReadDisclaimer => 'Re-read Medical Disclaimer';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_language_arabic => 'العربية';

  @override
  String get settings_language_english => 'English';

  @override
  String get settings_about => 'About';

  @override
  String get settings_about_body =>
      'Tayyibat — a mindful eating app. Uses the Gemini model for analysis via a secure proxy. Does not provide medical advice and does not replace a doctor or dietitian.';

  @override
  String get settings_partialEnglishNote =>
      'All content is available in both Arabic and English. The language switch applies instantly.';

  @override
  String get bodyResponse_title => 'How did you feel after the meal?';

  @override
  String get bodyResponse_save => 'Save';

  @override
  String get bodyResponse_finish => 'Finish';

  @override
  String bodyResponse_couldNotSave(String error) {
    return 'Could not save: $error';
  }

  @override
  String get bodyResponse_q1_title => 'Did you feel comfortably full?';

  @override
  String get bodyResponse_q1_h1 => 'I didn\'t feel full';

  @override
  String get bodyResponse_q1_h2 => 'Slightly full';

  @override
  String get bodyResponse_q1_h3 => 'Comfortably full';

  @override
  String get bodyResponse_q1_h4 => 'Fully full';

  @override
  String get bodyResponse_q1_h5 => 'Overly full';

  @override
  String get bodyResponse_q2_title =>
      'Did you experience bloating or heaviness?';

  @override
  String get bodyResponse_q2_h_comfortable => 'Fully comfortable';

  @override
  String get bodyResponse_q2_h_lightHeavy => 'Slight heaviness';

  @override
  String get bodyResponse_q2_h_bloating => 'Noticeable bloating';

  @override
  String get bodyResponse_q2_h_clearHeavy => 'Clear heaviness';

  @override
  String get bodyResponse_q2_h_severeHeavy => 'Severe heaviness';

  @override
  String get bodyResponse_q2_axisStart => '0 comfortable';

  @override
  String get bodyResponse_q2_axisEnd => '5 severe heaviness';

  @override
  String get bodyResponse_q3_title => 'How was your energy after eating?';

  @override
  String get bodyResponse_q3_l1 => 'Very sleepy';

  @override
  String get bodyResponse_q3_l2 => 'Sluggish';

  @override
  String get bodyResponse_q3_l3 => 'Normal';

  @override
  String get bodyResponse_q3_l4 => 'Energetic';

  @override
  String get bodyResponse_q3_l5 => 'Very energetic';

  @override
  String get bodyResponse_q4_title => 'How was your sleep after the meal?';

  @override
  String get bodyResponse_q4_hint =>
      'Optional — leave it on \"Don\'t know\" and come back later.';

  @override
  String get bodyResponse_q5_title => 'Is this meal worth repeating?';

  @override
  String get bodyResponse_q5_hint =>
      'This helps the app suggest what suits your body.';

  @override
  String get bodyResponse_q5_whyOptional => 'Why? (optional)';

  @override
  String get bodyResponse_thanks_title => 'Thank you';

  @override
  String get bodyResponse_thanks_body =>
      'These notes help you understand your body better. Over time, the app helps suggest what suits you.';

  @override
  String get fasting_title => 'Fasting';

  @override
  String get fasting_history_empty => 'No fasting days logged yet.';

  @override
  String get notif_title => 'Notifications';

  @override
  String get notif_kinds_title => 'Reminder types';

  @override
  String get notif_grantedBanner =>
      'Notifications are enabled at the OS level.';

  @override
  String get notif_notGrantedTitle =>
      'Notifications are not enabled at the OS level yet.';

  @override
  String get notif_notGrantedBody =>
      'To receive reminders, we need one-time system permission.';

  @override
  String get notif_allowButton => 'Allow Notifications';

  @override
  String get notif_testButton => 'Send a test notification';

  @override
  String get notif_antiRepeatNote =>
      'Tips rotate daily — the app avoids repeating the last 10 tips per slot so it stays fresh.';

  @override
  String error_couldNotReachServer(String error) {
    return 'Couldn\'t reach the server. Check your connection. ($error)';
  }

  @override
  String get error_network =>
      'Couldn\'t reach the server. Check your internet connection and try again.';

  @override
  String get error_unexpected => 'Something went wrong. Please try again.';

  @override
  String get error_noSession => 'No active session.';

  @override
  String get bodyResponse_later => 'Later';

  @override
  String get bodyResponse_discardTitle => 'Discard your answers?';

  @override
  String get bodyResponse_discardBody =>
      'They aren\'t saved yet. Exit without logging body response?';

  @override
  String get bodyResponse_discardConfirm => 'Discard';

  @override
  String bodyResponse_stepIndicator(int step, int total) {
    return '$step / $total';
  }

  @override
  String get bodyResponseCard_title => 'Body response';

  @override
  String get bodyResponseCard_edit => 'Edit';

  @override
  String get bodyResponseCard_satietyLabel => 'Fullness';

  @override
  String get bodyResponseCard_satietyNone => 'Not full';

  @override
  String get bodyResponseCard_satietyLight => 'Slight';

  @override
  String get bodyResponseCard_satietyComfortable => 'Comfortable';

  @override
  String get bodyResponseCard_satietyFull => 'Full';

  @override
  String get bodyResponseCard_satietyOverfull => 'Overfull';

  @override
  String get bodyResponseCard_bloatingLabel => 'Bloating';

  @override
  String get bodyResponseCard_bloatingComfortable => 'Comfortable';

  @override
  String get bodyResponseCard_bloatingLight => 'Slight';

  @override
  String get bodyResponseCard_bloatingNoticeable => 'Noticeable';

  @override
  String get bodyResponseCard_bloatingClear => 'Clear';

  @override
  String get bodyResponseCard_bloatingSevere => 'Severe';

  @override
  String get bodyResponseCard_energyLabel => 'Energy';

  @override
  String get bodyResponseCard_energySleepy => 'Sleepy';

  @override
  String get bodyResponseCard_energySluggish => 'Sluggish';

  @override
  String get bodyResponseCard_energyNormal => 'Normal';

  @override
  String get bodyResponseCard_energyEnergetic => 'Energetic';

  @override
  String get bodyResponseCard_energyVeryEnergetic => 'Very energetic';

  @override
  String bodyResponseCard_loggedAfter(int hours) {
    return 'Logged $hours hour(s) after the meal';
  }

  @override
  String get sleep_positive => 'Restful sleep';

  @override
  String get sleep_neutral => 'No noticeable change';

  @override
  String get sleep_negative => 'Negatively affected';

  @override
  String get sleep_unknown => 'Don\'t know';

  @override
  String get worth_yes => 'Yes, I\'d repeat';

  @override
  String get worth_maybe => 'Maybe';

  @override
  String get worth_no => 'No, avoid';

  @override
  String get notif_kind_morning => 'Morning tip';

  @override
  String get notif_kind_lunch => 'Lunch reminder';

  @override
  String get notif_kind_evening => 'Evening tip';

  @override
  String get notif_kind_endOfDay => 'Log your meals';

  @override
  String get notif_kind_weeklyPrep => 'Weekly prep';

  @override
  String get notif_kind_morning_desc =>
      'A morning tip from the Tayyibat system.';

  @override
  String get notif_kind_lunch_desc =>
      'A lunchtime reminder with a daily golden rule.';

  @override
  String get notif_kind_evening_desc => 'An evening tip before dinner.';

  @override
  String get notif_kind_endOfDay_desc => 'Reminder to log what you ate today.';

  @override
  String get notif_kind_weeklyPrep_desc =>
      'Every Saturday morning — a weekly prep checklist.';

  @override
  String get notif_bodyFollowup_title => 'Body response reminder';

  @override
  String get notif_bodyFollowup_subtitle => '3 hours after each meal';

  @override
  String notif_dailyAt(String time) {
    return 'Daily at $time';
  }

  @override
  String notif_everySaturdayAt(String time) {
    return 'Every Saturday at $time';
  }

  @override
  String get notif_testBody =>
      'This is a test notification. If you see it, reminders are working.';

  @override
  String get fasting_today => 'Today';

  @override
  String get fasting_fastingToday => 'You\'re fasting today';

  @override
  String get fasting_markFasting => 'Log that I\'m fasting today';

  @override
  String get fasting_unmarkFasting => 'Cancel fasting log';

  @override
  String get fasting_kind_monday => 'Monday';

  @override
  String get fasting_kind_thursday => 'Thursday';

  @override
  String get fasting_kind_white13 => 'White Days — 13';

  @override
  String get fasting_kind_white14 => 'White Days — 14';

  @override
  String get fasting_kind_white15 => 'White Days — 15';

  @override
  String get fasting_kind_general => 'Voluntary fast';

  @override
  String get fasting_hint_weeklyMustahab =>
      'Encouraged for those who can — a mercy, not an obligation.';

  @override
  String get fasting_hint_white => 'The White Days are an established Sunnah.';

  @override
  String get fasting_hint_general => 'An extra fasting day you chose.';

  @override
  String get fasting_log => 'Log';

  @override
  String fasting_nextSuggestion(String when) {
    return 'Next recommended fasting day: $when';
  }

  @override
  String get fasting_tomorrow => 'Tomorrow';

  @override
  String fasting_inDays(int n) {
    return 'In $n days';
  }

  @override
  String get suggestions_title => 'Smart Suggestions';

  @override
  String get suggestions_tab_single => 'Suggest a meal';

  @override
  String get suggestions_tab_weekly => 'Weekly plan';

  @override
  String get suggestions_single_intro =>
      'Get 3 Tayyib meal ideas at once — built from the green zone, with measured yellow touches, and no forbidden item.';

  @override
  String get suggestions_single_button_first => 'Suggest 3 meals';

  @override
  String get suggestions_single_button_again => 'Suggest 3 more';

  @override
  String get suggestions_components => 'Components';

  @override
  String get suggestions_anyTime => 'Any time';

  @override
  String suggestions_optionN(int n) {
    return 'Option $n';
  }

  @override
  String get suggestions_plan_intro =>
      'Generate a 7-day plan (Sat → Fri) with breakfast, lunch, and dinner for each day — Tayyibat only.';

  @override
  String get suggestions_plan_button_first => 'Generate weekly plan';

  @override
  String get suggestions_plan_button_again => 'Generate a new plan';

  @override
  String get plan_commit => 'Commit to this plan';

  @override
  String get plan_committed_note =>
      'Tracking planned vs actual since you committed.';

  @override
  String get plan_adherence_title => 'Planned vs actual';

  @override
  String get plan_adherence_sub =>
      'How closely you\'re following the plan so far.';

  @override
  String get plan_notCommitted =>
      'Commit to the plan to start tracking planned vs actual.';

  @override
  String get plan_day_done => 'On track';

  @override
  String get plan_day_missed => 'Missed';

  @override
  String get plan_day_upcoming => 'Upcoming';

  @override
  String get plan_savedAuto =>
      'Your plan is saved on this device — tick meals off as you go.';

  @override
  String plan_progress(int done, int total) {
    return '$done of $total meals done';
  }

  @override
  String get plan_replaceTitle => 'Generate a new plan?';

  @override
  String get plan_replaceBody =>
      'This will replace your current plan and its progress.';

  @override
  String get plan_generate => 'Generate';

  @override
  String get intel_title => 'How your body responds';

  @override
  String get intel_avgSatiety => 'Avg fullness';

  @override
  String get intel_avgBloating => 'Avg bloating';

  @override
  String get intel_outOf5 => '/ 5';

  @override
  String get intel_last30days => 'Last 30 days';

  @override
  String get intel_empty =>
      'Start logging body response after your meals so the app learns what suits you and your patterns show up here.';

  @override
  String get intel_topComforting => 'Meals that gave you comfort and fullness';

  @override
  String get intel_heaviest => 'Meals that weighed on you';

  @override
  String intel_satietyBadge(int n) {
    return '$n / 5 fullness';
  }

  @override
  String intel_bloatingBadge(int n) {
    return 'Bloating $n / 5';
  }

  @override
  String get intel_sleepTitle => 'How meals affected your sleep';

  @override
  String get intel_zoneShareTitle => 'Signal distribution on your plate';

  @override
  String get intel_last7days => 'Last 7 days';

  @override
  String get intel_noDataYet => 'No data yet';

  @override
  String intel_zonePercent(int pct, String label) {
    return '$pct% $label';
  }

  @override
  String get intel_zoneGreen => 'Green';

  @override
  String get intel_zoneYellow => 'Yellow';

  @override
  String get intel_zoneRed => 'Red';

  @override
  String get intel_trendTitle => 'Adherence trend';

  @override
  String intel_trendAvg(int pct) {
    return '$pct% average';
  }

  @override
  String get intel_trendSubtitle => 'Last 30 days — daily average meal score.';

  @override
  String get intel_trendNeedMore =>
      'At least two meals are needed to draw the trend.';

  @override
  String get intel_trendToday => 'Today';

  @override
  String get intel_trend30daysAgo => '30 days';

  @override
  String intel_tooltipPercent(int pct) {
    return '$pct%';
  }

  @override
  String get guide_index_title => 'Smart index';

  @override
  String get guide_index_subtitle => 'The guide in 10 sections';

  @override
  String get guide_section_guidebook => 'Meal guidebook';

  @override
  String get guidebook_title => 'Meal guidebook';

  @override
  String get guidebook_searchHint => 'Search meals or ingredients…';

  @override
  String get guidebook_empty => 'No meals match your search.';

  @override
  String get guidebook_cat_all => 'All';

  @override
  String get guidebook_cat_breakfast => 'Breakfast';

  @override
  String get guidebook_cat_lunch => 'Lunch';

  @override
  String get guidebook_cat_dinner => 'Dinner';

  @override
  String get guidebook_cat_snack => 'Snacks';

  @override
  String get guidebook_cat_fasting => 'Fasting days';

  @override
  String get guidebook_components => 'Components';

  @override
  String get guidebook_prep => 'How to prepare';

  @override
  String get guidebook_approxNutrition => 'Approximate nutrition';

  @override
  String get nutrition_title => 'Nutrition';

  @override
  String nutrition_kcalValue(int value) {
    return '$value kcal';
  }

  @override
  String get nutrition_kcalUnit => 'kcal';

  @override
  String nutrition_gramsValue(String value) {
    return '$value g';
  }

  @override
  String get nutrition_protein => 'Protein';

  @override
  String get nutrition_carbs => 'Carbs';

  @override
  String get nutrition_fat => 'Fat';

  @override
  String get nutrition_estimateNote =>
      'Visual estimates from the photo — for general awareness, not a precise measurement.';

  @override
  String get today_caloriesTitle => 'Today\'s calories';

  @override
  String today_caloriesOf(int consumed, int goal) {
    return '$consumed / $goal kcal';
  }

  @override
  String today_caloriesRemaining(int value) {
    return '$value kcal remaining of your daily goal';
  }

  @override
  String today_caloriesOver(int value) {
    return '$value kcal over your daily goal';
  }

  @override
  String get settings_nutrition => 'Nutrition';

  @override
  String get settings_calorieGoal => 'Daily calorie goal';

  @override
  String get settings_calorieGoal_dialogTitle => 'Daily calorie goal';

  @override
  String get settings_calorieGoal_note =>
      'A personal reference number you choose yourself. The app doesn\'t calculate needs or give dietary recommendations.';

  @override
  String get guide_section_philosophy => 'Philosophy';

  @override
  String get guide_section_goldenRules => 'Golden rules';

  @override
  String get guide_section_eatingMap => 'Eating map';

  @override
  String get guide_section_forbidden => 'Explicit no-list';

  @override
  String get guide_section_plate => 'The Tayyibat plate';

  @override
  String get guide_section_program15 => '15-day program';

  @override
  String get guide_section_mealBanks => 'Meal banks';

  @override
  String get guide_section_weeklyPrep => 'Weekly prep';

  @override
  String get guide_section_mistakes => 'Common mistakes';

  @override
  String get guide_eatingMap_zoneGreen => 'Green';

  @override
  String get guide_eatingMap_zoneYellow => 'Yellow';

  @override
  String get guide_eatingMap_zoneRed => 'Red';

  @override
  String get guide_eatingMap_verdictEat => 'Eat with confidence';

  @override
  String get guide_eatingMap_verdictModerate => 'In moderation';

  @override
  String get guide_eatingMap_verdictAvoid => 'Avoid';

  @override
  String get guide_eatingMap_footerGreen =>
      'This zone is the foundation. No limit on amounts beyond comfortable fullness.';

  @override
  String get guide_eatingMap_footerYellow =>
      'Yellow is not a ban — it\'s an invitation to pay attention. Watch your body and cut back when needed.';

  @override
  String get guide_eatingMap_footerRed =>
      'This zone is off-limits in this system. When in doubt about an ingredient, open \"When in doubt\" from the Today tab.';

  @override
  String get guide_plate_baseFormula => 'Base formula';

  @override
  String get guide_plate_formula =>
      'Rice or potatoes + suitable protein + natural fats';

  @override
  String get guide_plate_starch_title => 'Starches';

  @override
  String get guide_plate_starch_body =>
      'Choose between rice or potatoes any way you like (boiled, roasted, fried…).';

  @override
  String get guide_plate_protein_title => 'Protein';

  @override
  String get guide_plate_protein_body =>
      'Red meat, liver, trotters, rabbit, pigeon, or fully cooked fish. Avoid poultry and eggs.';

  @override
  String get guide_plate_fats_title => 'Natural fats';

  @override
  String get guide_plate_fats_body =>
      'Ghee, natural butter, olive oil, or olives — in moderation.';

  @override
  String get guide_plate_goldenRule_title => 'Golden rule';

  @override
  String get guide_plate_goldenRule_body =>
      'Simplify ingredients, stop before fullness, and watch your body\'s response.';

  @override
  String get guide_weeklyPrep_reset => 'Reset week';

  @override
  String get guide_weeklyPrep_hint =>
      'Tick each task once it\'s done. The checklist auto-resets every Saturday.';

  @override
  String guide_weeklyPrep_minutes(int n) {
    return '$n min';
  }

  @override
  String guide_weeklyPrep_validDays(int n) {
    return 'Lasts $n days';
  }

  @override
  String guide_weeklyPrep_weekOf(int day, String month) {
    return 'Week of $month $day';
  }

  @override
  String get mealBanks_intro =>
      'Meal ideas grouped by time of day — pick one, read the details, then capture it to log.';

  @override
  String get mealBanks_composition => 'Composition';

  @override
  String get mealBanks_note => 'Note';

  @override
  String get mealBanks_capture => 'Photograph this meal';

  @override
  String get program_phases_title => 'Journey phases';

  @override
  String get program_start => 'Start the program today';

  @override
  String get program_stop => 'Stop the program';

  @override
  String get program_restart => 'Start over';

  @override
  String get program_currentDay => 'Current day';

  @override
  String get program_completed_badge => 'Completed';

  @override
  String program_dayHeader(String n) {
    return 'Day $n';
  }

  @override
  String get program_suggestedMeal => 'Suggested meal';

  @override
  String get program_dailyTip => 'Today\'s tip';

  @override
  String get program_captureToday => 'Photograph today\'s meal';

  @override
  String get program_completed_title => 'Program complete 🎉';

  @override
  String get program_completed_body =>
      'You now know which meals leave you comfortable and full without heaviness. Repeat the best 5 as your baseline.';
}
