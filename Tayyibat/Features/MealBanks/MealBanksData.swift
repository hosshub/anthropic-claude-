import Foundation

/// عنصر داخل بنك وجبات (فكرة جاهزة).
struct MealBankItem: Identifiable, Hashable {
    let id = UUID()
    let nameAr: String
    let compositionAr: String
    let noteAr: String?
    let zone: FoodZone
}

/// بنك وجبات بحسب وقت اليوم.
struct MealBank: Identifiable, Hashable {
    let id = UUID()
    let emoji: String
    let titleAr: String
    let subtitleAr: String
    let items: [MealBankItem]
}

enum MealBanksData {
    static let banks: [MealBank] = [
        MealBank(
            emoji: "🌅",
            titleAr: "بنك الفطار",
            subtitleAr: "أفكار سريعة ومشبعة",
            items: [
                MealBankItem(nameAr: "تمر وماء",
                             compositionAr: "بضع تمرات + كوب ماء",
                             noteAr: "بسيط وسريع — مناسب عند الحاجة لطاقة خفيفة",
                             zone: .yellow),
                MealBankItem(nameAr: "بطاطس مهروسة بزبدة طبيعية",
                             compositionAr: "بطاطس مسلوقة + زبدة بلدية",
                             noteAr: "فطور مشبع وبسيط المكونات",
                             zone: .green),
                MealBankItem(nameAr: "أرز بسيط بالسمن",
                             compositionAr: "أرز أبيض + سمن بلدي",
                             noteAr: "للفطار المُشبع الذي يكفي حتى الغداء",
                             zone: .green),
                MealBankItem(nameAr: "توست كامل وجبنة معتقة",
                             compositionAr: "توست حبوب كاملة + جبن معتق صلب (شيدر / جودة)",
                             noteAr: "باعتدال — من المنطقة الصفراء وحسب الهضم",
                             zone: .yellow)
            ]
        ),
        MealBank(
            emoji: "🍽",
            titleAr: "بنك الغداء",
            subtitleAr: "أطباق رئيسية واضحة",
            items: [
                MealBankItem(nameAr: "أرز ولحم",
                             compositionAr: "أرز + لحم أحمر مستوٍ تماماً",
                             noteAr: nil,
                             zone: .green),
                MealBankItem(nameAr: "كبدة وبطاطس",
                             compositionAr: "كبدة + بطاطس",
                             noteAr: nil,
                             zone: .green),
                MealBankItem(nameAr: "سمك وأرز",
                             compositionAr: "سمك (مشوي أو مقلي) + أرز",
                             noteAr: nil,
                             zone: .green),
                MealBankItem(nameAr: "كوارع أو حمام",
                             compositionAr: "كوارع أو حمام مع نشوية بسيطة",
                             noteAr: "وجبة مشبعة لمن يحبّها",
                             zone: .green)
            ]
        ),
        MealBank(
            emoji: "🌙",
            titleAr: "بنك العشاء",
            subtitleAr: "خفيف وواضح",
            items: [
                MealBankItem(nameAr: "بطاطس مسلوقة بزبدة",
                             compositionAr: "بطاطس مسلوقة + زبدة طبيعية",
                             noteAr: "مناسب عند الحاجة لعشاء بسيط ومريح",
                             zone: .green),
                MealBankItem(nameAr: "أرز خفيف",
                             compositionAr: "أرز أبيض بسيط مع سمن أو زيت زيتون",
                             noteAr: "وجبة صغيرة بدون مكونات كثيرة",
                             zone: .green),
                MealBankItem(nameAr: "جبنة معتقة مع توست كامل",
                             compositionAr: "جبن معتق + توست حبوب كاملة",
                             noteAr: "عند تحمّل الأجبان وضمن الاعتدال",
                             zone: .yellow),
                MealBankItem(nameAr: "تمر وماء",
                             compositionAr: "بضع تمرات + كوب ماء",
                             noteAr: "عند احتياج بسيط دون وجبة كبيرة",
                             zone: .yellow)
            ]
        ),
        MealBank(
            emoji: "🍯",
            titleAr: "بنك السناك والحلويات",
            subtitleAr: "باعتدال — ليس عادة مستمرة طول اليوم",
            items: [
                MealBankItem(nameAr: "تمر",
                             compositionAr: "كمية صغيرة عند الحاجة للطاقة",
                             noteAr: "من المنطقة الصفراء — كميات بسيطة",
                             zone: .yellow),
                MealBankItem(nameAr: "عسل طبيعي",
                             compositionAr: "ملعقة صغيرة داخل وصفة أو وحده",
                             noteAr: "كميات محسوبة، وليس استخداماً مفتوحاً",
                             zone: .yellow),
                MealBankItem(nameAr: "فاكهة طبيعية",
                             compositionAr: "صنف واحد بالجلسة (مثلاً: تفاحة أو موزة)",
                             noteAr: "تدخل تدريجياً مع مراقبة الانتفاخ",
                             zone: .yellow)
            ]
        )
    ]
}
