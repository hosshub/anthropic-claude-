import '../models/analysis_result.dart';

String _pick(String locale, String ar, String en) => locale == 'en' ? en : ar;

/// فئة الوجبة في دليل الوجبات الكامل.
enum GuidebookCategory { breakfast, lunch, dinner, snack, fasting }

/// وجبة كاملة في دليل الطيبات: مكوّنات + طريقة تحضير مختصرة + منطقة غالبة
/// + تقديرات تغذية تقريبية. المحتوى ملتزم بقوائم النظام: الأساس أخضر،
/// اللمسات الصفراء بحساب، ولا شيء من المنطقة الحمراء إطلاقاً.
class GuidebookMeal {
  final String nameAr;
  final String nameEn;
  final GuidebookCategory category;
  final List<String> componentsAr;
  final List<String> componentsEn;
  final String prepAr;
  final String prepEn;
  final FoodZone zone;
  final int kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const GuidebookMeal({
    required this.nameAr,
    required this.nameEn,
    required this.category,
    required this.componentsAr,
    required this.componentsEn,
    required this.prepAr,
    required this.prepEn,
    required this.zone,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  String name(String locale) => _pick(locale, nameAr, nameEn);
  List<String> components(String locale) =>
      locale == 'en' ? componentsEn : componentsAr;
  String prep(String locale) => _pick(locale, prepAr, prepEn);

  MealNutrition get nutrition => MealNutrition(
        caloriesKcal: kcal,
        proteinG: proteinG,
        carbsG: carbsG,
        fatG: fatG,
      );
}

class GuidebookData {
  static const List<GuidebookMeal> meals = [
    // ---------------------------------------------------------------- فطور
    GuidebookMeal(
      nameAr: 'بطاطس الصباح بالزبدة',
      nameEn: 'Morning potatoes with butter',
      category: GuidebookCategory.breakfast,
      componentsAr: ['بطاطس مسلوقة (حبتان وسط)', 'زبدة طبيعية (ملعقة كبيرة)', 'رشة ملح'],
      componentsEn: ['Boiled potatoes (2 medium)', 'Natural butter (1 tbsp)', 'Pinch of salt'],
      prepAr: 'تُسلق البطاطس حتى تنضج تماماً، تُهرس مع الزبدة والملح وتقدَّم دافئة.',
      prepEn: 'Boil the potatoes until fully tender, mash with the butter and salt, serve warm.',
      zone: FoodZone.green,
      kcal: 380, proteinG: 6, carbsG: 62, fatG: 12,
    ),
    GuidebookMeal(
      nameAr: 'أرز الفطار بالسمن البلدي',
      nameEn: 'Breakfast rice with ghee',
      category: GuidebookCategory.breakfast,
      componentsAr: ['أرز أبيض مطبوخ (كوب)', 'سمن بلدي (ملعقة كبيرة)'],
      componentsEn: ['Cooked white rice (1 cup)', 'Ghee — samn baladi (1 tbsp)'],
      prepAr: 'يُسخَّن الأرز مع السمن على نار هادئة حتى يتشرّب. فطور مُشبع يكفي حتى الغداء.',
      prepEn: 'Warm the rice with the ghee over low heat until absorbed. A filling breakfast that holds you to lunch.',
      zone: FoodZone.green,
      kcal: 330, proteinG: 4.5, carbsG: 45, fatG: 14,
    ),
    GuidebookMeal(
      nameAr: 'تمرات وماء (فطور خفيف)',
      nameEn: 'Dates and water (light breakfast)',
      category: GuidebookCategory.breakfast,
      componentsAr: ['تمر (٣–٥ حبات)', 'كوب ماء كبير'],
      componentsEn: ['Dates (3–5)', 'A large glass of water'],
      prepAr: 'يُؤكل التمر ببطء مع الماء. طاقة سريعة عند صباح مزدحم — كمية محسوبة لا أكثر.',
      prepEn: 'Eat the dates slowly with the water. Quick energy for a busy morning — a measured amount, no more.',
      zone: FoodZone.yellow,
      kcal: 200, proteinG: 1.5, carbsG: 52, fatG: 0.3,
    ),
    GuidebookMeal(
      nameAr: 'توست كامل بجبنة معتقة',
      nameEn: 'Whole-grain toast with aged cheese',
      category: GuidebookCategory.breakfast,
      componentsAr: ['توست حبوب كاملة (شريحتان)', 'جبن معتق صلب — شيدر أو جودة (٤٠ غ)'],
      componentsEn: ['Whole-grain toast (2 slices)', 'Hard aged cheese — cheddar or gouda (40 g)'],
      prepAr: 'يُحمَّص التوست وتوضع الجبنة شرائح. من المنطقة الصفراء — راقب هضمك بعدها.',
      prepEn: 'Toast the bread and layer the cheese. Yellow zone — watch your digestion afterwards.',
      zone: FoodZone.yellow,
      kcal: 310, proteinG: 14, carbsG: 28, fatG: 16,
    ),
    GuidebookMeal(
      nameAr: 'كبدة الصباح السريعة',
      nameEn: 'Quick morning liver',
      category: GuidebookCategory.breakfast,
      componentsAr: ['كبدة بلدي (١٠٠ غ)', 'زيت زيتون (ملعقة)', 'توست كامل أو أرز خفيف'],
      componentsEn: ['Liver (100 g)', 'Olive oil (1 tbsp)', 'Whole-grain toast or light rice'],
      prepAr: 'تُشوَّح الكبدة في زيت الزيتون على نار متوسطة حتى تستوي تماماً. بروتين وحديد لبداية قوية.',
      prepEn: 'Sear the liver in olive oil over medium heat until fully cooked. Protein and iron for a strong start.',
      zone: FoodZone.green,
      kcal: 350, proteinG: 28, carbsG: 18, fatG: 18,
    ),
    GuidebookMeal(
      nameAr: 'فاكهة الصباح (صنف واحد)',
      nameEn: 'Morning fruit (one type)',
      category: GuidebookCategory.breakfast,
      componentsAr: ['تفاحة أو موزة أو كمثرى (صنف واحد فقط)'],
      componentsEn: ['An apple, banana, or pear (one type only)'],
      prepAr: 'صنف فاكهة واحد بالجلسة — القاعدة الذهبية. يناسب من يعتاد فطوراً خفيفاً جداً.',
      prepEn: 'One fruit type per sitting — the golden rule. Suits those used to a very light breakfast.',
      zone: FoodZone.yellow,
      kcal: 100, proteinG: 0.5, carbsG: 26, fatG: 0.3,
    ),

    // ---------------------------------------------------------------- غداء
    GuidebookMeal(
      nameAr: 'أرز ولحم أحمر',
      nameEn: 'Rice and red meat',
      category: GuidebookCategory.lunch,
      componentsAr: ['أرز بسمتي مطبوخ (كوب ونصف)', 'لحم أحمر مستوٍ تماماً (١٥٠ غ)', 'سمن بلدي (ملعقة صغيرة)'],
      componentsEn: ['Cooked basmati rice (1.5 cups)', 'Fully cooked red meat (150 g)', 'Ghee (1 tsp)'],
      prepAr: 'يُطهى اللحم حتى الاستواء الكامل ويقدَّم فوق الأرز المُسمَّن. الطبق الرئيسي الأوضح في النظام.',
      prepEn: 'Cook the meat through completely and serve over the ghee rice. The clearest main plate in the system.',
      zone: FoodZone.green,
      kcal: 640, proteinG: 42, carbsG: 68, fatG: 20,
    ),
    GuidebookMeal(
      nameAr: 'كبدة وبطاطس مشوية',
      nameEn: 'Liver with roasted potatoes',
      category: GuidebookCategory.lunch,
      componentsAr: ['كبدة بلدي (١٥٠ غ)', 'بطاطس مشوية (حبتان)', 'زيت زيتون'],
      componentsEn: ['Liver (150 g)', 'Roasted potatoes (2)', 'Olive oil'],
      prepAr: 'تُشوى البطاطس بزيت الزيتون وتُشوَّح الكبدة حتى الاستواء. وجبة حديد وبروتين مُشبعة.',
      prepEn: 'Roast the potatoes in olive oil and sear the liver until done. A filling iron-and-protein meal.',
      zone: FoodZone.green,
      kcal: 560, proteinG: 38, carbsG: 52, fatG: 22,
    ),
    GuidebookMeal(
      nameAr: 'سمك مشوي وأرز',
      nameEn: 'Grilled fish and rice',
      category: GuidebookCategory.lunch,
      componentsAr: ['سمك مشوي (١٥٠–٢٠٠ غ)', 'أرز أبيض (كوب)', 'زيت زيتون وليمون خفيف'],
      componentsEn: ['Grilled fish (150–200 g)', 'White rice (1 cup)', 'Olive oil and a little lemon'],
      prepAr: 'يُتبَّل السمك بالقليل ويُشوى. بروتين خفيف على المعدة مع أساس نشوي بسيط.',
      prepEn: 'Season the fish lightly and grill. A stomach-light protein over a simple starch base.',
      zone: FoodZone.green,
      kcal: 520, proteinG: 40, carbsG: 48, fatG: 16,
    ),
    GuidebookMeal(
      nameAr: 'حمام محشي أرز',
      nameEn: 'Rice-stuffed pigeon',
      category: GuidebookCategory.lunch,
      componentsAr: ['حمام (واحدة)', 'أرز للحشو', 'سمن بلدي'],
      componentsEn: ['Pigeon (one)', 'Rice for stuffing', 'Ghee'],
      prepAr: 'يُحشى الحمام بالأرز المُسمَّن ويُطهى حتى النضج الكامل. من أطيب أطباق المناسبات.',
      prepEn: 'Stuff the pigeon with ghee rice and cook until completely done. One of the finest occasion plates.',
      zone: FoodZone.green,
      kcal: 680, proteinG: 36, carbsG: 58, fatG: 30,
    ),
    GuidebookMeal(
      nameAr: 'كوارع مع نشوية بسيطة',
      nameEn: 'Trotters with a simple starch',
      category: GuidebookCategory.lunch,
      componentsAr: ['كوارع مطهية جيداً', 'أرز أو بطاطس مسلوقة'],
      componentsEn: ['Well-cooked trotters', 'Rice or boiled potatoes'],
      prepAr: 'تُطهى الكوارع طويلاً حتى تلين تماماً وتقدَّم مع نشوية واحدة بسيطة. وجبة مُشبعة لمن يحبها.',
      prepEn: 'Simmer the trotters long until fully tender; serve with one simple starch. Deeply filling for those who enjoy it.',
      zone: FoodZone.green,
      kcal: 620, proteinG: 35, carbsG: 45, fatG: 32,
    ),
    GuidebookMeal(
      nameAr: 'أرنب مطهو وبطاطس',
      nameEn: 'Cooked rabbit with potatoes',
      category: GuidebookCategory.lunch,
      componentsAr: ['لحم أرنب (١٥٠ غ)', 'بطاطس مطبوخة', 'زيت زيتون'],
      componentsEn: ['Rabbit meat (150 g)', 'Cooked potatoes', 'Olive oil'],
      prepAr: 'يُطهى الأرنب حتى الاستواء التام مع البطاطس. بروتين أبيض ضمن قائمة النظام.',
      prepEn: 'Cook the rabbit through with the potatoes. A white protein that is on the system list.',
      zone: FoodZone.green,
      kcal: 540, proteinG: 40, carbsG: 46, fatG: 20,
    ),
    GuidebookMeal(
      nameAr: 'سمان مشوي وأرز بسمتي',
      nameEn: 'Grilled quail with basmati rice',
      category: GuidebookCategory.lunch,
      componentsAr: ['سمان (٢)', 'أرز بسمتي (كوب)', 'سمن بلدي'],
      componentsEn: ['Quail (2)', 'Basmati rice (1 cup)', 'Ghee'],
      prepAr: 'يُشوى السمان حتى النضج ويقدَّم فوق أرز مُسمَّن. طائر ضمن قائمة النظام — ليس دواجن تجارية.',
      prepEn: 'Grill the quail until done and serve over ghee rice. A listed bird — not commercial poultry.',
      zone: FoodZone.green,
      kcal: 600, proteinG: 38, carbsG: 52, fatG: 24,
    ),
    GuidebookMeal(
      nameAr: 'غداء الجبنة المعتقة (يوم خفيف)',
      nameEn: 'Aged-cheese lunch (light day)',
      category: GuidebookCategory.lunch,
      componentsAr: ['جبن معتق (٥٠ غ)', 'توست كامل أو بطاطس مسلوقة', 'زيتون'],
      componentsEn: ['Aged cheese (50 g)', 'Whole-grain toast or boiled potatoes', 'Olives'],
      prepAr: 'ليوم لا تشتهي فيه طبخاً: جبنة معتقة مع نشوية بسيطة وزيتون. لمسة صفراء بحساب.',
      prepEn: 'For a no-cooking day: aged cheese with a simple starch and olives. A measured yellow touch.',
      zone: FoodZone.yellow,
      kcal: 450, proteinG: 18, carbsG: 40, fatG: 24,
    ),

    // ---------------------------------------------------------------- عشاء
    GuidebookMeal(
      nameAr: 'بطاطس العشاء الدافئة',
      nameEn: 'Warm dinner potatoes',
      category: GuidebookCategory.dinner,
      componentsAr: ['بطاطس مسلوقة (حبة كبيرة)', 'زبدة طبيعية'],
      componentsEn: ['Boiled potato (1 large)', 'Natural butter'],
      prepAr: 'عشاء بسيط مريح للمعدة قبل النوم — بطاطس دافئة بالزبدة، بلا إضافات كثيرة.',
      prepEn: 'A simple, stomach-easy dinner before bed — warm buttered potato, nothing extra.',
      zone: FoodZone.green,
      kcal: 260, proteinG: 4, carbsG: 40, fatG: 9,
    ),
    GuidebookMeal(
      nameAr: 'أرز خفيف بزيت الزيتون',
      nameEn: 'Light rice with olive oil',
      category: GuidebookCategory.dinner,
      componentsAr: ['أرز أبيض (نصف كوب إلى كوب)', 'زيت زيتون (ملعقة)'],
      componentsEn: ['White rice (½–1 cup)', 'Olive oil (1 tbsp)'],
      prepAr: 'كمية صغيرة تكفي المساء. توقّف قبل الامتلاء — قاعدة العشاء الأولى.',
      prepEn: 'A small evening portion. Stop before fullness — the first rule of dinner.',
      zone: FoodZone.green,
      kcal: 280, proteinG: 3.5, carbsG: 42, fatG: 11,
    ),
    GuidebookMeal(
      nameAr: 'سمك خفيف مع ليمون',
      nameEn: 'Light fish with lemon',
      category: GuidebookCategory.dinner,
      componentsAr: ['سمك مشوي صغير (١٠٠ غ)', 'ليمون', 'زيت زيتون'],
      componentsEn: ['Small grilled fish (100 g)', 'Lemon', 'Olive oil'],
      prepAr: 'بروتين مسائي خفيف لمن يتعشى مبكراً. تجنّبه متأخراً إن أثّر على نومك.',
      prepEn: 'A light evening protein for early diners. Skip it late if it affects your sleep.',
      zone: FoodZone.green,
      kcal: 220, proteinG: 22, carbsG: 2, fatG: 13,
    ),
    GuidebookMeal(
      nameAr: 'عشاء الجبنة والتوست',
      nameEn: 'Cheese-and-toast dinner',
      category: GuidebookCategory.dinner,
      componentsAr: ['جبن معتق (٣٠ غ)', 'توست حبوب كاملة (شريحة)'],
      componentsEn: ['Aged cheese (30 g)', 'Whole-grain toast (1 slice)'],
      prepAr: 'عشاء صغير من المنطقة الصفراء — عند تحمّل الأجبان وضمن الاعتدال.',
      prepEn: 'A small yellow-zone dinner — when you tolerate cheese, and in moderation.',
      zone: FoodZone.yellow,
      kcal: 210, proteinG: 10, carbsG: 15, fatG: 12,
    ),
    GuidebookMeal(
      nameAr: 'تمر وماء (عشاء الزهد)',
      nameEn: 'Dates and water (minimal dinner)',
      category: GuidebookCategory.dinner,
      componentsAr: ['تمر (٣ حبات)', 'ماء'],
      componentsEn: ['Dates (3)', 'Water'],
      prepAr: 'حين لا تحتاج وجبة كاملة: حاجة بسيطة تسدّ الجوع وتُنام هادئاً.',
      prepEn: 'When you do not need a full meal: a simple bite that settles hunger for a calm night.',
      zone: FoodZone.yellow,
      kcal: 140, proteinG: 1, carbsG: 36, fatG: 0.2,
    ),
    GuidebookMeal(
      nameAr: 'شوربة لحم صافية',
      nameEn: 'Clear meat broth',
      category: GuidebookCategory.dinner,
      componentsAr: ['مرق لحم صافٍ', 'قطع لحم صغيرة مستوية', 'ملح خفيف'],
      componentsEn: ['Clear meat broth', 'Small fully-cooked meat pieces', 'Light salt'],
      prepAr: 'مرق دافئ صافٍ مع قطع لحم قليلة. عشاء شتوي مريح بدون ثقل.',
      prepEn: 'Warm clear broth with a few meat pieces. A comforting winter dinner without heaviness.',
      zone: FoodZone.green,
      kcal: 180, proteinG: 18, carbsG: 3, fatG: 10,
    ),

    // ---------------------------------------------------------------- سناك
    GuidebookMeal(
      nameAr: 'تمرات الطاقة',
      nameEn: 'Energy dates',
      category: GuidebookCategory.snack,
      componentsAr: ['تمر (٢–٣ حبات)'],
      componentsEn: ['Dates (2–3)'],
      prepAr: 'سناك المنطقة الصفراء الأول — كمية صغيرة محسوبة عند الحاجة الفعلية للطاقة.',
      prepEn: 'The primary yellow-zone snack — a small measured amount when you genuinely need energy.',
      zone: FoodZone.yellow,
      kcal: 130, proteinG: 1, carbsG: 34, fatG: 0.2,
    ),
    GuidebookMeal(
      nameAr: 'ملعقة عسل طبيعي',
      nameEn: 'A spoon of natural honey',
      category: GuidebookCategory.snack,
      componentsAr: ['عسل طبيعي (ملعقة صغيرة)'],
      componentsEn: ['Natural honey (1 tsp)'],
      prepAr: 'وحدها أو في مشروب دافئ. كميات محسوبة — ليست استخداماً مفتوحاً طوال اليوم.',
      prepEn: 'On its own or in a warm drink. Measured amounts — not open all-day use.',
      zone: FoodZone.yellow,
      kcal: 60, proteinG: 0, carbsG: 17, fatG: 0,
    ),
    GuidebookMeal(
      nameAr: 'فاكهة الجلسة الواحدة',
      nameEn: 'One-sitting fruit',
      category: GuidebookCategory.snack,
      componentsAr: ['صنف فاكهة واحد (تفاح/كمثرى/رمان/فراولة…)'],
      componentsEn: ['One fruit type (apple / pear / pomegranate / strawberry…)'],
      prepAr: 'صنف واحد فقط بالجلسة، ويُدخَل تدريجياً مع مراقبة الانتفاخ أو الخمول.',
      prepEn: 'Only one type per sitting, introduced gradually while watching for bloating or sluggishness.',
      zone: FoodZone.yellow,
      kcal: 90, proteinG: 0.5, carbsG: 23, fatG: 0.3,
    ),
    GuidebookMeal(
      nameAr: 'زيتون وجبنة معتقة',
      nameEn: 'Olives and aged cheese',
      category: GuidebookCategory.snack,
      componentsAr: ['زيتون (حفنة صغيرة)', 'جبن معتق (٢٠ غ)'],
      componentsEn: ['Olives (a small handful)', 'Aged cheese (20 g)'],
      prepAr: 'سناك مالح مُشبع: دهن طبيعي أخضر مع لمسة صفراء من الجبن.',
      prepEn: 'A satisfying savory snack: green natural fat with a yellow cheese touch.',
      zone: FoodZone.yellow,
      kcal: 150, proteinG: 6, carbsG: 3, fatG: 13,
    ),

    // ---------------------------------------------------------------- صيام
    GuidebookMeal(
      nameAr: 'سحور المُصبِّر',
      nameEn: 'Sustaining suhoor',
      category: GuidebookCategory.fasting,
      componentsAr: ['أرز بالسمن أو بطاطس بالزبدة', 'تمر (حبتان)', 'ماء وافر'],
      componentsEn: ['Ghee rice or buttered potatoes', 'Dates (2)', 'Plenty of water'],
      prepAr: 'نشوية دسمة بطيئة الهضم + تمر + ماء. سحور يُصبّرك ليوم الاثنين أو الخميس.',
      prepEn: 'A rich slow-digesting starch + dates + water. A suhoor that carries you through a Monday or Thursday fast.',
      zone: FoodZone.green,
      kcal: 450, proteinG: 6, carbsG: 70, fatG: 16,
    ),
    GuidebookMeal(
      nameAr: 'فطور الصائم التدريجي',
      nameEn: 'Gradual fast-breaking',
      category: GuidebookCategory.fasting,
      componentsAr: ['تمر (١–٣ حبات) وماء', 'ثم بعد راحة: وجبة خضراء كاملة'],
      componentsEn: ['Dates (1–3) and water', 'Then, after a pause: a full green meal'],
      prepAr: 'افطر على تمر وماء، تمهّل دقائق، ثم انتقل لوجبة خضراء (أرز ولحم أو سمك). لا تفاجئ معدتك.',
      prepEn: 'Break the fast with dates and water, pause a few minutes, then move to a green meal (rice and meat, or fish). Do not shock your stomach.',
      zone: FoodZone.green,
      kcal: 700, proteinG: 40, carbsG: 85, fatG: 22,
    ),
    GuidebookMeal(
      nameAr: 'عشاء ليلة الصيام',
      nameEn: 'Pre-fast night dinner',
      category: GuidebookCategory.fasting,
      componentsAr: ['وجبة خضراء خفيفة', 'ماء كافٍ قبل النوم'],
      componentsEn: ['A light green meal', 'Enough water before bed'],
      prepAr: 'ليلة الاثنين/الخميس: عشاء أخضر خفيف وماء كافٍ — فيقوم السحور مقام وقوده الأساسي.',
      prepEn: 'On the eve of a fast: a light green dinner and enough water — letting suhoor be the primary fuel.',
      zone: FoodZone.green,
      kcal: 300, proteinG: 12, carbsG: 42, fatG: 10,
    ),
    GuidebookMeal(
      nameAr: 'إفطار الأيام البيض',
      nameEn: 'White-days iftar',
      category: GuidebookCategory.fasting,
      componentsAr: ['تمر وماء', 'حمام أو سمان مع أرز', 'فاكهة (صنف واحد) لاحقاً'],
      componentsEn: ['Dates and water', 'Pigeon or quail with rice', 'One fruit type later'],
      prepAr: 'أيام ١٣/١٤/١٥ هجري: افتح بتمر وماء ثم طبق مناسبة طيّب، وفاكهة بعد ساعة إن اشتهيت.',
      prepEn: 'On Hijri 13/14/15: open with dates and water, then a fine occasion plate, and one fruit an hour later if desired.',
      zone: FoodZone.green,
      kcal: 750, proteinG: 38, carbsG: 92, fatG: 26,
    ),
  ];

  static List<GuidebookMeal> byCategory(GuidebookCategory? category) =>
      category == null
          ? meals
          : meals.where((m) => m.category == category).toList();
}
