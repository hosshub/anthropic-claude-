/// بنك النصائح المعروضة في إشعارات اليوم. كل نصيحة لها تصنيف وقتي يحدّد متى
/// تظهر، ونوع التذكير لا يحتاج نصيحة عشوائية. الخوارزمية في NotificationService
/// تختار نصيحة لم تظهر في آخر ١٠ مرات لكل وقت.
enum TipSlot { morning, afternoon, evening, general, prep, fasting }

class Tip {
  final String id;
  final TipSlot slot;
  final String textAr;
  final String textEn;
  const Tip({
    required this.id,
    required this.slot,
    required this.textAr,
    required this.textEn,
  });

  String text(String locale) => locale == 'en' ? textEn : textAr;
}

class TipsData {
  static const List<Tip> all = [
    // ---- صباح ----
    Tip(
      id: 'm1',
      slot: TipSlot.morning,
      textAr: 'ابدأ يومك بكوب ماء قبل أي شيء.',
      textEn: 'Start your day with a glass of water before anything else.',
    ),
    Tip(
      id: 'm2',
      slot: TipSlot.morning,
      textAr: 'أول وجبة في اليوم هي الأساس — اجعلها بسيطة ومُشبعة.',
      textEn: 'Your first meal anchors the day — keep it simple and filling.',
    ),
    Tip(
      id: 'm3',
      slot: TipSlot.morning,
      textAr: 'القهوة بعد الإفطار أرحم على المعدة من القهوة على معدة فارغة.',
      textEn: 'Coffee after breakfast is gentler on the stomach than on empty.',
    ),
    Tip(
      id: 'm4',
      slot: TipSlot.morning,
      textAr: 'بطاطس مسلوقة + سمن بلدي + قهوة = فطار طيب بدون تعقيد.',
      textEn:
          'Boiled potato + ghee + coffee — a Tayyib breakfast, no complications.',
    ),
    Tip(
      id: 'm5',
      slot: TipSlot.morning,
      textAr: 'الكبدة لفطار قوي — البلدي أفضل من المستوردة.',
      textEn: 'Liver makes a strong breakfast — local is better than imported.',
    ),
    Tip(
      id: 'm6',
      slot: TipSlot.morning,
      textAr: 'صباح اليوم: استمع لجسمك. هل أنت جائع فعلاً أم بدافع العادة؟',
      textEn:
          'This morning: listen to your body. Are you actually hungry, or just on autopilot?',
    ),
    Tip(
      id: 'm7',
      slot: TipSlot.morning,
      textAr: 'تجنّب البقوليات على الفطار حتى لا ترهق هضمك.',
      textEn: 'Skip legumes at breakfast so you don\'t weigh down digestion.',
    ),
    Tip(
      id: 'm8',
      slot: TipSlot.morning,
      textAr: 'وجبة الصباح تحدد توازن الطاقة لبقية اليوم.',
      textEn: "Your morning meal sets the energy balance for the whole day.",
    ),

    // ---- ظهر ----
    Tip(
      id: 'a1',
      slot: TipSlot.afternoon,
      textAr: 'وقت الغداء — اختر طبقاً واحداً واضحاً بدلاً من خلطات كثيرة.',
      textEn: 'Lunchtime — pick one clear dish rather than many mixed sides.',
    ),
    Tip(
      id: 'a2',
      slot: TipSlot.afternoon,
      textAr: 'أرز أبيض + لحم أحمر + زيت زيتون = غداء بسيط ومتوازن.',
      textEn:
          'White rice + red meat + olive oil — a simple, balanced lunch.',
    ),
    Tip(
      id: 'a3',
      slot: TipSlot.afternoon,
      textAr: 'توقف عند الشبع المريح، وليس عند الامتلاء.',
      textEn: 'Stop at comfortable fullness, not at stuffed.',
    ),
    Tip(
      id: 'a4',
      slot: TipSlot.afternoon,
      textAr: 'الفترة بين الغداء والعشاء فرصة لراحة المعدة. تجنّب السناكات.',
      textEn:
          'The gap between lunch and dinner gives your stomach a break — skip the snacks.',
    ),
    Tip(
      id: 'a5',
      slot: TipSlot.afternoon,
      textAr: 'صوّر وجبتك قبل أن تأكلها — لتتعلم عينك ما يبدو طيباً.',
      textEn:
          "Photograph your meal before eating — train your eye to recognize what's Tayyib.",
    ),
    Tip(
      id: 'a6',
      slot: TipSlot.afternoon,
      textAr: 'البقوليات (فول، حمص، عدس) ممنوعة في النظام. ابحث عن بدائل بسيطة.',
      textEn:
          'Legumes (fava, chickpea, lentil) are off the menu — look for simpler alternatives.',
    ),

    // ---- مساء ----
    Tip(
      id: 'e1',
      slot: TipSlot.evening,
      textAr: 'العشاء قبل النوم بساعتين على الأقل — يساعد على نوم أعمق.',
      textEn:
          'Eat dinner at least two hours before bed — it makes for deeper sleep.',
    ),
    Tip(
      id: 'e2',
      slot: TipSlot.evening,
      textAr: 'لو شعرت بجوع مسائي، كوب ماء أو ثمرة تمر تكفي عادةً.',
      textEn:
          'If hunger hits in the evening, a glass of water or a single date usually settles it.',
    ),
    Tip(
      id: 'e3',
      slot: TipSlot.evening,
      textAr: 'تجنّب الفراخ والبيض ليلاً — أكثر الناس يستيقظون بثقل بسببها.',
      textEn:
          'Avoid chicken and eggs at night — they tend to leave most people heavy by morning.',
    ),
    Tip(
      id: 'e4',
      slot: TipSlot.evening,
      textAr: 'العشاء الخفيف خير من العشاء المتأخر.',
      textEn: 'A light dinner beats a late dinner.',
    ),
    Tip(
      id: 'e5',
      slot: TipSlot.evening,
      textAr: 'ماذا أكلت اليوم؟ افتح "اليوم" وراجع تقييم وجباتك.',
      textEn:
          "What did you eat today? Open Today and review your meal scores.",
    ),

    // ---- عام (أي وقت) ----
    Tip(
      id: 'g1',
      slot: TipSlot.general,
      textAr: 'الشبع المريح أهم من التخمة.',
      textEn: 'Comfortable fullness matters more than stuffed.',
    ),
    Tip(
      id: 'g2',
      slot: TipSlot.general,
      textAr: 'ابسط مكوّنات الطبق — كل ما زادت المكوّنات زاد الإرهاق الهضمي.',
      textEn:
          'Simplify the plate — every extra ingredient is extra digestive work.',
    ),
    Tip(
      id: 'g3',
      slot: TipSlot.general,
      textAr: 'لو وجبتك تحتوي صوصاً جاهزاً، فهي ليست طيبة.',
      textEn: "If your meal has a ready-made sauce in it, it's not Tayyib.",
    ),
    Tip(
      id: 'g4',
      slot: TipSlot.general,
      textAr: 'الزيت المهدرج هو العدو الصامت. ابحث عنه في كل ملصق.',
      textEn:
          'Hydrogenated oil is the silent enemy — check for it on every label.',
    ),
    Tip(
      id: 'g5',
      slot: TipSlot.general,
      textAr: 'كرر أفضل ٥ وجبات مريحة لجسمك — لا داعي للتنويع المرهق.',
      textEn:
          'Rotate your 5 best, easiest-on-the-body meals — exhausting variety is optional.',
    ),
    Tip(
      id: 'g6',
      slot: TipSlot.general,
      textAr: 'الاستمرارية أهم من المثالية. خطوة ثابتة كل يوم تكفي.',
      textEn:
          'Consistency beats perfection. One steady step a day is enough.',
    ),
    Tip(
      id: 'g7',
      slot: TipSlot.general,
      textAr: 'راقب ثلاثة: الهضم، الطاقة، النوم. هم الميزان الحقيقي.',
      textEn:
          'Watch three things: digestion, energy, sleep. They are the real scoreboard.',
    ),
    Tip(
      id: 'g8',
      slot: TipSlot.general,
      textAr: 'الأكل عند الجوع الحقيقي. الجوع العاطفي يخدعك كثيراً.',
      textEn:
          'Eat at real hunger. Emotional hunger fools you more often than you think.',
    ),
    Tip(
      id: 'g9',
      slot: TipSlot.general,
      textAr: 'العلامة الصفراء ليست تحريماً — هي دعوة للانتباه.',
      textEn: 'A yellow signal is not a ban — it\'s an invitation to pay attention.',
    ),
    Tip(
      id: 'g10',
      slot: TipSlot.general,
      textAr:
          'لو احترت، اسأل نفسك: هل هذا قريب من حالته الطبيعية أم مصنّع كثيراً؟',
      textEn:
          "If unsure, ask: is this close to its natural state, or heavily processed?",
    ),

    // ---- تحضير الأسبوع (سبت صباحاً) ----
    Tip(
      id: 'p1',
      slot: TipSlot.prep,
      textAr: 'صباح السبت: حضّر بطاطس وأرز يكفيان أيام الأسبوع.',
      textEn:
          'Saturday morning: prep potatoes and rice to carry you through the week.',
    ),
    Tip(
      id: 'p2',
      slot: TipSlot.prep,
      textAr: 'افتح "التحضير الأسبوعي" في الدليل وعلّم مهامك.',
      textEn: "Open Weekly Prep in the Guide and tick off your tasks.",
    ),
    Tip(
      id: 'p3',
      slot: TipSlot.prep,
      textAr: 'تجهيز اللحم مسبقاً يوفر عليك ٤ قرارات في الأسبوع.',
      textEn: 'Prepping meat ahead saves you 4 decisions across the week.',
    ),

    // ---- صيام (ليلة الصيام) ----
    Tip(
      id: 'f1',
      slot: TipSlot.fasting,
      textAr: 'غداً صيام تطوّع. هيئ نيّتك وتذكّر النية من الليل.',
      textEn:
          'Voluntary fast tomorrow — set your intention tonight.',
    ),
    Tip(
      id: 'f2',
      slot: TipSlot.fasting,
      textAr: 'اشرب ماءً جيداً الليلة — يخفف العطش غداً.',
      textEn: 'Drink well tonight — it eases tomorrow\'s thirst.',
    ),
    Tip(
      id: 'f3',
      slot: TipSlot.fasting,
      textAr: 'سحور بسيط (تمر + ماء + قليل من السمن) يكفي.',
      textEn:
          'A simple suhoor — dates + water + a little ghee — is enough.',
    ),
  ];

  static List<Tip> bySlot(TipSlot slot) =>
      all.where((t) => t.slot == slot).toList();
}
