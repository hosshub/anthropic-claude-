import SwiftUI

/// مرحلة من برنامج الـ١٥ يوم (٤ مراحل تدريجية).
struct ProgramPhase: Identifiable, Hashable {
    let id = UUID()
    let number: Int
    let daysRangeAr: String
    let dayRange: ClosedRange<Int>
    let titleAr: String
    let focusAr: String
    let color: Color
}

/// يوم من البرنامج بمعلوماته (التركيز، وجبة مقترحة، نصيحة).
struct ProgramDay: Identifiable, Hashable {
    let id = UUID()
    let day: Int
    let focusAr: String
    let exampleMealAr: String
    let tipAr: String
}

/// حالة مشاركة المستخدم في البرنامج.
enum ProgramStatus: Equatable {
    case notStarted
    case inProgress(day: Int)   // 1...15
    case completed
}

enum Program15DayData {
    static let titleAr = "برنامج ١٥ يوم — الرحلة بدل الجدول الممل"
    static let philosophyAr = "ليس جدولاً جامداً، بل رحلة تدريجية. كل مرحلة تبني على ما قبلها."

    static let phases: [ProgramPhase] = [
        ProgramPhase(number: 1, daysRangeAr: "الأيام ١–٣", dayRange: 1...3,
                     titleAr: "تهدئة الفوضى الغذائية",
                     focusAr: "وجبات بسيطة، مكونات قليلة، وتقليل المُصنّع.",
                     color: Color(hex: 0xA8D5BA)),
        ProgramPhase(number: 2, daysRangeAr: "الأيام ٤–٧", dayRange: 4...7,
                     titleAr: "بناء الروتين",
                     focusAr: "الأكل عند الجوع الحقيقي وتقليل السناكات.",
                     color: Color(hex: 0x7FBC8C)),
        ProgramPhase(number: 3, daysRangeAr: "الأيام ٨–١١", dayRange: 8...11,
                     titleAr: "تنظيم البروتين",
                     focusAr: "استخدام البروتين الحيواني بذكاء حسب الاستجابة.",
                     color: Color(hex: 0x4F9C5F)),
        ProgramPhase(number: 4, daysRangeAr: "الأيام ١٢–١٥", dayRange: 12...15,
                     titleAr: "تثبيت النظام",
                     focusAr: "معرفة الوجبات التي تعطي راحة وشبعاً بدون ثقل.",
                     color: Color(hex: 0x147A4A))
    ]

    static let days: [ProgramDay] = [
        ProgramDay(day: 1, focusAr: "بداية هادئة",
                   exampleMealAr: "أرز بسيط + دهون طبيعية",
                   tipAr: "ابدأ بوجبة واحدة بسيطة اليوم. لا تحاول تغيير كل شيء دفعة واحدة."),
        ProgramDay(day: 2, focusAr: "تقليل السناكات",
                   exampleMealAr: "بطاطس مسلوقة أو مشوية",
                   tipAr: "اترك ساعتين على الأقل بين الوجبات اليوم."),
        ProgramDay(day: 3, focusAr: "مراقبة الهضم",
                   exampleMealAr: "أرز + لحم بسيط",
                   tipAr: "بعد كل وجبة اليوم، اسأل نفسك: شعور مريح أم ثقل؟"),
        ProgramDay(day: 4, focusAr: "تثبيت الجوع الحقيقي",
                   exampleMealAr: "بطاطس + زبدة طبيعية",
                   tipAr: "لا تأكل اليوم إلا عند جوع واضح، ليس بسبب الوقت."),
        ProgramDay(day: 5, focusAr: "وجبة مشبعة",
                   exampleMealAr: "أرز + كبدة",
                   tipAr: "اختر وجبة واحدة تشعرك بالشبع المريح وكرّرها."),
        ProgramDay(day: 6, focusAr: "يوم أخفّ",
                   exampleMealAr: "بطاطس + زيت زيتون",
                   tipAr: "اليوم وجبتان فقط، خفيفتان."),
        ProgramDay(day: 7, focusAr: "مراجعة أول أسبوع",
                   exampleMealAr: "طبق بسيط مكرّر ومريح",
                   tipAr: "راجع سجلك: أي وجبات أعطتك أفضل شعور؟"),
        ProgramDay(day: 8, focusAr: "إدخال بروتين",
                   exampleMealAr: "لحم أحمر + أرز",
                   tipAr: "ركّز على بروتين عالي الجودة اليوم."),
        ProgramDay(day: 9, focusAr: "راحة هضمية",
                   exampleMealAr: "بطاطس + مشروب بسيط",
                   tipAr: "اليوم يوم خفيف، أعطِ جهازك الهضمي راحة."),
        ProgramDay(day: 10, focusAr: "بروتين مناسب",
                   exampleMealAr: "سمك + أرز",
                   tipAr: "جرّب نوعاً مختلفاً من البروتين اليوم."),
        ProgramDay(day: 11, focusAr: "أكل منزلي",
                   exampleMealAr: "كوارع أو لحم + أرز",
                   tipAr: "لا أكل خارجي اليوم، فقط طبخ منزلي."),
        ProgramDay(day: 12, focusAr: "تثبيت المسموح",
                   exampleMealAr: "طبقك الأفضل من الأيام السابقة",
                   tipAr: "أعد تكرار الوجبة الأكثر راحة لك."),
        ProgramDay(day: 13, focusAr: "تقليل التعقيد",
                   exampleMealAr: "وجبة بمكونات أقل",
                   tipAr: "اليوم: لا تتجاوز ٣ مكونات في كل وجبة."),
        ProgramDay(day: 14, focusAr: "اختبار الاستمرارية",
                   exampleMealAr: "وجبتان أو ثلاث حسب الجوع",
                   tipAr: "اسمع جسمك، كم وجبة يحتاج فعلاً؟"),
        ProgramDay(day: 15, focusAr: "خطة ما بعد البرنامج",
                   exampleMealAr: "اختر ٥ وجبات مريحة وكرّرها",
                   tipAr: "حدّد قائمتك الذهبية للأيام القادمة.")
    ]

    static func phase(for day: Int) -> ProgramPhase {
        phases.first(where: { $0.dayRange.contains(day) }) ?? phases[0]
    }

    static func day(_ day: Int) -> ProgramDay? {
        days.first(where: { $0.day == day })
    }
}

extension UserProfile {
    /// الحالة الحالية للبرنامج بناءً على `programStartedAt`.
    var programStatus: ProgramStatus {
        guard let start = programStartedAt else { return .notStarted }
        let cal = Calendar.current
        let startDay = cal.startOfDay(for: start)
        let today = cal.startOfDay(for: .now)
        let elapsed = (cal.dateComponents([.day], from: startDay, to: today).day ?? 0) + 1
        if elapsed < 1 { return .inProgress(day: 1) }
        if elapsed > 15 { return .completed }
        return .inProgress(day: elapsed)
    }
}
