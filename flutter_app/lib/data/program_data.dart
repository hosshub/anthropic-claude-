import 'package:flutter/material.dart';

/// مرحلة من برنامج ١٥ يوم.
class ProgramPhase {
  final int number;
  final String daysRangeAr;
  final int startDay;
  final int endDay;
  final String titleAr;
  final String focusAr;
  final Color color;
  const ProgramPhase({
    required this.number,
    required this.daysRangeAr,
    required this.startDay,
    required this.endDay,
    required this.titleAr,
    required this.focusAr,
    required this.color,
  });

  bool contains(int day) => day >= startDay && day <= endDay;
}

/// يوم واحد من البرنامج.
class ProgramDay {
  final int day;
  final String focusAr;
  final String exampleMealAr;
  final String tipAr;
  const ProgramDay({
    required this.day,
    required this.focusAr,
    required this.exampleMealAr,
    required this.tipAr,
  });
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
  static const String titleAr = 'برنامج ١٥ يوم — الرحلة بدل الجدول الممل';
  static const String philosophyAr =
      'ليس جدولاً جامداً، بل رحلة تدريجية. كل مرحلة تبني على ما قبلها.';

  static const List<ProgramPhase> phases = [
    ProgramPhase(
      number: 1,
      daysRangeAr: 'الأيام ١–٣',
      startDay: 1,
      endDay: 3,
      titleAr: 'تهدئة الفوضى الغذائية',
      focusAr: 'وجبات بسيطة، مكونات قليلة، وتقليل المُصنّع.',
      color: Color(0xFFA8D5BA),
    ),
    ProgramPhase(
      number: 2,
      daysRangeAr: 'الأيام ٤–٧',
      startDay: 4,
      endDay: 7,
      titleAr: 'بناء الروتين',
      focusAr: 'الأكل عند الجوع الحقيقي وتقليل السناكات.',
      color: Color(0xFF7FBC8C),
    ),
    ProgramPhase(
      number: 3,
      daysRangeAr: 'الأيام ٨–١١',
      startDay: 8,
      endDay: 11,
      titleAr: 'تنظيم البروتين',
      focusAr: 'استخدام البروتين الحيواني بذكاء حسب الاستجابة.',
      color: Color(0xFF4F9C5F),
    ),
    ProgramPhase(
      number: 4,
      daysRangeAr: 'الأيام ١٢–١٥',
      startDay: 12,
      endDay: 15,
      titleAr: 'تثبيت النظام',
      focusAr: 'معرفة الوجبات التي تعطي راحة وشبعاً بدون ثقل.',
      color: Color(0xFF147A4A),
    ),
  ];

  static const List<ProgramDay> days = [
    ProgramDay(
      day: 1,
      focusAr: 'بداية هادئة',
      exampleMealAr: 'أرز بسيط + دهون طبيعية',
      tipAr: 'ابدأ بوجبة واحدة بسيطة اليوم. لا تحاول تغيير كل شيء دفعة واحدة.',
    ),
    ProgramDay(
      day: 2,
      focusAr: 'تقليل السناكات',
      exampleMealAr: 'بطاطس مسلوقة أو مشوية',
      tipAr: 'اترك ساعتين على الأقل بين الوجبات اليوم.',
    ),
    ProgramDay(
      day: 3,
      focusAr: 'مراقبة الهضم',
      exampleMealAr: 'أرز + لحم بسيط',
      tipAr: 'بعد كل وجبة اليوم، اسأل نفسك: شعور مريح أم ثقل؟',
    ),
    ProgramDay(
      day: 4,
      focusAr: 'تثبيت الجوع الحقيقي',
      exampleMealAr: 'بطاطس + زبدة طبيعية',
      tipAr: 'لا تأكل اليوم إلا عند جوع واضح، ليس بسبب الوقت.',
    ),
    ProgramDay(
      day: 5,
      focusAr: 'وجبة مشبعة',
      exampleMealAr: 'أرز + كبدة',
      tipAr: 'اختر وجبة واحدة تشعرك بالشبع المريح وكرّرها.',
    ),
    ProgramDay(
      day: 6,
      focusAr: 'يوم أخفّ',
      exampleMealAr: 'بطاطس + زيت زيتون',
      tipAr: 'اليوم وجبتان فقط، خفيفتان.',
    ),
    ProgramDay(
      day: 7,
      focusAr: 'مراجعة أول أسبوع',
      exampleMealAr: 'طبق بسيط مكرّر ومريح',
      tipAr: 'راجع سجلك: أي وجبات أعطتك أفضل شعور؟',
    ),
    ProgramDay(
      day: 8,
      focusAr: 'إدخال بروتين',
      exampleMealAr: 'لحم أحمر + أرز',
      tipAr: 'ركّز على بروتين عالي الجودة اليوم.',
    ),
    ProgramDay(
      day: 9,
      focusAr: 'راحة هضمية',
      exampleMealAr: 'بطاطس + مشروب بسيط',
      tipAr: 'اليوم يوم خفيف، أعطِ جهازك الهضمي راحة.',
    ),
    ProgramDay(
      day: 10,
      focusAr: 'بروتين مناسب',
      exampleMealAr: 'سمك + أرز',
      tipAr: 'جرّب نوعاً مختلفاً من البروتين اليوم.',
    ),
    ProgramDay(
      day: 11,
      focusAr: 'أكل منزلي',
      exampleMealAr: 'كوارع أو لحم + أرز',
      tipAr: 'لا أكل خارجي اليوم، فقط طبخ منزلي.',
    ),
    ProgramDay(
      day: 12,
      focusAr: 'تثبيت المسموح',
      exampleMealAr: 'طبقك الأفضل من الأيام السابقة',
      tipAr: 'أعد تكرار الوجبة الأكثر راحة لك.',
    ),
    ProgramDay(
      day: 13,
      focusAr: 'تقليل التعقيد',
      exampleMealAr: 'وجبة بمكونات أقل',
      tipAr: 'اليوم: لا تتجاوز ٣ مكونات في كل وجبة.',
    ),
    ProgramDay(
      day: 14,
      focusAr: 'اختبار الاستمرارية',
      exampleMealAr: 'وجبتان أو ثلاث حسب الجوع',
      tipAr: 'اسمع جسمك، كم وجبة يحتاج فعلاً؟',
    ),
    ProgramDay(
      day: 15,
      focusAr: 'خطة ما بعد البرنامج',
      exampleMealAr: 'اختر ٥ وجبات مريحة وكرّرها',
      tipAr: 'حدّد قائمتك الذهبية للأيام القادمة.',
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
