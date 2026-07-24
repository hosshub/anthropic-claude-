import '../models/analysis_result.dart';

/// فئات بنك الطعام (وقت/نوع الصنف).
enum FoodBankCategory { breakfast, lunch, dinner, street, drink, sweet }

/// صنف من بنك الطعام: مأكولات عربية ومصرية شائعة مع منطقتها وفق نظام
/// الطيبات وتقديرات تغذية للحصة المتوسطة.
class FoodBankItem {
  final String id;
  final String nameAr;
  final String nameEn;
  final FoodBankCategory category;
  final FoodZone zone;
  final int caloriesKcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String portionAr;
  final String portionEn;
  final String? noteAr;
  final String? noteEn;

  const FoodBankItem(
    this.id,
    this.nameAr,
    this.nameEn,
    this.category,
    this.zone,
    this.caloriesKcal,
    this.proteinG,
    this.carbsG,
    this.fatG, {
    this.portionAr = 'حصة متوسطة',
    this.portionEn = 'medium portion',
    this.noteAr,
    this.noteEn,
  });

  String name(String locale) => locale == 'en' ? nameEn : nameAr;
  String portion(String locale) => locale == 'en' ? portionEn : portionAr;
  String? note(String locale) => locale == 'en' ? noteEn : noteAr;

  String get categoryLabelAr => switch (category) {
        FoodBankCategory.breakfast => 'فطور',
        FoodBankCategory.lunch => 'غداء',
        FoodBankCategory.dinner => 'عشاء',
        FoodBankCategory.street => 'أكل شارع',
        FoodBankCategory.drink => 'مشروب',
        FoodBankCategory.sweet => 'حلويات',
      };
}

/// بحث في بنك الطعام بالاسم (عربي أو إنجليزي، غير حساس لحالة الأحرف) مع
/// تصفية اختيارية بالفئة.
List<FoodBankItem> searchFoodBank(String query, {FoodBankCategory? category}) {
  final q = query.trim().toLowerCase();
  return [
    for (final it in foodBankItems)
      if ((category == null || it.category == category) &&
          (q.isEmpty ||
              it.nameAr.toLowerCase().contains(q) ||
              it.nameEn.toLowerCase().contains(q)))
        it,
  ];
}

const _b = FoodBankCategory.breakfast;
const _l = FoodBankCategory.lunch;
const _d = FoodBankCategory.dinner;
const _s = FoodBankCategory.street;
const _k = FoodBankCategory.drink;
const _w = FoodBankCategory.sweet;
const _g = FoodZone.green;
const _y = FoodZone.yellow;
const _r = FoodZone.red;

const String _legume = 'من البقوليات — منطقة حمراء في النظام';
const String _legumeEn = 'A legume — red zone in the system';
const String _dairy = 'من الألبان العادية — منطقة حمراء';
const String _dairyEn = 'Ordinary dairy — red zone';
const String _poultry = 'دواجن/بيض — منطقة حمراء';
const String _poultryEn = 'Poultry/eggs — red zone';

/// ~150 صنفاً مصرياً/عربياً. المناطق تتبع نظام الطيبات بأمانة:
/// البقوليات والدواجن والبيض والألبان العادية وفائق التصنيع = أحمر؛
/// الأجبان المعتّقة والفواكه والقهوة والشاي = أصفر؛ الأرز والبطاطس واللحوم
/// الحمراء والكبد والأسماك والدهون الطبيعية = أخضر.
const List<FoodBankItem> foodBankItems = [
  // ---------------------------------------------------------------- فطور
  FoodBankItem('ful', 'فول مدمس', 'Ful medames', _b, _r, 240, 14, 33, 6,
      noteAr: _legume, noteEn: _legumeEn),
  FoodBankItem('ful-zeit', 'فول بزيت الزيتون', 'Ful with olive oil', _b, _r,
      300, 14, 33, 14, noteAr: _legume, noteEn: _legumeEn),
  FoodBankItem('tameya', 'طعمية (فلافل)', "Ta'meya (falafel)", _b, _r, 330, 13,
      31, 18, noteAr: _legume, noteEn: _legumeEn),
  FoodBankItem('bedingan-me2ly', 'بيض بالبسطرمة', 'Eggs with basturma', _b, _r,
      300, 20, 3, 23, noteAr: _poultry, noteEn: _poultryEn),
  FoodBankItem('beid-3ein', 'بيض عيون', 'Fried eggs', _b, _r, 200, 13, 1, 16,
      noteAr: _poultry, noteEn: _poultryEn),
  FoodBankItem('omelette', 'أومليت', 'Omelette', _b, _r, 250, 15, 3, 20,
      noteAr: _poultry, noteEn: _poultryEn),
  FoodBankItem('gebna-2arish', 'جبنة قريش', 'Areesh cheese', _b, _r, 120, 14, 4,
      5, noteAr: _dairy, noteEn: _dairyEn),
  FoodBankItem('gebna-rumy', 'جبنة رومي', 'Roumy (aged) cheese', _b, _y, 160,
      11, 1, 12, noteAr: 'جبن معتّق — باعتدال', noteEn: 'Aged cheese — moderate'),
  FoodBankItem('gebna-cheddar', 'جبنة شيدر', 'Cheddar cheese', _b, _y, 160, 10,
      1, 13, noteAr: 'جبن معتّق — باعتدال', noteEn: 'Aged cheese — moderate'),
  FoodBankItem('zabady', 'زبادي', 'Yogurt', _b, _r, 120, 6, 12, 5,
      noteAr: _dairy, noteEn: _dairyEn),
  FoodBankItem('laban', 'لبن حليب', 'Milk', _k, _r, 130, 8, 12, 5,
      noteAr: _dairy, noteEn: _dairyEn),
  FoodBankItem('batates-samna', 'بطاطس بالسمن البلدي', 'Potatoes with ghee', _b,
      _g, 260, 4, 33, 13),
  FoodBankItem('batates-maslou2a', 'بطاطس مسلوقة', 'Boiled potatoes', _b, _g,
      160, 4, 34, 1),
  FoodBankItem('roz-samna', 'أرز بالسمن', 'Rice with ghee', _b, _g, 280, 5, 45,
      9),
  FoodBankItem('kebda-eskandarani', 'كبدة إسكندراني', 'Alexandrian liver', _b,
      _g, 260, 26, 6, 14),
  FoodBankItem('tamr', 'تمر', 'Dates', _b, _y, 90, 0.7, 24, 0.1,
      portionAr: '٣ حبات', portionEn: '3 pieces',
      noteAr: 'كمية محسوبة', noteEn: 'A measured amount'),
  FoodBankItem('3asal-nahl', 'عسل نحل', 'Honey', _b, _y, 64, 0.1, 17, 0,
      portionAr: 'ملعقة', portionEn: '1 tbsp',
      noteAr: 'كمية محسوبة', noteEn: 'A measured amount'),
  FoodBankItem('zaytoon', 'زيتون', 'Olives', _b, _g, 60, 0.4, 2, 6,
      portionAr: 'حفنة', portionEn: 'a handful'),
  FoodBankItem('zebda-baladi', 'زبدة بلدي', 'Farm butter', _b, _g, 100, 0.1, 0,
      11, portionAr: 'ملعقة', portionEn: '1 tbsp'),
  FoodBankItem('3esh-baladi', 'عيش بلدي', 'Baladi bread', _b, _r, 180, 6, 36, 1,
      noteAr: 'خبز مصنّع — يُقلَّل', noteEn: 'Processed bread — minimize'),
  FoodBankItem('toast-asmar', 'توست أسمر', 'Whole-grain toast', _b, _y, 150, 6,
      27, 2),
  FoodBankItem('mesh', 'مش قديم', 'Mish (aged cheese)', _b, _y, 130, 9, 2, 10,
      noteAr: 'جبن معتّق — باعتدال', noteEn: 'Aged cheese — moderate'),
  FoodBankItem('halawa-tahiniya', 'حلاوة طحينية', 'Halva (tahini)', _b, _r, 260,
      6, 26, 15, noteAr: 'مصنّع وسكّري', noteEn: 'Processed and sugary'),
  FoodBankItem('gebna-feta', 'جبنة فيتا/بيضاء', 'Feta / white cheese', _b, _r,
      140, 8, 2, 11, noteAr: _dairy, noteEn: _dairyEn),
  FoodBankItem('shakshouka', 'شكشوكة', 'Shakshouka', _b, _r, 250, 13, 10, 18,
      noteAr: _poultry, noteEn: _poultryEn),
  FoodBankItem('foul-eskandarani', 'فول إسكندراني', 'Alexandrian ful', _b, _r,
      320, 15, 34, 15, noteAr: _legume, noteEn: _legumeEn),

  // ---------------------------------------------------------------- غداء
  FoodBankItem('roz-lahma', 'أرز بلحمة', 'Rice with red meat', _l, _g, 520, 32,
      55, 20),
  FoodBankItem('roz-basmati', 'أرز بسمتي أبيض', 'White basmati rice', _l, _g,
      210, 4, 45, 1),
  FoodBankItem('roz-mo3ammar', 'أرز معمّر', "Roz me'ammar", _l, _r, 420, 12, 45,
      20, noteAr: _dairy, noteEn: _dairyEn),
  FoodBankItem('fattah', 'فتّة باللحمة', 'Fattah with meat', _l, _r, 620, 30,
      55, 30, noteAr: 'خبز مصنّع وثوم بالخل — يُقلَّل',
      noteEn: 'Processed bread base — minimize'),
  FoodBankItem('molokhia-lahma', 'ملوخية باللحمة', 'Molokhia with meat', _l, _g,
      380, 28, 12, 22, noteAr: 'مع لحم أحمر وأرز', noteEn: 'With red meat & rice'),
  FoodBankItem('molokhia-farkha', 'ملوخية بالفراخ', 'Molokhia with chicken', _l,
      _r, 360, 27, 12, 20, noteAr: _poultry, noteEn: _poultryEn),
  FoodBankItem('bamya-lahma', 'بامية باللحمة', 'Okra stew with meat', _l, _g,
      340, 26, 16, 18),
  FoodBankItem('kaware3', 'كوارع', 'Trotters (kaware3)', _l, _g, 420, 34, 3, 30),
  FoodBankItem('mombar', 'ممبار', 'Mombar (stuffed intestine)', _l, _g, 480, 18,
      35, 30),
  FoodBankItem('hamam-mahshi', 'حمام محشي', 'Stuffed pigeon', _l, _g, 450, 34, 28,
      22),
  FoodBankItem('araneb', 'أرنب مطبوخ', 'Cooked rabbit', _l, _g, 360, 40, 2, 20),
  FoodBankItem('sabe3-me2ly', 'سمك مقلي', 'Fried fish', _l, _g, 340, 30, 8, 20),
  FoodBankItem('samak-meshwy', 'سمك مشوي', 'Grilled fish', _l, _g, 260, 32, 0, 14),
  FoodBankItem('bolty-singary', 'بلطي سنجاري', 'Singari tilapia', _l, _g, 300,
      31, 3, 18),
  FoodBankItem('kofta', 'كفتة مشوية', 'Grilled kofta', _l, _g, 380, 28, 4, 28),
  FoodBankItem('rekaby-lahma', 'رقاق باللحمة المفرومة', 'Rekaka with mince', _l,
      _r, 560, 26, 45, 30, noteAr: 'عجين مصنّع ولبن — يُقلَّل',
      noteEn: 'Processed pastry & milk — minimize'),
  FoodBankItem('mahshi-wara2', 'محشي ورق عنب', 'Stuffed vine leaves', _l, _g,
      320, 6, 42, 15),
  FoodBankItem('mahshi-kromb', 'محشي كرنب', 'Stuffed cabbage', _l, _g, 300, 6,
      40, 13),
  FoodBankItem('mahshi-koosa', 'محشي كوسة', 'Stuffed zucchini', _l, _g, 300, 7,
      38, 13),
  FoodBankItem('mahshi-felfel', 'محشي فلفل', 'Stuffed peppers', _l, _g, 300, 6,
      38, 13),
  FoodBankItem('sadr-firakh', 'صدور فراخ مشوية', 'Grilled chicken breast', _l,
      _r, 220, 33, 0, 9, noteAr: _poultry, noteEn: _poultryEn),
  FoodBankItem('firakh-mashwya', 'ربع فرخة مشوي', 'Grilled quarter chicken', _l,
      _r, 320, 30, 0, 22, noteAr: _poultry, noteEn: _poultryEn),
  FoodBankItem('roz-adas', 'كشري رز وعدس', 'Rice and lentils (koshari base)',
      _l, _r, 340, 12, 60, 5, noteAr: _legume, noteEn: _legumeEn),
  FoodBankItem('koshari', 'كشري', 'Koshari', _s, _r, 520, 16, 90, 10,
      noteAr: 'بقوليات ومكرونة وصوص — أحمر',
      noteEn: 'Legumes, pasta and sauce — red'),
  FoodBankItem('makarona-bashamel', 'مكرونة بشاميل', 'Macarona béchamel', _l,
      _r, 560, 22, 55, 28, noteAr: 'مكرونة ولبن — أحمر',
      noteEn: 'Pasta and milk — red'),
  FoodBankItem('roz-sayadeya', 'أرز صيادية بالسمك', 'Sayadeya fish rice', _l, _g,
      520, 30, 60, 16),
  FoodBankItem('lahma-mashwya', 'لحمة مشوية', 'Grilled red meat', _l, _g, 340,
      33, 0, 23),
  FoodBankItem('kabab', 'كباب', 'Kebab', _l, _g, 360, 30, 2, 26),
  FoodBankItem('bettengan-mekhalel', 'بيتنجان مخلّل', 'Pickled aubergine', _l,
      _y, 90, 2, 10, 5, noteAr: 'مخلّل — باعتدال', noteEn: 'Pickled — moderate'),
  FoodBankItem('sogo2', 'سجق', 'Sogo2 (spiced sausage)', _l, _g, 420, 22, 6, 34),
  FoodBankItem('kebda-me2lya', 'كبدة مقلية', 'Fried liver', _l, _g, 280, 27, 5,
      16),
  FoodBankItem('mokh', 'مخ مقلي', 'Fried brain', _l, _g, 300, 12, 3, 26),
  FoodBankItem('kalawy', 'كلاوي مشوية', 'Grilled kidneys', _l, _g, 220, 26, 2,
      12),
  FoodBankItem('torly', 'طرلي خضار باللحمة', 'Mixed veg & meat casserole', _l,
      _g, 360, 24, 20, 20),
  FoodBankItem('betengan-lahma', 'مسقعة باللحمة', 'Aubergine & meat casserole',
      _l, _g, 380, 22, 18, 24),
  FoodBankItem('mahshi-batates', 'بطاطس محشية', 'Stuffed potatoes', _l, _g, 320,
      12, 40, 12),
  FoodBankItem('lahma-blbatates', 'لحمة بالبطاطس', 'Meat and potato stew', _l,
      _g, 420, 30, 30, 20),

  // ---------------------------------------------------------------- عشاء
  FoodBankItem('batates-zebda', 'بطاطس بالزبدة', 'Buttered potatoes', _d, _g,
      240, 4, 33, 11),
  FoodBankItem('roz-abyad-zeit', 'أرز أبيض بزيت الزيتون',
      'White rice with olive oil', _d, _g, 250, 4, 45, 7),
  FoodBankItem('samak-khafeef', 'سمكة صغيرة مشوية', 'Small grilled fish', _d, _g,
      180, 22, 0, 10),
  FoodBankItem('shorbet-lahma', 'شوربة لحمة', 'Clear meat broth', _d, _g, 180,
      16, 6, 10),
  FoodBankItem('shorbet-3ads', 'شوربة عدس', 'Lentil soup', _d, _r, 230, 12, 36,
      4, noteAr: _legume, noteEn: _legumeEn),
  FoodBankItem('shorbet-khodar', 'شوربة خضار', 'Vegetable soup', _d, _y, 120, 4,
      18, 4),
  FoodBankItem('salata-baladi', 'سلطة بلدي', 'Baladi salad', _d, _y, 90, 2, 10,
      5, portionAr: 'طبق', portionEn: 'a bowl'),
  FoodBankItem('salata-tahina', 'سلطة طحينة', 'Tahini salad', _d, _y, 180, 5, 8,
      15),
  FoodBankItem('baba-ghanoug', 'بابا غنوج', 'Baba ghanoush', _d, _y, 160, 4, 10,
      12),
  FoodBankItem('tabbouleh', 'تبولة', 'Tabbouleh', _d, _y, 150, 4, 20, 7),
  FoodBankItem('gebna-zaytoon', 'جبنة رومي وزيتون', 'Roumy cheese & olives', _d,
      _y, 220, 12, 3, 18),
  FoodBankItem('roz-labany', 'أرز بلبن', 'Rice pudding', _w, _r, 260, 7, 44, 6,
      noteAr: _dairy, noteEn: _dairyEn),
  FoodBankItem('tamr-maa', 'تمر وماء', 'Dates and water', _d, _y, 100, 1, 25, 0,
      portionAr: '٣ تمرات', portionEn: '3 dates'),
  FoodBankItem('batarekh', 'بطارخ', 'Botargo (batarekh)', _d, _g, 260, 24, 2,
      18),
  FoodBankItem('feseekh', 'فسيخ', 'Feseekh (fermented fish)', _d, _y, 240, 26, 0,
      15, noteAr: 'مملّح — باعتدال', noteEn: 'Very salty — moderate'),
  FoodBankItem('renga', 'رنجة', 'Smoked herring (renga)', _d, _g, 220, 22, 0,
      15),
  FoodBankItem('gambari-mashwy', 'جمبري مشوي', 'Grilled shrimp', _d, _g, 180, 28,
      2, 6),
  FoodBankItem('kalamari', 'كاليماري مشوي', 'Grilled calamari', _d, _g, 200, 26,
      6, 8),
  FoodBankItem('shorbet-kawitch', 'شوربة كوارع', 'Trotter soup', _d, _g, 260,
      24, 3, 17),

  // ---------------------------------------------------------------- أكل شارع
  FoodBankItem('shawarma-lahma', 'شاورما لحمة', 'Meat shawarma', _s, _y, 480, 28,
      40, 24, noteAr: 'خبز وصوص جاهز — باعتدال',
      noteEn: 'Bread & ready sauce — moderate'),
  FoodBankItem('shawarma-firakh', 'شاورما فراخ', 'Chicken shawarma', _s, _r, 460,
      30, 40, 20, noteAr: _poultry, noteEn: _poultryEn),
  FoodBankItem('hawawshy', 'حواوشي', 'Hawawshi', _s, _y, 520, 26, 45, 26,
      noteAr: 'خبز مصنّع — يُقلَّل', noteEn: 'Processed bread — minimize'),
  FoodBankItem('sandwich-kebda', 'سندويتش كبدة', 'Liver sandwich', _s, _y, 380,
      22, 38, 16, noteAr: 'خبز مصنّع — يُقلَّل',
      noteEn: 'Processed bread — minimize'),
  FoodBankItem('sandwich-sogo2', 'سندويتش سجق', 'Sogo2 sandwich', _s, _y, 430,
      20, 38, 24, noteAr: 'خبز مصنّع — يُقلَّل',
      noteEn: 'Processed bread — minimize'),
  FoodBankItem('taboon-lahma', 'فطير باللحمة', 'Meat feteer', _s, _y, 620, 24,
      55, 34),
  FoodBankItem('feteer-meshaltet', 'فطير مشلتت سادة', 'Plain feteer', _s, _y,
      520, 10, 60, 26),
  FoodBankItem('battata-mashwya', 'بطاطا مشوية', 'Roasted sweet potato', _s, _g,
      180, 3, 41, 0),
  FoodBankItem('dora-mashwy', 'ذرة مشوية', 'Grilled corn', _s, _y, 130, 4, 28, 2),
  FoodBankItem('termes', 'ترمس', 'Lupini beans (termes)', _s, _r, 160, 16, 12, 5,
      noteAr: _legume, noteEn: _legumeEn),
  FoodBankItem('hummus-sham', 'حمص الشام', 'Hot chickpeas (hummus el-Sham)', _s,
      _r, 180, 9, 28, 4, noteAr: _legume, noteEn: _legumeEn),
  FoodBankItem('sandwich-tameya', 'سندويتش طعمية', "Ta'meya sandwich", _s, _r,
      380, 13, 45, 17, noteAr: _legume, noteEn: _legumeEn),
  FoodBankItem('sandwich-batates', 'سندويتش بطاطس', 'Potato sandwich', _s, _y,
      340, 7, 52, 12),
  FoodBankItem('kebda-sandwich-eskndrany', 'سندويتش كبدة إسكندراني',
      'Alexandrian liver sandwich', _s, _y, 420, 24, 40, 18),
  FoodBankItem('sogo2-eskndrany', 'سجق إسكندراني', 'Alexandrian sogo2', _s, _g,
      420, 22, 6, 34),
  FoodBankItem('grilled-liver-street', 'كبدة على الطريقة', 'Street grilled liver',
      _s, _g, 260, 26, 5, 15),
  FoodBankItem('shish-tawook', 'شيش طاووق', 'Shish tawook', _s, _r, 320, 34, 4,
      18, noteAr: _poultry, noteEn: _poultryEn),
  FoodBankItem('kofta-street', 'كفتة على الفحم', 'Charcoal kofta', _s, _g, 380,
      28, 4, 28),
  FoodBankItem('foul-sandwich', 'سندويتش فول', 'Ful sandwich', _s, _r, 300, 12,
      45, 8, noteAr: _legume, noteEn: _legumeEn),
  FoodBankItem('mekaronah-street', 'مكرونة بالصلصة', 'Pasta with tomato sauce',
      _s, _r, 420, 12, 70, 10, noteAr: 'مكرونة مصنّعة — أحمر',
      noteEn: 'Processed pasta — red'),
  FoodBankItem('shawerma-crepe', 'كريب لحمة', 'Meat crêpe', _s, _y, 560, 26, 50,
      28),
  FoodBankItem('bolty-mashwy-street', 'بلطي مشوي بالشارع', 'Street grilled tilapia',
      _s, _g, 300, 31, 3, 17),
  FoodBankItem('grilled-quail-street', 'سمان مشوي', 'Grilled quail', _s, _g, 280,
      30, 0, 18),

  // ---------------------------------------------------------------- مشروبات
  FoodBankItem('maya', 'ماء', 'Water', _k, _g, 0, 0, 0, 0,
      portionAr: 'كوب', portionEn: 'a glass'),
  FoodBankItem('2ahwa', 'قهوة سادة', 'Black coffee', _k, _y, 5, 0.1, 1, 0,
      portionAr: 'فنجان', portionEn: 'a cup',
      noteAr: 'حسب النوم والتحمّل', noteEn: 'Per sleep & tolerance'),
  FoodBankItem('2ahwa-turky', 'قهوة تركي', 'Turkish coffee', _k, _y, 40, 0.2, 9,
      0, portionAr: 'فنجان', portionEn: 'a cup'),
  FoodBankItem('shay', 'شاي', 'Tea', _k, _y, 30, 0, 8, 0, portionAr: 'كوب',
      portionEn: 'a glass', noteAr: 'بسكر خفيف', noteEn: 'With light sugar'),
  FoodBankItem('shay-bilaban', 'شاي باللبن', 'Tea with milk', _k, _r, 110, 4, 14,
      4, noteAr: _dairy, noteEn: _dairyEn),
  FoodBankItem('ne3na3', 'شاي بالنعناع', 'Mint tea', _k, _y, 30, 0, 8, 0),
  FoodBankItem('yansoon', 'ينسون', 'Anise (yansoon)', _k, _g, 10, 0, 2, 0),
  FoodBankItem('helba', 'حلبة', 'Fenugreek drink (helba)', _k, _g, 40, 2, 6, 1),
  FoodBankItem('2erfa', 'قرفة', 'Cinnamon drink (erfa)', _k, _y, 60, 1, 14, 0),
  FoodBankItem('sahlab', 'سحلب', 'Sahlab', _k, _r, 220, 6, 36, 6,
      noteAr: _dairy, noteEn: _dairyEn),
  FoodBankItem('karkade', 'كركديه', 'Hibiscus (karkade)', _k, _y, 60, 0, 15, 0),
  FoodBankItem('3asir-2asab', 'عصير قصب', 'Sugarcane juice', _k, _y, 190, 0, 48,
      0, noteAr: 'سكّري — باعتدال', noteEn: 'Sugary — moderate'),
  FoodBankItem('3asir-manga', 'عصير مانجو', 'Mango juice', _k, _y, 150, 1, 37, 0,
      noteAr: 'فاكهة — صنف واحد بالجلسة', noteEn: 'Fruit — one type per sitting'),
  FoodBankItem('3asir-borto2an', 'عصير برتقال', 'Orange juice', _k, _y, 120, 2,
      26, 0),
  FoodBankItem('3asir-farawla', 'عصير فراولة', 'Strawberry juice', _k, _y, 110,
      1, 26, 0),
  FoodBankItem('3asir-limoon', 'عصير ليمون', 'Lemonade', _k, _y, 90, 0, 23, 0),
  FoodBankItem('sobia', 'سوبيا', 'Sobia', _k, _r, 200, 4, 34, 6,
      noteAr: _dairy, noteEn: _dairyEn),
  FoodBankItem('3ergsous', 'عرقسوس', 'Licorice drink (erksous)', _k, _y, 70, 0,
      17, 0),
  FoodBankItem('tamr-hendy', 'تمر هندي', 'Tamarind drink', _k, _y, 90, 0, 22, 0),
  FoodBankItem('kharoob', 'خروب', 'Carob drink', _k, _y, 100, 1, 24, 0),
  FoodBankItem('soda', 'مشروب غازي', 'Soda / soft drink', _k, _r, 140, 0, 39, 0,
      noteAr: 'غازي — منطقة حمراء', noteEn: 'Soda — red zone'),

  // ---------------------------------------------------------------- حلويات
  FoodBankItem('om-ali', 'أم علي', 'Om Ali', _w, _r, 420, 9, 55, 18,
      noteAr: _dairy, noteEn: _dairyEn),
  FoodBankItem('konafa', 'كنافة', 'Kunafa', _w, _r, 480, 8, 62, 22,
      noteAr: 'مصنّع وسكّري', noteEn: 'Processed and sugary'),
  FoodBankItem('basbousa', 'بسبوسة', 'Basbousa', _w, _r, 380, 5, 55, 16,
      noteAr: 'مصنّع وسكّري', noteEn: 'Processed and sugary'),
  FoodBankItem('baklava', 'بقلاوة', 'Baklava', _w, _r, 420, 6, 45, 25,
      noteAr: 'مصنّع وسكّري', noteEn: 'Processed and sugary'),
  FoodBankItem('zalabya', 'زلابية', 'Zalabya (loqmet el-qady)', _w, _r, 360, 5,
      50, 16, noteAr: 'مقلي وسكّري', noteEn: 'Fried and sugary'),
  FoodBankItem('roz-blaban-w', 'أرز باللبن', 'Rice pudding', _w, _r, 260, 7, 44,
      6, noteAr: _dairy, noteEn: _dairyEn),
  FoodBankItem('mahalabeya', 'مهلبية', 'Mahalabeya', _w, _r, 220, 5, 38, 5,
      noteAr: _dairy, noteEn: _dairyEn),
  FoodBankItem('balah-elsham', 'بلح الشام', 'Balah el-Sham', _w, _r, 340, 4, 44,
      17, noteAr: 'مقلي وسكّري', noteEn: 'Fried and sugary'),
  FoodBankItem('ghorayeba', 'غريبة', 'Ghorayeba', _w, _r, 300, 3, 34, 17,
      noteAr: 'مصنّع وسكّري', noteEn: 'Processed and sugary'),
  FoodBankItem('kahk', 'كحك العيد', 'Kahk (feast cookies)', _w, _r, 320, 4, 38,
      17, noteAr: 'مصنّع وسكّري', noteEn: 'Processed and sugary'),
  FoodBankItem('petit-four', 'بيتي فور', 'Petit four', _w, _r, 300, 4, 40, 14,
      noteAr: 'مصنّع وسكّري', noteEn: 'Processed and sugary'),
  FoodBankItem('meshabek', 'مشبّك', 'Meshabek', _w, _r, 350, 3, 55, 14,
      noteAr: 'مقلي وسكّري', noteEn: 'Fried and sugary'),
  FoodBankItem('roz-b3agwa', 'تمر بالسمن', 'Dates in ghee', _w, _y, 180, 1, 30,
      7, noteAr: 'كمية محسوبة', noteEn: 'A measured amount'),
  FoodBankItem('3asal-tahina', 'عسل بطحينة', 'Honey with tahini', _w, _y, 240, 5,
      18, 16),
  FoodBankItem('balah-sokary', 'بلح سكري', 'Sukkary dates', _w, _y, 110, 1, 28,
      0, portionAr: '٣ حبات', portionEn: '3 pieces'),
  FoodBankItem('teen-mogaffaf', 'تين مجفف', 'Dried figs', _w, _y, 100, 1, 24, 0),
  FoodBankItem('zabib', 'زبيب', 'Raisins', _w, _y, 90, 1, 22, 0),
  FoodBankItem('mango-fresh', 'مانجو طازة', 'Fresh mango', _w, _y, 100, 1, 25, 0,
      noteAr: 'صنف فاكهة واحد بالجلسة', noteEn: 'One fruit type per sitting'),
  FoodBankItem('battikh', 'بطيخ', 'Watermelon', _w, _y, 90, 2, 22, 0),
  FoodBankItem('3enab', 'عنب', 'Grapes', _w, _y, 100, 1, 26, 0),
  FoodBankItem('tuffah', 'تفاح', 'Apple', _w, _y, 95, 0.5, 25, 0),
  FoodBankItem('mooz', 'موز', 'Banana', _w, _y, 105, 1.3, 27, 0.4),
];
