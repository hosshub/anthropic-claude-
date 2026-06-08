import 'package:flutter/material.dart';

String _pick(String locale, String ar, String en) => locale == 'en' ? en : ar;

/// قاعدة ذهبية واحدة (من ست).
class GoldenRule {
  final int id;
  final String ruleAr;
  final String ruleEn;
  final String applicationAr;
  final String applicationEn;
  final IconData icon;
  const GoldenRule({
    required this.id,
    required this.ruleAr,
    required this.ruleEn,
    required this.applicationAr,
    required this.applicationEn,
    required this.icon,
  });

  String rule(String locale) => _pick(locale, ruleAr, ruleEn);
  String application(String locale) => _pick(locale, applicationAr, applicationEn);
}

/// بطاقة فلسفة (من ثلاث في صفحة الفلسفة).
class PhilosophyCard {
  final int id;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  const PhilosophyCard({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
  });

  String title(String locale) => _pick(locale, titleAr, titleEn);
  String body(String locale) => _pick(locale, bodyAr, bodyEn);
}

/// مهمّة في قائمة التحضير الأسبوعي.
class WeeklyPrepTask {
  final String id;
  final String titleAr;
  final String titleEn;
  final int? estimatedMinutes;
  final int validDays;
  final String category;
  const WeeklyPrepTask({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    this.estimatedMinutes,
    required this.validDays,
    required this.category,
  });

  String title(String locale) => _pick(locale, titleAr, titleEn);
}

/// خطأ شائع + تصحيحه.
class CommonMistake {
  final String mistakeAr;
  final String mistakeEn;
  final String correctionAr;
  final String correctionEn;
  const CommonMistake({
    required this.mistakeAr,
    required this.mistakeEn,
    required this.correctionAr,
    required this.correctionEn,
  });

  String mistake(String locale) => _pick(locale, mistakeAr, mistakeEn);
  String correction(String locale) => _pick(locale, correctionAr, correctionEn);
}

/// مجموعة داخل منطقة. خضراء/حمراء تستخدم category + items؛
/// الصفراء تستخدم item + examples + guidance.
class ZoneGroup {
  final String? categoryAr;
  final String? categoryEn;
  final List<String>? itemsAr;
  final List<String>? itemsEn;
  final String? itemAr;
  final String? itemEn;
  final String? examplesAr;
  final String? examplesEn;
  final String? guidanceAr;
  final String? guidanceEn;
  const ZoneGroup({
    this.categoryAr,
    this.categoryEn,
    this.itemsAr,
    this.itemsEn,
    this.itemAr,
    this.itemEn,
    this.examplesAr,
    this.examplesEn,
    this.guidanceAr,
    this.guidanceEn,
  });

  String? category(String locale) => _pickNullable(locale, categoryAr, categoryEn);
  List<String>? items(String locale) =>
      locale == 'en' ? itemsEn : itemsAr;
  String? item(String locale) => _pickNullable(locale, itemAr, itemEn);
  String? examples(String locale) => _pickNullable(locale, examplesAr, examplesEn);
  String? guidance(String locale) => _pickNullable(locale, guidanceAr, guidanceEn);
}

String? _pickNullable(String locale, String? ar, String? en) {
  if (locale == 'en') return en ?? ar;
  return ar ?? en;
}

class ZoneData {
  final String labelAr;
  final String labelEn;
  final String subtitleAr;
  final String subtitleEn;
  final String? watchwordAr;
  final String? watchwordEn;
  final List<ZoneGroup> groups;
  const ZoneData({
    required this.labelAr,
    required this.labelEn,
    required this.subtitleAr,
    required this.subtitleEn,
    this.watchwordAr,
    this.watchwordEn,
    required this.groups,
  });

  String label(String locale) => _pick(locale, labelAr, labelEn);
  String subtitle(String locale) => _pick(locale, subtitleAr, subtitleEn);
  String? watchword(String locale) =>
      _pickNullable(locale, watchwordAr, watchwordEn);
}

/// كل بيانات الدليل ساكنة — نفس محتوى tayyibat_rules.json (v2) في iOS.
class GuideData {
  static String medicalDisclaimer(String locale) => locale == 'en'
      ? 'This guide is educational and organizational, not a substitute for a '
          "doctor or dietitian. Don't stop any treatment or medication because "
          'of a diet without consulting your doctor, especially with chronic '
          'conditions, pregnancy, breastfeeding, children, or older adults.'
      : 'هذا الدليل تثقيفي وتنظيمي، وليس بديلاً عن الطبيب أو أخصائي التغذية. '
          'لا توقف أي علاج أو دواء بسبب نظام غذائي دون الرجوع لطبيبك، خصوصاً مع الأمراض '
          'المزمنة، الحمل، الرضاعة، الأطفال، أو كبار السن.';

  static const ZoneData greenZone = ZoneData(
    labelAr: 'أخضر',
    labelEn: 'Green',
    subtitleAr: 'أساس النظام، تُبنى عليه أغلب الوجبات',
    subtitleEn: 'The foundation of the system; most meals are built on these',
    groups: [
      ZoneGroup(
        categoryAr: 'النشويات البسيطة',
        categoryEn: 'Simple starches',
        itemsAr: ['الأرز الأبيض', 'الأرز البسمتي', 'البطاطس'],
        itemsEn: ['White rice', 'Basmati rice', 'Potatoes'],
      ),
      ZoneGroup(
        categoryAr: 'البروتينات الأساسية',
        categoryEn: 'Core proteins',
        itemsAr: [
          'اللحم الأحمر', 'الكبدة', 'الكوارع', 'لحم الأرنب',
          'بعض الأسماك', 'الحمام', 'السمان',
        ],
        itemsEn: [
          'Red meat', 'Liver', 'Trotters', 'Rabbit',
          'Some fish', 'Pigeon', 'Quail',
        ],
      ),
      ZoneGroup(
        categoryAr: 'الدهون الطبيعية',
        categoryEn: 'Natural fats',
        itemsAr: ['السمن البلدي', 'الزبدة الطبيعية', 'زيت الزيتون', 'الزيتون'],
        itemsEn: ['Ghee (samn baladi)', 'Natural butter', 'Olive oil', 'Olives'],
      ),
      ZoneGroup(
        categoryAr: 'إضافات بسيطة',
        categoryEn: 'Simple add-ons',
        itemsAr: ['التمر (كمية محسوبة)', 'العسل الطبيعي (كمية محسوبة)'],
        itemsEn: ['Dates (measured)', 'Natural honey (measured)'],
      ),
      ZoneGroup(
        categoryAr: 'مشروبات أساسية',
        categoryEn: 'Core beverages',
        itemsAr: ['الماء', 'مشروبات بسيطة حسب التحمل'],
        itemsEn: ['Water', 'Simple drinks per tolerance'],
      ),
    ],
  );

  static const ZoneData yellowZone = ZoneData(
    labelAr: 'أصفر',
    labelEn: 'Yellow',
    subtitleAr: 'بحساب، وليس مفتوحاً بلا حدود',
    subtitleEn: 'Measured, not unlimited',
    watchwordAr: 'جرّب، راقب، وقلّل عند ظهور ثقل أو اضطراب هضمي',
    watchwordEn: 'Try it, watch your body, and cut back if heaviness or digestive upset shows up',
    groups: [
      ZoneGroup(
        itemAr: 'الأجبان المعتقة',
        itemEn: 'Aged cheeses',
        examplesAr: 'شيدر، جودة، بارميزان، روكفور، فلمنك',
        examplesEn: 'Cheddar, gouda, parmesan, roquefort, edam',
        guidanceAr: 'باعتدال وحسب الهضم',
        guidanceEn: 'In moderation, watching digestion',
      ),
      ZoneGroup(
        itemAr: 'الفواكه الطبيعية',
        itemEn: 'Natural fruit',
        examplesAr:
            'التفاح، الكمثرى، المانجو، الجوافة، الرمان، الفراولة، التين، العنب، الموز',
        examplesEn:
            'Apple, pear, mango, guava, pomegranate, strawberry, fig, grape, banana',
        guidanceAr: 'تدخل تدريجياً مع مراقبة الانتفاخ أو الخمول',
        guidanceEn: 'Introduce gradually while watching for bloating or sluggishness',
      ),
      ZoneGroup(
        itemAr: 'العسل والتمر',
        itemEn: 'Honey and dates',
        guidanceAr: 'كميات بسيطة، وليس استخداماً مفتوحاً طوال اليوم',
        guidanceEn: 'Small amounts, not open use all day',
      ),
      ZoneGroup(
        itemAr: 'القهوة',
        itemEn: 'Coffee',
        guidanceAr: 'حسب النوم والتوتر وتحمل الكافيين',
        guidanceEn: 'Depends on sleep, stress, and caffeine tolerance',
      ),
      ZoneGroup(
        itemAr: 'الشاي',
        itemEn: 'Tea',
        guidanceAr: 'ليس أساساً. إن وُجد يكون بسيطاً وبسكر خفيف',
        guidanceEn: 'Not a staple. If used, keep it simple with light sugar',
      ),
    ],
  );

  static const ZoneData redZone = ZoneData(
    labelAr: 'أحمر',
    labelEn: 'Red',
    subtitleAr: 'ممنوع تماماً في هذه النسخة',
    subtitleEn: 'Completely avoided in this version',
    groups: [
      ZoneGroup(
        categoryAr: 'الدواجن والبيض',
        categoryEn: 'Poultry and eggs',
        itemsAr: [
          'الفراخ', 'الديك الرومي', 'البط', 'الطيور التجارية', 'البيض بجميع أشكاله',
        ],
        itemsEn: [
          'Chicken', 'Turkey', 'Duck', 'Commercial poultry', 'Eggs in any form',
        ],
      ),
      ZoneGroup(
        categoryAr: 'الحليب ومشتقاته العادية',
        categoryEn: 'Milk and ordinary dairy',
        itemsAr: [
          'الحليب', 'الزبادي', 'اللبن الرائب', 'القشطة', 'منتجات الألبان العادية',
        ],
        itemsEn: [
          'Milk', 'Yogurt', 'Cultured milk', 'Cream', 'Ordinary dairy products',
        ],
      ),
      ZoneGroup(
        categoryAr: 'البقوليات',
        categoryEn: 'Legumes',
        itemsAr: [
          'الفول', 'العدس', 'الحمص', 'الفاصوليا', 'اللوبيا', 'البازلاء',
        ],
        itemsEn: [
          'Fava beans', 'Lentils', 'Chickpeas', 'Kidney beans', 'Black-eyed peas', 'Green peas',
        ],
      ),
      ZoneGroup(
        categoryAr: 'الأطعمة فائقة التصنيع',
        categoryEn: 'Ultra-processed foods',
        itemsAr: ['الوجبات السريعة', 'المنتجات الجاهزة', 'المشروبات الغازية'],
        itemsEn: ['Fast food', 'Ready-made products', 'Soft drinks'],
      ),
      ZoneGroup(
        categoryAr: 'الزيوت الصناعية',
        categoryEn: 'Industrial oils',
        itemsAr: ['الزيوت المهدرجة', 'الزيوت كثيرة المعالجة'],
        itemsEn: ['Hydrogenated oils', 'Heavily processed oils'],
      ),
      ZoneGroup(
        categoryAr: 'الإضافات الجاهزة',
        categoryEn: 'Ready-made additions',
        itemsAr: ['الصوصات', 'الخلطات الجاهزة', 'المنتجات كثيرة المكونات'],
        itemsEn: ['Sauces', 'Pre-made mixes', 'Multi-ingredient products'],
      ),
    ],
  );

  static const List<GoldenRule> goldenRules = [
    GoldenRule(
      id: 1,
      ruleAr: 'الأكل عند الجوع الحقيقي',
      ruleEn: 'Eat at real hunger',
      applicationAr: 'لا تأكل بسبب الملل أو التوتر أو العادة',
      applicationEn: "Don't eat out of boredom, stress, or habit",
      icon: Icons.local_fire_department,
    ),
    GoldenRule(
      id: 2,
      ruleAr: 'التوقف قبل الامتلاء',
      ruleEn: 'Stop before fullness',
      applicationAr: 'الشبع المريح أهم من التخمة',
      applicationEn: 'Comfortable fullness matters more than stuffed',
      icon: Icons.balance,
    ),
    GoldenRule(
      id: 3,
      ruleAr: 'تقليل السناكات',
      ruleEn: 'Cut down on snacks',
      applicationAr: 'اترك للجهاز الهضمي وقت راحة بين الوجبات',
      applicationEn: 'Give your digestive system rest between meals',
      icon: Icons.access_time,
    ),
    GoldenRule(
      id: 4,
      ruleAr: 'تبسيط مكونات الوجبة',
      ruleEn: 'Simplify meal ingredients',
      applicationAr: 'وجبة قليلة المكونات أفضل من خلطات كثيرة',
      applicationEn: 'A few-ingredient meal beats a many-mixture one',
      icon: Icons.grid_view,
    ),
    GoldenRule(
      id: 5,
      ruleAr: 'مراقبة الاستجابة',
      ruleEn: 'Watch your response',
      applicationAr: 'راقب الطاقة والهضم والنوم بعد الأكل',
      applicationEn: 'Watch energy, digestion, and sleep after eating',
      icon: Icons.visibility,
    ),
    GoldenRule(
      id: 6,
      ruleAr: 'الاستمرارية قبل المثالية',
      ruleEn: 'Consistency before perfection',
      applicationAr: 'النظام الذي تستطيع الاستمرار عليه هو الأقوى',
      applicationEn: 'The system you can sustain is the strongest one',
      icon: Icons.all_inclusive,
    ),
  ];

  static const List<PhilosophyCard> philosophyCards = [
    PhilosophyCard(
      id: 1,
      titleAr: '٠١ — الفكرة ليست الكمال',
      titleEn: '01 — The point isn\'t perfection',
      bodyAr: 'الهدف أن يكون الأكل أبسط، أوضح، وأكثر قابلية للاستمرار.',
      bodyEn:
          'The goal is for eating to be simpler, clearer, and more sustainable.',
    ),
    PhilosophyCard(
      id: 2,
      titleAr: '٠٢ — راقب جسمك',
      titleEn: '02 — Watch your body',
      bodyAr: 'الهضم، الطاقة، النوم، الشبع، والثقل بعد الأكل كلها إشارات مهمة.',
      bodyEn:
          'Digestion, energy, sleep, fullness, and heaviness after eating are all important signals.',
    ),
    PhilosophyCard(
      id: 3,
      titleAr: '٠٣ — التدرّج مهم',
      titleEn: '03 — Gradualism matters',
      bodyAr: 'ابدأ خطوة خطوة، ولا تغيّر كل شيء مرة واحدة حتى لا تفشل سريعاً.',
      bodyEn:
          "Start step by step, don't change everything at once or you'll fail fast.",
    ),
  ];

  static const List<WeeklyPrepTask> weeklyPrep = [
    WeeklyPrepTask(
      id: 'prep-potatoes',
      titleAr: 'حضّر بطاطس مسلوقة أو مشوية',
      titleEn: 'Prep boiled or roasted potatoes',
      estimatedMinutes: 30,
      validDays: 4,
      category: 'starch',
    ),
    WeeklyPrepTask(
      id: 'prep-rice',
      titleAr: 'اطبخ كمية أرز تكفي يومين',
      titleEn: 'Cook enough rice for two days',
      estimatedMinutes: 25,
      validDays: 2,
      category: 'starch',
    ),
    WeeklyPrepTask(
      id: 'prep-protein',
      titleAr: 'جهّز بروتيناً مناسباً مسبقاً (لحم/كبدة/سمك)',
      titleEn: 'Prep a suitable protein ahead (meat / liver / fish)',
      estimatedMinutes: 40,
      validDays: 3,
      category: 'protein',
    ),
    WeeklyPrepTask(
      id: 'stock-tamr-honey',
      titleAr: 'احتفظ بتمر وعسل طبيعي بكميات محسوبة',
      titleEn: 'Keep dates and natural honey in measured quantities',
      estimatedMinutes: 5,
      validDays: 14,
      category: 'pantry',
    ),
    WeeklyPrepTask(
      id: 'remove-sauces',
      titleAr: 'امنع الصوصات والخلطات الجاهزة من البيت',
      titleEn: 'Keep ready-made sauces and mixes out of the house',
      estimatedMinutes: 10,
      validDays: 30,
      category: 'kitchen',
    ),
    WeeklyPrepTask(
      id: 'repeat-best-5',
      titleAr: 'كرّر أفضل ٥ وجبات مريحة لجسمك',
      titleEn: 'Rotate your 5 best, easiest-on-the-body meals',
      validDays: 7,
      category: 'planning',
    ),
  ];

  static const List<CommonMistake> commonMistakes = [
    CommonMistake(
      mistakeAr: 'أكل كميات ضخمة لأن الأكل مسموح',
      mistakeEn: 'Eating huge portions because the food is allowed',
      correctionAr: 'المسموح له حدود، والشبع المريح هو الهدف',
      correctionEn: 'Allowed has limits, and comfortable fullness is the goal',
    ),
    CommonMistake(
      mistakeAr: 'الدخول بعنف في كل القواعد',
      mistakeEn: 'Jumping into every rule at once',
      correctionAr: 'ابدأ تدريجياً لتستمر',
      correctionEn: 'Start gradually so you can sustain it',
    ),
    CommonMistake(
      mistakeAr: 'تحويل النظام لوصفات معقدة',
      mistakeEn: 'Turning the system into complicated recipes',
      correctionAr: 'الأصل: مكونات قليلة وطهي بسيط',
      correctionEn: 'The default: few ingredients and simple cooking',
    ),
    CommonMistake(
      mistakeAr: 'تجاهل أعراض الجسم',
      mistakeEn: 'Ignoring body symptoms',
      correctionAr: 'راقب الهضم والطاقة والنوم',
      correctionEn: 'Watch digestion, energy, and sleep',
    ),
    CommonMistake(
      mistakeAr: 'استخدام النظام كبديل علاجي',
      mistakeEn: 'Using the system as a medical substitute',
      correctionAr: 'لا يغني عن الطبيب عند الحاجة',
      correctionEn: 'Does not replace a doctor when needed',
    ),
    CommonMistake(
      mistakeAr: 'ترك الشاي مفتوحاً طوال اليوم',
      mistakeEn: 'Drinking tea open-ended all day',
      correctionAr: 'ليس أساسياً، وإن وُجد يكون محدوداً وبسكر خفيف',
      correctionEn: "It's not a staple — if used, keep it limited with light sugar",
    ),
  ];
}

/// تحويل تصنيف التحضير الأسبوعي إلى نص محلّي.
String weeklyCategoryLabel(String raw, String locale) {
  if (locale == 'en') {
    switch (raw) {
      case 'starch':
        return 'Starches';
      case 'protein':
        return 'Protein';
      case 'pantry':
        return 'Pantry';
      case 'kitchen':
        return 'Kitchen';
      case 'planning':
        return 'Planning';
      default:
        return raw;
    }
  }
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
