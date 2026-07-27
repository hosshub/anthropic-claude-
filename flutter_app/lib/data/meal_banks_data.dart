import '../models/analysis_result.dart';

String _pick(String locale, String ar, String en) => locale == 'en' ? en : ar;

/// عنصر داخل بنك وجبات (فكرة جاهزة).
class MealBankItem {
  final String nameAr;
  final String nameEn;
  final String compositionAr;
  final String compositionEn;
  final String? noteAr;
  final String? noteEn;
  final FoodZone zone;
  const MealBankItem({
    required this.nameAr,
    required this.nameEn,
    required this.compositionAr,
    required this.compositionEn,
    this.noteAr,
    this.noteEn,
    required this.zone,
  });

  String name(String locale) => _pick(locale, nameAr, nameEn);
  String composition(String locale) => _pick(locale, compositionAr, compositionEn);
  String? note(String locale) {
    final ar = noteAr;
    final en = noteEn;
    if (locale == 'en') return en ?? ar;
    return ar ?? en;
  }
}

/// بنك وجبات بحسب وقت اليوم.
class MealBank {
  final String emoji;
  final String titleAr;
  final String titleEn;
  final String subtitleAr;
  final String subtitleEn;
  final List<MealBankItem> items;
  const MealBank({
    required this.emoji,
    required this.titleAr,
    required this.titleEn,
    required this.subtitleAr,
    required this.subtitleEn,
    required this.items,
  });

  String title(String locale) => _pick(locale, titleAr, titleEn);
  String subtitle(String locale) => _pick(locale, subtitleAr, subtitleEn);
}

class MealBanksData {
  static const List<MealBank> banks = [
    MealBank(
      emoji: '🌅',
      titleAr: 'بنك الفطار',
      titleEn: 'Breakfast bank',
      subtitleAr: 'أفكار سريعة ومشبعة',
      subtitleEn: 'Quick, filling ideas',
      items: [
        MealBankItem(
          nameAr: 'تمر وماء',
          nameEn: 'Dates and water',
          compositionAr: 'بضع تمرات + كوب ماء',
          compositionEn: 'A few dates + a glass of water',
          noteAr: 'بسيط وسريع — مناسب عند الحاجة لطاقة خفيفة',
          noteEn: 'Simple and quick — good when you need a little energy',
          zone: FoodZone.yellow,
        ),
        MealBankItem(
          nameAr: 'بطاطس مهروسة بزبدة طبيعية',
          nameEn: 'Mashed potato with natural butter',
          compositionAr: 'بطاطس مسلوقة + زبدة بلدية',
          compositionEn: 'Boiled potato + farm butter',
          noteAr: 'فطور مشبع وبسيط المكونات',
          noteEn: 'A filling breakfast with simple ingredients',
          zone: FoodZone.green,
        ),
        MealBankItem(
          nameAr: 'أرز بسيط بالسمن',
          nameEn: 'Simple rice with ghee',
          compositionAr: 'أرز أبيض + سمن بلدي',
          compositionEn: 'White rice + ghee (samn baladi)',
          noteAr: 'للفطار المُشبع الذي يكفي حتى الغداء',
          noteEn: 'A filling breakfast that holds you to lunch',
          zone: FoodZone.green,
        ),
        MealBankItem(
          nameAr: 'توست كامل وجبنة معتقة',
          nameEn: 'Whole-grain toast and aged cheese',
          compositionAr: 'توست حبوب كاملة + جبن معتق صلب (شيدر / جودة)',
          compositionEn: 'Whole-grain toast + hard aged cheese (cheddar / gouda)',
          noteAr: 'باعتدال — من المنطقة الصفراء وحسب الهضم',
          noteEn: 'In moderation — from the yellow zone, per digestion',
          zone: FoodZone.yellow,
        ),
      ],
    ),
    MealBank(
      emoji: '🍽',
      titleAr: 'بنك الغداء',
      titleEn: 'Lunch bank',
      subtitleAr: 'أطباق رئيسية واضحة',
      subtitleEn: 'Clear, main-course plates',
      items: [
        MealBankItem(
          nameAr: 'أرز ولحم',
          nameEn: 'Rice and meat',
          compositionAr: 'أرز + لحم أحمر مستوٍ تماماً',
          compositionEn: 'Rice + fully cooked red meat',
          noteAr: null,
          noteEn: null,
          zone: FoodZone.green,
        ),
        MealBankItem(
          nameAr: 'كبدة وبطاطس',
          nameEn: 'Liver and potatoes',
          compositionAr: 'كبدة + بطاطس',
          compositionEn: 'Liver + potatoes',
          noteAr: null,
          noteEn: null,
          zone: FoodZone.green,
        ),
        MealBankItem(
          nameAr: 'سمك وأرز',
          nameEn: 'Fish and rice',
          compositionAr: 'سمك (مشوي أو مقلي) + أرز',
          compositionEn: 'Fish (grilled or fried) + rice',
          noteAr: null,
          noteEn: null,
          zone: FoodZone.green,
        ),
        MealBankItem(
          nameAr: 'كوارع أو حمام',
          nameEn: 'Trotters or pigeon',
          compositionAr: 'كوارع أو حمام مع نشوية بسيطة',
          compositionEn: 'Trotters or pigeon with a simple starch',
          noteAr: 'وجبة مشبعة لمن يحبّها',
          noteEn: 'A filling meal for those who enjoy it',
          zone: FoodZone.green,
        ),
      ],
    ),
    MealBank(
      emoji: '🌙',
      titleAr: 'بنك العشاء',
      titleEn: 'Dinner bank',
      subtitleAr: 'خفيف وواضح',
      subtitleEn: 'Light and clear',
      items: [
        MealBankItem(
          nameAr: 'بطاطس مسلوقة بزبدة',
          nameEn: 'Boiled potato with butter',
          compositionAr: 'بطاطس مسلوقة + زبدة طبيعية',
          compositionEn: 'Boiled potato + natural butter',
          noteAr: 'مناسب عند الحاجة لعشاء بسيط ومريح',
          noteEn: 'Good when you need a simple, comfortable dinner',
          zone: FoodZone.green,
        ),
        MealBankItem(
          nameAr: 'أرز خفيف',
          nameEn: 'Light rice',
          compositionAr: 'أرز أبيض بسيط مع سمن أو زيت زيتون',
          compositionEn: 'Simple white rice with ghee or olive oil',
          noteAr: 'وجبة صغيرة بدون مكونات كثيرة',
          noteEn: 'A small meal without many ingredients',
          zone: FoodZone.green,
        ),
        MealBankItem(
          nameAr: 'جبنة معتقة مع توست كامل',
          nameEn: 'Aged cheese with whole-grain toast',
          compositionAr: 'جبن معتق + توست حبوب كاملة',
          compositionEn: 'Aged cheese + whole-grain toast',
          noteAr: 'عند تحمّل الأجبان وضمن الاعتدال',
          noteEn: 'When you tolerate cheese, and in moderation',
          zone: FoodZone.yellow,
        ),
        MealBankItem(
          nameAr: 'تمر وماء',
          nameEn: 'Dates and water',
          compositionAr: 'بضع تمرات + كوب ماء',
          compositionEn: 'A few dates + a glass of water',
          noteAr: 'عند احتياج بسيط دون وجبة كبيرة',
          noteEn: 'For small hunger without a full meal',
          zone: FoodZone.yellow,
        ),
      ],
    ),
    MealBank(
      emoji: '🍯',
      titleAr: 'بنك السناك والحلويات',
      titleEn: 'Snack and sweets bank',
      subtitleAr: 'باعتدال — ليس عادة مستمرة طول اليوم',
      subtitleEn: 'In moderation — not an all-day habit',
      items: [
        MealBankItem(
          nameAr: 'تمر',
          nameEn: 'Dates',
          compositionAr: 'كمية صغيرة عند الحاجة للطاقة',
          compositionEn: 'A small amount when you need energy',
          noteAr: 'من المنطقة الصفراء — كميات بسيطة',
          noteEn: 'From the yellow zone — small amounts',
          zone: FoodZone.yellow,
        ),
        MealBankItem(
          nameAr: 'عسل طبيعي',
          nameEn: 'Natural honey',
          compositionAr: 'ملعقة صغيرة داخل وصفة أو وحده',
          compositionEn: 'A teaspoon inside a recipe or on its own',
          noteAr: 'كميات محسوبة، وليس استخداماً مفتوحاً',
          noteEn: 'Measured amounts, not open use',
          zone: FoodZone.yellow,
        ),
        MealBankItem(
          nameAr: 'فاكهة طبيعية',
          nameEn: 'Natural fruit',
          compositionAr: 'صنف واحد بالجلسة (مثلاً: تفاحة أو موزة)',
          compositionEn: 'One type per sitting (an apple or a banana, for example)',
          noteAr: 'تدخل تدريجياً مع مراقبة الانتفاخ',
          noteEn: 'Introduce gradually, watching for bloating',
          zone: FoodZone.yellow,
        ),
      ],
    ),
  ];
}
