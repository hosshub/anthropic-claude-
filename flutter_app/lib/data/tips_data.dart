/// بنك النصائح المعروضة في إشعارات اليوم. كل نصيحة لها تصنيف وقتي يحدّد متى
/// تظهر، ونوع التذكير لا يحتاج نصيحة عشوائية. الخوارزمية في NotificationService
/// تختار نصيحة لم تظهر في آخر ١٠ مرات لكل وقت.
enum TipSlot { morning, afternoon, evening, general, prep, fasting }

class Tip {
  final String id;
  final TipSlot slot;
  final String textAr;
  const Tip({required this.id, required this.slot, required this.textAr});
}

class TipsData {
  static const List<Tip> all = [
    // ---- صباح ----
    Tip(id: 'm1', slot: TipSlot.morning, textAr: 'ابدأ يومك بكوب ماء قبل أي شيء.'),
    Tip(id: 'm2', slot: TipSlot.morning, textAr: 'أول وجبة في اليوم هي الأساس — اجعلها بسيطة ومُشبعة.'),
    Tip(id: 'm3', slot: TipSlot.morning, textAr: 'القهوة بعد الإفطار أرحم على المعدة من القهوة على معدة فارغة.'),
    Tip(id: 'm4', slot: TipSlot.morning, textAr: 'بطاطس مسلوقة + سمن بلدي + قهوة = فطار طيب بدون تعقيد.'),
    Tip(id: 'm5', slot: TipSlot.morning, textAr: 'الكبدة لفطار قوي — البلدي أفضل من المستوردة.'),
    Tip(id: 'm6', slot: TipSlot.morning, textAr: 'صباح اليوم: استمع لجسمك. هل أنت جائع فعلاً أم بدافع العادة؟'),
    Tip(id: 'm7', slot: TipSlot.morning, textAr: 'تجنّب البقوليات على الفطار حتى لا ترهق هضمك.'),
    Tip(id: 'm8', slot: TipSlot.morning, textAr: 'وجبة الصباح تحدد توازن الطاقة لبقية اليوم.'),

    // ---- ظهر ----
    Tip(id: 'a1', slot: TipSlot.afternoon, textAr: 'وقت الغداء — اختر طبقاً واحداً واضحاً بدلاً من خلطات كثيرة.'),
    Tip(id: 'a2', slot: TipSlot.afternoon, textAr: 'أرز أبيض + لحم أحمر + زيت زيتون = غداء بسيط ومتوازن.'),
    Tip(id: 'a3', slot: TipSlot.afternoon, textAr: 'توقف عند الشبع المريح، وليس عند الامتلاء.'),
    Tip(id: 'a4', slot: TipSlot.afternoon, textAr: 'الفترة بين الغداء والعشاء فرصة لراحة المعدة. تجنّب السناكات.'),
    Tip(id: 'a5', slot: TipSlot.afternoon, textAr: 'صوّر وجبتك قبل أن تأكلها — لتتعلم عينك ما يبدو طيباً.'),
    Tip(id: 'a6', slot: TipSlot.afternoon, textAr: 'البقوليات (فول، حمص، عدس) ممنوعة في النظام. ابحث عن بدائل بسيطة.'),

    // ---- مساء ----
    Tip(id: 'e1', slot: TipSlot.evening, textAr: 'العشاء قبل النوم بساعتين على الأقل — يساعد على نوم أعمق.'),
    Tip(id: 'e2', slot: TipSlot.evening, textAr: 'لو شعرت بجوع مسائي، كوب ماء أو ثمرة تمر تكفي عادةً.'),
    Tip(id: 'e3', slot: TipSlot.evening, textAr: 'تجنّب الفراخ والبيض ليلاً — أكثر الناس يستيقظون بثقل بسببها.'),
    Tip(id: 'e4', slot: TipSlot.evening, textAr: 'العشاء الخفيف خير من العشاء المتأخر.'),
    Tip(id: 'e5', slot: TipSlot.evening, textAr: 'ماذا أكلت اليوم؟ افتح "اليوم" وراجع تقييم وجباتك.'),

    // ---- عام (أي وقت) ----
    Tip(id: 'g1', slot: TipSlot.general, textAr: 'الشبع المريح أهم من التخمة.'),
    Tip(id: 'g2', slot: TipSlot.general, textAr: 'ابسط مكوّنات الطبق — كل ما زادت المكوّنات زاد الإرهاق الهضمي.'),
    Tip(id: 'g3', slot: TipSlot.general, textAr: 'لو وجبتك تحتوي صوصاً جاهزاً، فهي ليست طيبة.'),
    Tip(id: 'g4', slot: TipSlot.general, textAr: 'الزيت المهدرج هو العدو الصامت. ابحث عنه في كل ملصق.'),
    Tip(id: 'g5', slot: TipSlot.general, textAr: 'كرر أفضل ٥ وجبات مريحة لجسمك — لا داعي للتنويع المرهق.'),
    Tip(id: 'g6', slot: TipSlot.general, textAr: 'الاستمرارية أهم من المثالية. خطوة ثابتة كل يوم تكفي.'),
    Tip(id: 'g7', slot: TipSlot.general, textAr: 'راقب ثلاثة: الهضم، الطاقة، النوم. هم الميزان الحقيقي.'),
    Tip(id: 'g8', slot: TipSlot.general, textAr: 'الأكل عند الجوع الحقيقي. الجوع العاطفي يخدعك كثيراً.'),
    Tip(id: 'g9', slot: TipSlot.general, textAr: 'العلامة الصفراء ليست تحريماً — هي دعوة للانتباه.'),
    Tip(id: 'g10', slot: TipSlot.general, textAr: 'لو احترت، اسأل نفسك: هل هذا قريب من حالته الطبيعية أم مصنّع كثيراً؟'),

    // ---- تحضير الأسبوع (سبت صباحاً) ----
    Tip(id: 'p1', slot: TipSlot.prep, textAr: 'صباح السبت: حضّر بطاطس وأرز يكفيان أيام الأسبوع.'),
    Tip(id: 'p2', slot: TipSlot.prep, textAr: 'افتح "التحضير الأسبوعي" في الدليل وعلّم مهامك.'),
    Tip(id: 'p3', slot: TipSlot.prep, textAr: 'تجهيز اللحم مسبقاً يوفر عليك ٤ قرارات في الأسبوع.'),

    // ---- صيام (ليلة الصيام) ----
    Tip(id: 'f1', slot: TipSlot.fasting, textAr: 'غداً صيام تطوّع. هيئ نيّتك وتذكّر النية من الليل.'),
    Tip(id: 'f2', slot: TipSlot.fasting, textAr: 'اشرب ماءً جيداً الليلة — يخفف العطش غداً.'),
    Tip(id: 'f3', slot: TipSlot.fasting, textAr: 'سحور بسيط (تمر + ماء + قليل من السمن) يكفي.'),
  ];

  static List<Tip> bySlot(TipSlot slot) =>
      all.where((t) => t.slot == slot).toList();
}
