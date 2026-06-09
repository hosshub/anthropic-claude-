import 'package:hijri/hijri_calendar.dart';

/// أنواع الصيام المرشّحة من النظام.
enum FastingKind {
  monday,       // اثنين
  thursday,     // خميس
  whiteDay13,   // الأبيض ١٣
  whiteDay14,   // الأبيض ١٤
  whiteDay15,   // الأبيض ١٥
  general,      // صيام تطوع آخر سجّله المستخدم يدوياً
}

// Locale-aware labels live in lib/l10n/enum_labels.dart (fastingKindLabel,
// fastingKindHint) — use those.

/// يحسب ما هي أنواع الصيام المرشّحة لتاريخ معيّن.
class FastingCalculator {
  /// يرجع كل الأنواع المرشّحة لذلك التاريخ (مثلاً قد يكون الإثنين = ١٣ هجري
  /// فيظهر في القائمتين). للوضوح في الواجهة نرتّبها: ميلادي ثم أبيض.
  static List<FastingKind> kindsFor(DateTime date) {
    final result = <FastingKind>[];
    if (date.weekday == DateTime.monday) result.add(FastingKind.monday);
    if (date.weekday == DateTime.thursday) result.add(FastingKind.thursday);

    final hijri = HijriCalendar.fromDate(date);
    switch (hijri.hDay) {
      case 13:
        result.add(FastingKind.whiteDay13);
        break;
      case 14:
        result.add(FastingKind.whiteDay14);
        break;
      case 15:
        result.add(FastingKind.whiteDay15);
        break;
    }
    return result;
  }

  /// مفتاح اليوم المستخدم في الجداول والتفضيلات. تنسيق yyyy-MM-dd ميلادي.
  static String dateKey(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  /// Compact Hijri label for the UI. Month names + year suffix flip with the
  /// app locale — Arabic users see "15 ذو القعدة 1447هـ", English users see
  /// "15 Dhul Qa'dah 1447 AH".
  static String hijriShort(DateTime date, [String locale = 'ar']) {
    final h = HijriCalendar.fromDate(date);
    final months = locale == 'en' ? _hijriMonthsEn : _hijriMonthsAr;
    final suffix = locale == 'en' ? ' AH' : 'هـ';
    return '${h.hDay} ${months[h.hMonth - 1]} ${h.hYear}$suffix';
  }

  static const List<String> _hijriMonthsAr = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني', 'جمادى الأولى',
    'جمادى الآخرة', 'رجب', 'شعبان', 'رمضان', 'شوال',
    'ذو القعدة', 'ذو الحجة',
  ];

  /// Common transliterations (close to ISO 233 / Library of Congress).
  static const List<String> _hijriMonthsEn = [
    'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani",
    'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', "Sha'ban",
    'Ramadan', 'Shawwal', "Dhul Qa'dah", 'Dhul Hijjah',
  ];

  /// يجد أقرب يوم صيام مرشّح في الأيام القادمة (حتى ٣٠ يوم).
  static ({DateTime date, List<FastingKind> kinds})? nextRecommended(
      DateTime from) {
    for (var i = 0; i <= 30; i++) {
      final d = DateTime(from.year, from.month, from.day + i);
      final kinds = kindsFor(d);
      if (kinds.isNotEmpty) {
        return (date: d, kinds: kinds);
      }
    }
    return null;
  }
}
