import '../models/analysis_result.dart';
import '../models/body_response.dart';
import '../services/fasting_calculator.dart';
import '../services/notification_service.dart';
import 'generated/app_localizations.dart';

String sleepImpactLabel(AppLocalizations l, SleepImpact v) {
  switch (v) {
    case SleepImpact.positive:
      return l.sleep_positive;
    case SleepImpact.neutral:
      return l.sleep_neutral;
    case SleepImpact.negative:
      return l.sleep_negative;
    case SleepImpact.unknown:
      return l.sleep_unknown;
  }
}

String worthRepeatingLabel(AppLocalizations l, WorthRepeating v) {
  switch (v) {
    case WorthRepeating.yes:
      return l.worth_yes;
    case WorthRepeating.maybe:
      return l.worth_maybe;
    case WorthRepeating.no:
      return l.worth_no;
  }
}

String notifKindLabel(AppLocalizations l, NotifKind k) {
  switch (k) {
    case NotifKind.morningTip:
      return l.notif_kind_morning;
    case NotifKind.lunchReminder:
      return l.notif_kind_lunch;
    case NotifKind.eveningTip:
      return l.notif_kind_evening;
    case NotifKind.endOfDayLog:
      return l.notif_kind_endOfDay;
    case NotifKind.weeklyPrep:
      return l.notif_kind_weeklyPrep;
  }
}

String notifKindDescription(AppLocalizations l, NotifKind k) {
  switch (k) {
    case NotifKind.morningTip:
      return l.notif_kind_morning_desc;
    case NotifKind.lunchReminder:
      return l.notif_kind_lunch_desc;
    case NotifKind.eveningTip:
      return l.notif_kind_evening_desc;
    case NotifKind.endOfDayLog:
      return l.notif_kind_endOfDay_desc;
    case NotifKind.weeklyPrep:
      return l.notif_kind_weeklyPrep_desc;
  }
}

String fastingKindLabel(AppLocalizations l, FastingKind k) {
  switch (k) {
    case FastingKind.monday:
      return l.fasting_kind_monday;
    case FastingKind.thursday:
      return l.fasting_kind_thursday;
    case FastingKind.whiteDay13:
      return l.fasting_kind_white13;
    case FastingKind.whiteDay14:
      return l.fasting_kind_white14;
    case FastingKind.whiteDay15:
      return l.fasting_kind_white15;
    case FastingKind.general:
      return l.fasting_kind_general;
  }
}

String fastingKindHint(AppLocalizations l, FastingKind k) {
  switch (k) {
    case FastingKind.monday:
    case FastingKind.thursday:
      return l.fasting_hint_weeklyMustahab;
    case FastingKind.whiteDay13:
    case FastingKind.whiteDay14:
    case FastingKind.whiteDay15:
      return l.fasting_hint_white;
    case FastingKind.general:
      return l.fasting_hint_general;
  }
}

String foodZoneLabel(AppLocalizations l, FoodZone z) {
  switch (z) {
    case FoodZone.green:
      return l.intel_zoneGreen;
    case FoodZone.yellow:
      return l.intel_zoneYellow;
    case FoodZone.red:
      return l.intel_zoneRed;
  }
}
