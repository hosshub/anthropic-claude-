import Foundation
import SwiftData

/// تأثير الوجبة على النوم لاحقاً (يُسأل صباح اليوم التالي عادةً).
enum SleepImpact: String, Codable, CaseIterable, Identifiable {
    case positive, neutral, negative, unknown

    var id: String { rawValue }

    var labelAr: String {
        switch self {
        case .positive: return "نوم مريح"
        case .neutral: return "لم ألاحظ فرقاً"
        case .negative: return "تأثر سلباً"
        case .unknown: return "لا أعلم"
        }
    }
}

/// قرار المستخدم في تكرار هذه الوجبة لاحقاً.
enum WorthRepeating: String, Codable, CaseIterable, Identifiable {
    case yes, maybe, no

    var id: String { rawValue }

    var labelAr: String {
        switch self {
        case .yes: return "نعم، أحبها"
        case .maybe: return "ربما"
        case .no: return "لا، تجنّبها"
        }
    }

    var emoji: String {
        switch self {
        case .yes: return "👍"
        case .maybe: return "🤷"
        case .no: return "👎"
        }
    }
}

/// متابعة الجسم بعد الوجبة (الشبع/الانتفاخ/الطاقة/النوم/تكرار الوجبة).
@Model
final class BodyResponse {
    var id: UUID
    var loggedAt: Date
    /// كم ساعة مرّت بين الأكل وتسجيل الملاحظة (للسياق).
    var hoursAfterMeal: Int

    /// ١-٥ (١ لا أبداً، ٣ شبع مريح، ٥ ممتلئ جداً)
    var satisfyingFullness: Int
    /// ٠-٥ (٠ مرتاح تماماً، ٥ ثقل شديد)
    var bloating: Int
    /// ١-٥ (١ نعسان جداً، ٥ نشيط جداً)
    var energyLevel: Int

    var sleepImpactRaw: String
    var worthRepeatingRaw: String
    var notes: String?

    /// علاقة عكسية مع `Meal.bodyResponse`.
    var meal: Meal?

    var sleepImpact: SleepImpact {
        get { SleepImpact(rawValue: sleepImpactRaw) ?? .unknown }
        set { sleepImpactRaw = newValue.rawValue }
    }

    var worthRepeating: WorthRepeating {
        get { WorthRepeating(rawValue: worthRepeatingRaw) ?? .maybe }
        set { worthRepeatingRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        loggedAt: Date = .now,
        hoursAfterMeal: Int = 0,
        satisfyingFullness: Int = 3,
        bloating: Int = 0,
        energyLevel: Int = 3,
        sleepImpact: SleepImpact = .unknown,
        worthRepeating: WorthRepeating = .maybe,
        notes: String? = nil
    ) {
        self.id = id
        self.loggedAt = loggedAt
        self.hoursAfterMeal = hoursAfterMeal
        self.satisfyingFullness = max(1, min(5, satisfyingFullness))
        self.bloating = max(0, min(5, bloating))
        self.energyLevel = max(1, min(5, energyLevel))
        self.sleepImpactRaw = sleepImpact.rawValue
        self.worthRepeatingRaw = worthRepeating.rawValue
        self.notes = notes
    }
}
