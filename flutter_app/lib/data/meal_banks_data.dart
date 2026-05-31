import '../models/analysis_result.dart';

/// عنصر داخل بنك وجبات (فكرة جاهزة).
class MealBankItem {
  final String nameAr;
  final String compositionAr;
  final String? noteAr;
  final FoodZone zone;
  const MealBankItem({
    required this.nameAr,
    required this.compositionAr,
    this.noteAr,
    required this.zone,
  });
}

/// بنك وجبات بحسب وقت اليوم.
class MealBank {
  final String emoji;
  final String titleAr;
  final String subtitleAr;
  final List<MealBankItem> items;
  const MealBank({
    required this.emoji,
    required this.titleAr,
    required this.subtitleAr,
    required this.items,
  });
}

class MealBanksData {
  static const List<MealBank> banks = [
    MealBank(
      emoji: '🌅',
      titleAr: 'بنك الفطار',
      subtitleAr: 'أفكار سريعة ومشبعة',
      items: [
        MealBankItem(
          nameAr: 'تمر وماء',
          compositionAr: 'بضع تمرات + كوب ماء',
          noteAr: 'بسيط وسريع — مناسب عند الحاجة لطاقة خفيفة',
          zone: FoodZone.yellow,
        ),
        MealBankItem(
          nameAr: 'بطاطس مهروسة بزبدة طبيعية',
          compositionAr: 'بطاطس مسلوقة + زبدة بلدية',
          noteAr: 'فطور مشبع وبسيط المكونات',
          zone: FoodZone.green,
        ),
        MealBankItem(
          nameAr: 'أرز بسيط بالسمن',
          compositionAr: 'أرز أبيض + سمن بلدي',
          noteAr: 'للفطار المُشبع الذي يكفي حتى الغداء',
          zone: FoodZone.green,
        ),
        MealBankItem(
          nameAr: 'توست كامل وجبنة معتقة',
          compositionAr: 'توست حبوب كاملة + جبن معتق صلب (شيدر / جودة)',
          noteAr: 'باعتدال — من المنطقة الصفراء وحسب الهضم',
          zone: FoodZone.yellow,
        ),
      ],
    ),
    MealBank(
      emoji: '🍽',
      titleAr: 'بنك الغداء',
      subtitleAr: 'أطباق رئيسية واضحة',
      items: [
        MealBankItem(
          nameAr: 'أرز ولحم',
          compositionAr: 'أرز + لحم أحمر مستوٍ تماماً',
          zone: FoodZone.green,
        ),
        MealBankItem(
          nameAr: 'كبدة وبطاطس',
          compositionAr: 'كبدة + بطاطس',
          zone: FoodZone.green,
        ),
        MealBankItem(
          nameAr: 'سمك وأرز',
          compositionAr: 'سمك (مشوي أو مقلي) + أرز',
          zone: FoodZone.green,
        ),
        MealBankItem(
          nameAr: 'كوارع أو حمام',
          compositionAr: 'كوارع أو حمام مع نشوية بسيطة',
          noteAr: 'وجبة مشبعة لمن يحبّها',
          zone: FoodZone.green,
        ),
      ],
    ),
    MealBank(
      emoji: '🌙',
      titleAr: 'بنك العشاء',
      subtitleAr: 'خفيف وواضح',
      items: [
        MealBankItem(
          nameAr: 'بطاطس مسلوقة بزبدة',
          compositionAr: 'بطاطس مسلوقة + زبدة طبيعية',
          noteAr: 'مناسب عند الحاجة لعشاء بسيط ومريح',
          zone: FoodZone.green,
        ),
        MealBankItem(
          nameAr: 'أرز خفيف',
          compositionAr: 'أرز أبيض بسيط مع سمن أو زيت زيتون',
          noteAr: 'وجبة صغيرة بدون مكونات كثيرة',
          zone: FoodZone.green,
        ),
        MealBankItem(
          nameAr: 'جبنة معتقة مع توست كامل',
          compositionAr: 'جبن معتق + توست حبوب كاملة',
          noteAr: 'عند تحمّل الأجبان وضمن الاعتدال',
          zone: FoodZone.yellow,
        ),
        MealBankItem(
          nameAr: 'تمر وماء',
          compositionAr: 'بضع تمرات + كوب ماء',
          noteAr: 'عند احتياج بسيط دون وجبة كبيرة',
          zone: FoodZone.yellow,
        ),
      ],
    ),
    MealBank(
      emoji: '🍯',
      titleAr: 'بنك السناك والحلويات',
      subtitleAr: 'باعتدال — ليس عادة مستمرة طول اليوم',
      items: [
        MealBankItem(
          nameAr: 'تمر',
          compositionAr: 'كمية صغيرة عند الحاجة للطاقة',
          noteAr: 'من المنطقة الصفراء — كميات بسيطة',
          zone: FoodZone.yellow,
        ),
        MealBankItem(
          nameAr: 'عسل طبيعي',
          compositionAr: 'ملعقة صغيرة داخل وصفة أو وحده',
          noteAr: 'كميات محسوبة، وليس استخداماً مفتوحاً',
          zone: FoodZone.yellow,
        ),
        MealBankItem(
          nameAr: 'فاكهة طبيعية',
          compositionAr: 'صنف واحد بالجلسة (مثلاً: تفاحة أو موزة)',
          noteAr: 'تدخل تدريجياً مع مراقبة الانتفاخ',
          zone: FoodZone.yellow,
        ),
      ],
    ),
  ];
}
