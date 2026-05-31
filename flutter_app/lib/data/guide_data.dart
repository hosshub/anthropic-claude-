import 'package:flutter/material.dart';

/// قاعدة ذهبية واحدة (من ست).
class GoldenRule {
  final int id;
  final String ruleAr;
  final String applicationAr;
  final IconData icon;
  const GoldenRule({
    required this.id,
    required this.ruleAr,
    required this.applicationAr,
    required this.icon,
  });
}

/// بطاقة فلسفة (من ثلاث في صفحة الفلسفة).
class PhilosophyCard {
  final int id;
  final String titleAr;
  final String bodyAr;
  const PhilosophyCard({
    required this.id,
    required this.titleAr,
    required this.bodyAr,
  });
}

/// مهمّة في قائمة التحضير الأسبوعي.
class WeeklyPrepTask {
  final String id;
  final String titleAr;
  final int? estimatedMinutes;
  final int validDays;
  final String category;
  const WeeklyPrepTask({
    required this.id,
    required this.titleAr,
    this.estimatedMinutes,
    required this.validDays,
    required this.category,
  });
}

/// خطأ شائع + تصحيحه.
class CommonMistake {
  final String mistakeAr;
  final String correctionAr;
  const CommonMistake({
    required this.mistakeAr,
    required this.correctionAr,
  });
}

/// مجموعة داخل منطقة. خضراء/حمراء تستخدم categoryAr + items؛
/// الصفراء تستخدم itemAr + examplesAr + guidanceAr.
class ZoneGroup {
  final String? categoryAr;
  final List<String>? items;
  final String? itemAr;
  final String? examplesAr;
  final String? guidanceAr;
  const ZoneGroup({
    this.categoryAr,
    this.items,
    this.itemAr,
    this.examplesAr,
    this.guidanceAr,
  });
}

class ZoneData {
  final String labelAr;
  final String subtitleAr;
  final String? watchwordAr;
  final List<ZoneGroup> groups;
  const ZoneData({
    required this.labelAr,
    required this.subtitleAr,
    this.watchwordAr,
    required this.groups,
  });
}

/// كل بيانات الدليل ساكنة — نفس محتوى tayyibat_rules.json (v2) في iOS.
class GuideData {
  static const String medicalDisclaimer =
      'هذا الدليل تثقيفي وتنظيمي، وليس بديلاً عن الطبيب أو أخصائي التغذية. '
      'لا توقف أي علاج أو دواء بسبب نظام غذائي دون الرجوع لطبيبك، خصوصاً مع الأمراض '
      'المزمنة، الحمل، الرضاعة، الأطفال، أو كبار السن.';

  static const ZoneData greenZone = ZoneData(
    labelAr: 'أخضر',
    subtitleAr: 'أساس النظام، تُبنى عليه أغلب الوجبات',
    groups: [
      ZoneGroup(categoryAr: 'النشويات البسيطة', items: [
        'الأرز الأبيض', 'الأرز البسمتي', 'البطاطس',
      ]),
      ZoneGroup(categoryAr: 'البروتينات الأساسية', items: [
        'اللحم الأحمر', 'الكبدة', 'الكوارع', 'لحم الأرنب',
        'بعض الأسماك', 'الحمام', 'السمان',
      ]),
      ZoneGroup(categoryAr: 'الدهون الطبيعية', items: [
        'السمن البلدي', 'الزبدة الطبيعية', 'زيت الزيتون', 'الزيتون',
      ]),
      ZoneGroup(categoryAr: 'إضافات بسيطة', items: [
        'التمر (كمية محسوبة)', 'العسل الطبيعي (كمية محسوبة)',
      ]),
      ZoneGroup(categoryAr: 'مشروبات أساسية', items: [
        'الماء', 'مشروبات بسيطة حسب التحمل',
      ]),
    ],
  );

  static const ZoneData yellowZone = ZoneData(
    labelAr: 'أصفر',
    subtitleAr: 'بحساب، وليس مفتوحاً بلا حدود',
    watchwordAr: 'جرّب، راقب، وقلّل عند ظهور ثقل أو اضطراب هضمي',
    groups: [
      ZoneGroup(
        itemAr: 'الأجبان المعتقة',
        examplesAr: 'شيدر، جودة، بارميزان، روكفور، فلمنك',
        guidanceAr: 'باعتدال وحسب الهضم',
      ),
      ZoneGroup(
        itemAr: 'الفواكه الطبيعية',
        examplesAr:
            'التفاح، الكمثرى، المانجو، الجوافة، الرمان، الفراولة، التين، العنب، الموز',
        guidanceAr: 'تدخل تدريجياً مع مراقبة الانتفاخ أو الخمول',
      ),
      ZoneGroup(
        itemAr: 'العسل والتمر',
        guidanceAr: 'كميات بسيطة، وليس استخداماً مفتوحاً طوال اليوم',
      ),
      ZoneGroup(
        itemAr: 'القهوة',
        guidanceAr: 'حسب النوم والتوتر وتحمل الكافيين',
      ),
      ZoneGroup(
        itemAr: 'الشاي',
        guidanceAr: 'ليس أساساً. إن وُجد يكون بسيطاً وبسكر خفيف',
      ),
    ],
  );

  static const ZoneData redZone = ZoneData(
    labelAr: 'أحمر',
    subtitleAr: 'ممنوع تماماً في هذه النسخة',
    groups: [
      ZoneGroup(categoryAr: 'الدواجن والبيض', items: [
        'الفراخ', 'الديك الرومي', 'البط', 'الطيور التجارية', 'البيض بجميع أشكاله',
      ]),
      ZoneGroup(categoryAr: 'الحليب ومشتقاته العادية', items: [
        'الحليب', 'الزبادي', 'اللبن الرائب', 'القشطة', 'منتجات الألبان العادية',
      ]),
      ZoneGroup(categoryAr: 'البقوليات', items: [
        'الفول', 'العدس', 'الحمص', 'الفاصوليا', 'اللوبيا', 'البازلاء',
      ]),
      ZoneGroup(categoryAr: 'الأطعمة فائقة التصنيع', items: [
        'الوجبات السريعة', 'المنتجات الجاهزة', 'المشروبات الغازية',
      ]),
      ZoneGroup(categoryAr: 'الزيوت الصناعية', items: [
        'الزيوت المهدرجة', 'الزيوت كثيرة المعالجة',
      ]),
      ZoneGroup(categoryAr: 'الإضافات الجاهزة', items: [
        'الصوصات', 'الخلطات الجاهزة', 'المنتجات كثيرة المكونات',
      ]),
    ],
  );

  static const List<GoldenRule> goldenRules = [
    GoldenRule(
      id: 1,
      ruleAr: 'الأكل عند الجوع الحقيقي',
      applicationAr: 'لا تأكل بسبب الملل أو التوتر أو العادة',
      icon: Icons.local_fire_department,
    ),
    GoldenRule(
      id: 2,
      ruleAr: 'التوقف قبل الامتلاء',
      applicationAr: 'الشبع المريح أهم من التخمة',
      icon: Icons.balance,
    ),
    GoldenRule(
      id: 3,
      ruleAr: 'تقليل السناكات',
      applicationAr: 'اترك للجهاز الهضمي وقت راحة بين الوجبات',
      icon: Icons.access_time,
    ),
    GoldenRule(
      id: 4,
      ruleAr: 'تبسيط مكونات الوجبة',
      applicationAr: 'وجبة قليلة المكونات أفضل من خلطات كثيرة',
      icon: Icons.grid_view,
    ),
    GoldenRule(
      id: 5,
      ruleAr: 'مراقبة الاستجابة',
      applicationAr: 'راقب الطاقة والهضم والنوم بعد الأكل',
      icon: Icons.visibility,
    ),
    GoldenRule(
      id: 6,
      ruleAr: 'الاستمرارية قبل المثالية',
      applicationAr: 'النظام الذي تستطيع الاستمرار عليه هو الأقوى',
      icon: Icons.all_inclusive,
    ),
  ];

  static const List<PhilosophyCard> philosophyCards = [
    PhilosophyCard(
      id: 1,
      titleAr: '٠١ — الفكرة ليست الكمال',
      bodyAr: 'الهدف أن يكون الأكل أبسط، أوضح، وأكثر قابلية للاستمرار.',
    ),
    PhilosophyCard(
      id: 2,
      titleAr: '٠٢ — راقب جسمك',
      bodyAr: 'الهضم، الطاقة، النوم، الشبع، والثقل بعد الأكل كلها إشارات مهمة.',
    ),
    PhilosophyCard(
      id: 3,
      titleAr: '٠٣ — التدرّج مهم',
      bodyAr: 'ابدأ خطوة خطوة، ولا تغيّر كل شيء مرة واحدة حتى لا تفشل سريعاً.',
    ),
  ];

  static const List<WeeklyPrepTask> weeklyPrep = [
    WeeklyPrepTask(
      id: 'prep-potatoes',
      titleAr: 'حضّر بطاطس مسلوقة أو مشوية',
      estimatedMinutes: 30,
      validDays: 4,
      category: 'starch',
    ),
    WeeklyPrepTask(
      id: 'prep-rice',
      titleAr: 'اطبخ كمية أرز تكفي يومين',
      estimatedMinutes: 25,
      validDays: 2,
      category: 'starch',
    ),
    WeeklyPrepTask(
      id: 'prep-protein',
      titleAr: 'جهّز بروتيناً مناسباً مسبقاً (لحم/كبدة/سمك)',
      estimatedMinutes: 40,
      validDays: 3,
      category: 'protein',
    ),
    WeeklyPrepTask(
      id: 'stock-tamr-honey',
      titleAr: 'احتفظ بتمر وعسل طبيعي بكميات محسوبة',
      estimatedMinutes: 5,
      validDays: 14,
      category: 'pantry',
    ),
    WeeklyPrepTask(
      id: 'remove-sauces',
      titleAr: 'امنع الصوصات والخلطات الجاهزة من البيت',
      estimatedMinutes: 10,
      validDays: 30,
      category: 'kitchen',
    ),
    WeeklyPrepTask(
      id: 'repeat-best-5',
      titleAr: 'كرّر أفضل ٥ وجبات مريحة لجسمك',
      validDays: 7,
      category: 'planning',
    ),
  ];

  static const List<CommonMistake> commonMistakes = [
    CommonMistake(
      mistakeAr: 'أكل كميات ضخمة لأن الأكل مسموح',
      correctionAr: 'المسموح له حدود، والشبع المريح هو الهدف',
    ),
    CommonMistake(
      mistakeAr: 'الدخول بعنف في كل القواعد',
      correctionAr: 'ابدأ تدريجياً لتستمر',
    ),
    CommonMistake(
      mistakeAr: 'تحويل النظام لوصفات معقدة',
      correctionAr: 'الأصل: مكونات قليلة وطهي بسيط',
    ),
    CommonMistake(
      mistakeAr: 'تجاهل أعراض الجسم',
      correctionAr: 'راقب الهضم والطاقة والنوم',
    ),
    CommonMistake(
      mistakeAr: 'استخدام النظام كبديل علاجي',
      correctionAr: 'لا يغني عن الطبيب عند الحاجة',
    ),
    CommonMistake(
      mistakeAr: 'ترك الشاي مفتوحاً طوال اليوم',
      correctionAr: 'ليس أساسياً، وإن وُجد يكون محدوداً وبسكر خفيف',
    ),
  ];
}

/// تحويل التصنيف الإنجليزي لاسم عربي.
String weeklyCategoryLabel(String raw) {
  switch (raw) {
    case 'starch':
      return 'نشويات';
    case 'protein':
      return 'بروتين';
    case 'pantry':
      return 'مؤن';
    case 'kitchen':
      return 'المطبخ';
    case 'planning':
      return 'تخطيط';
    default:
      return raw;
  }
}
