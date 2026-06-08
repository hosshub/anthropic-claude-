import 'package:flutter/material.dart';

String _pick(String locale, String ar, String en) => locale == 'en' ? en : ar;

/// مرحلة من برنامج ١٥ يوم.
class ProgramPhase {
  final int number;
  final String daysRangeAr;
  final String daysRangeEn;
  final int startDay;
  final int endDay;
  final String titleAr;
  final String titleEn;
  final String focusAr;
  final String focusEn;
  final Color color;
  const ProgramPhase({
    required this.number,
    required this.daysRangeAr,
    required this.daysRangeEn,
    required this.startDay,
    required this.endDay,
    required this.titleAr,
    required this.titleEn,
    required this.focusAr,
    required this.focusEn,
    required this.color,
  });

  bool contains(int day) => day >= startDay && day <= endDay;

  String daysRange(String locale) => _pick(locale, daysRangeAr, daysRangeEn);
  String title(String locale) => _pick(locale, titleAr, titleEn);
  String focus(String locale) => _pick(locale, focusAr, focusEn);
}

/// يوم واحد من البرنامج.
class ProgramDay {
  final int day;
  final String focusAr;
  final String focusEn;
  final String exampleMealAr;
  final String exampleMealEn;
  final String tipAr;
  final String tipEn;
  const ProgramDay({
    required this.day,
    required this.focusAr,
    required this.focusEn,
    required this.exampleMealAr,
    required this.exampleMealEn,
    required this.tipAr,
    required this.tipEn,
  });

  String focus(String locale) => _pick(locale, focusAr, focusEn);
  String exampleMeal(String locale) =>
      _pick(locale, exampleMealAr, exampleMealEn);
  String tip(String locale) => _pick(locale, tipAr, tipEn);
}

/// حالة المستخدم في البرنامج.
sealed class ProgramStatus {
  const ProgramStatus();
}

class NotStarted extends ProgramStatus {
  const NotStarted();
}

class InProgress extends ProgramStatus {
  final int day; // 1..15
  const InProgress(this.day);
}

class Completed extends ProgramStatus {
  const Completed();
}

class ProgramData {
  static String title(String locale) => locale == 'en'
      ? '15-day program — the journey, not a rigid schedule'
      : 'برنامج ١٥ يوم — الرحلة بدل الجدول الممل';
  static String philosophy(String locale) => locale == 'en'
      ? "Not a rigid schedule, but a gradual journey. Each phase builds on the one before it."
      : 'ليس جدولاً جامداً، بل رحلة تدريجية. كل مرحلة تبني على ما قبلها.';

  static const List<ProgramPhase> phases = [
    ProgramPhase(
      number: 1,
      daysRangeAr: 'الأيام ١–٣',
      daysRangeEn: 'Days 1–3',
      startDay: 1,
      endDay: 3,
      titleAr: 'تهدئة الفوضى الغذائية',
      titleEn: 'Calming the food chaos',
      focusAr: 'وجبات بسيطة، مكونات قليلة، وتقليل المُصنّع.',
      focusEn: 'Simple meals, few ingredients, less processed.',
      color: Color(0xFFA8D5BA),
    ),
    ProgramPhase(
      number: 2,
      daysRangeAr: 'الأيام ٤–٧',
      daysRangeEn: 'Days 4–7',
      startDay: 4,
      endDay: 7,
      titleAr: 'بناء الروتين',
      titleEn: 'Building the routine',
      focusAr: 'الأكل عند الجوع الحقيقي وتقليل السناكات.',
      focusEn: 'Eating at real hunger and cutting down snacks.',
      color: Color(0xFF7FBC8C),
    ),
    ProgramPhase(
      number: 3,
      daysRangeAr: 'الأيام ٨–١١',
      daysRangeEn: 'Days 8–11',
      startDay: 8,
      endDay: 11,
      titleAr: 'تنظيم البروتين',
      titleEn: 'Organizing protein',
      focusAr: 'استخدام البروتين الحيواني بذكاء حسب الاستجابة.',
      focusEn: 'Using animal protein wisely based on body response.',
      color: Color(0xFF4F9C5F),
    ),
    ProgramPhase(
      number: 4,
      daysRangeAr: 'الأيام ١٢–١٥',
      daysRangeEn: 'Days 12–15',
      startDay: 12,
      endDay: 15,
      titleAr: 'تثبيت النظام',
      titleEn: 'Locking in the system',
      focusAr: 'معرفة الوجبات التي تعطي راحة وشبعاً بدون ثقل.',
      focusEn:
          'Identifying the meals that give comfort and fullness without heaviness.',
      color: Color(0xFF147A4A),
    ),
  ];

  static const List<ProgramDay> days = [
    ProgramDay(
      day: 1,
      focusAr: 'بداية هادئة',
      focusEn: 'A quiet start',
      exampleMealAr: 'أرز بسيط + دهون طبيعية',
      exampleMealEn: 'Simple rice + natural fats',
      tipAr: 'ابدأ بوجبة واحدة بسيطة اليوم. لا تحاول تغيير كل شيء دفعة واحدة.',
      tipEn:
          "Start with one simple meal today. Don't try to change everything at once.",
    ),
    ProgramDay(
      day: 2,
      focusAr: 'تقليل السناكات',
      focusEn: 'Cutting down snacks',
      exampleMealAr: 'بطاطس مسلوقة أو مشوية',
      exampleMealEn: 'Boiled or roasted potato',
      tipAr: 'اترك ساعتين على الأقل بين الوجبات اليوم.',
      tipEn: 'Leave at least two hours between meals today.',
    ),
    ProgramDay(
      day: 3,
      focusAr: 'مراقبة الهضم',
      focusEn: 'Watching digestion',
      exampleMealAr: 'أرز + لحم بسيط',
      exampleMealEn: 'Rice + simple meat',
      tipAr: 'بعد كل وجبة اليوم، اسأل نفسك: شعور مريح أم ثقل؟',
      tipEn: 'After every meal today, ask yourself: comfortable or heavy?',
    ),
    ProgramDay(
      day: 4,
      focusAr: 'تثبيت الجوع الحقيقي',
      focusEn: 'Locking in real hunger',
      exampleMealAr: 'بطاطس + زبدة طبيعية',
      exampleMealEn: 'Potato + natural butter',
      tipAr: 'لا تأكل اليوم إلا عند جوع واضح، ليس بسبب الوقت.',
      tipEn: "Don't eat today unless you're clearly hungry — not because of the clock.",
    ),
    ProgramDay(
      day: 5,
      focusAr: 'وجبة مشبعة',
      focusEn: 'A filling meal',
      exampleMealAr: 'أرز + كبدة',
      exampleMealEn: 'Rice + liver',
      tipAr: 'اختر وجبة واحدة تشعرك بالشبع المريح وكرّرها.',
      tipEn: 'Pick one meal that leaves you comfortably full and repeat it.',
    ),
    ProgramDay(
      day: 6,
      focusAr: 'يوم أخفّ',
      focusEn: 'A lighter day',
      exampleMealAr: 'بطاطس + زيت زيتون',
      exampleMealEn: 'Potato + olive oil',
      tipAr: 'اليوم وجبتان فقط، خفيفتان.',
      tipEn: 'Two meals only today, both light.',
    ),
    ProgramDay(
      day: 7,
      focusAr: 'مراجعة أول أسبوع',
      focusEn: 'First-week review',
      exampleMealAr: 'طبق بسيط مكرّر ومريح',
      exampleMealEn: 'A repeated, comforting simple plate',
      tipAr: 'راجع سجلك: أي وجبات أعطتك أفضل شعور؟',
      tipEn: 'Review your log: which meals left you feeling best?',
    ),
    ProgramDay(
      day: 8,
      focusAr: 'إدخال بروتين',
      focusEn: 'Bringing protein in',
      exampleMealAr: 'لحم أحمر + أرز',
      exampleMealEn: 'Red meat + rice',
      tipAr: 'ركّز على بروتين عالي الجودة اليوم.',
      tipEn: 'Focus on a high-quality protein today.',
    ),
    ProgramDay(
      day: 9,
      focusAr: 'راحة هضمية',
      focusEn: 'Digestive rest',
      exampleMealAr: 'بطاطس + مشروب بسيط',
      exampleMealEn: 'Potato + a simple drink',
      tipAr: 'اليوم يوم خفيف، أعطِ جهازك الهضمي راحة.',
      tipEn: "Today is a light day — give your digestive system a rest.",
    ),
    ProgramDay(
      day: 10,
      focusAr: 'بروتين مناسب',
      focusEn: 'Suitable protein',
      exampleMealAr: 'سمك + أرز',
      exampleMealEn: 'Fish + rice',
      tipAr: 'جرّب نوعاً مختلفاً من البروتين اليوم.',
      tipEn: 'Try a different kind of protein today.',
    ),
    ProgramDay(
      day: 11,
      focusAr: 'أكل منزلي',
      focusEn: 'Home cooking',
      exampleMealAr: 'كوارع أو لحم + أرز',
      exampleMealEn: 'Trotters or meat + rice',
      tipAr: 'لا أكل خارجي اليوم، فقط طبخ منزلي.',
      tipEn: 'No outside food today — only home cooking.',
    ),
    ProgramDay(
      day: 12,
      focusAr: 'تثبيت المسموح',
      focusEn: 'Locking in the allowed',
      exampleMealAr: 'طبقك الأفضل من الأيام السابقة',
      exampleMealEn: 'Your best plate from the previous days',
      tipAr: 'أعد تكرار الوجبة الأكثر راحة لك.',
      tipEn: 'Repeat the meal that left you most comfortable.',
    ),
    ProgramDay(
      day: 13,
      focusAr: 'تقليل التعقيد',
      focusEn: 'Reducing complexity',
      exampleMealAr: 'وجبة بمكونات أقل',
      exampleMealEn: 'A meal with fewer ingredients',
      tipAr: 'اليوم: لا تتجاوز ٣ مكونات في كل وجبة.',
      tipEn: 'Today: no more than 3 ingredients per meal.',
    ),
    ProgramDay(
      day: 14,
      focusAr: 'اختبار الاستمرارية',
      focusEn: 'Testing sustainability',
      exampleMealAr: 'وجبتان أو ثلاث حسب الجوع',
      exampleMealEn: 'Two or three meals depending on hunger',
      tipAr: 'اسمع جسمك، كم وجبة يحتاج فعلاً؟',
      tipEn: 'Listen to your body — how many meals does it actually need?',
    ),
    ProgramDay(
      day: 15,
      focusAr: 'خطة ما بعد البرنامج',
      focusEn: 'Post-program plan',
      exampleMealAr: 'اختر ٥ وجبات مريحة وكرّرها',
      exampleMealEn: 'Pick 5 comfortable meals and rotate them',
      tipAr: 'حدّد قائمتك الذهبية للأيام القادمة.',
      tipEn: 'Set your golden short-list for the days ahead.',
    ),
  ];

  static ProgramDay? day(int n) {
    for (final d in days) {
      if (d.day == n) return d;
    }
    return null;
  }

  static ProgramPhase phaseFor(int day) =>
      phases.firstWhere((p) => p.contains(day), orElse: () => phases.first);

  static ProgramStatus statusFor(DateTime? startedAt) {
    if (startedAt == null) return const NotStarted();
    final start = DateTime(startedAt.year, startedAt.month, startedAt.day);
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    final elapsed = t.difference(start).inDays + 1;
    if (elapsed < 1) return const InProgress(1);
    if (elapsed > 15) return const Completed();
    return InProgress(elapsed);
  }
}

/// تحويل أرقام لاتينية إلى عربية-هندية للعرض.
String arabicNumeral(int n) {
  const map = {
    '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤',
    '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩',
  };
  return n.toString().split('').map((c) => map[c] ?? c).join();
}

/// Locale-aware numeral: keep Latin digits for English, switch to Arabic
/// digits for Arabic to match the rest of the UI.
String localizedNumeral(int n, String locale) =>
    locale == 'en' ? n.toString() : arabicNumeral(n);
