import Foundation
import SwiftData

enum NotificationIntensity: String, Codable, CaseIterable {
    case low      // قليل ~1/يوم
    case medium   // متوسط ~3/يوم
    case high     // مكثّف 5+/يوم

    var labelAr: String {
        switch self {
        case .low: return "قليل"
        case .medium: return "متوسط"
        case .high: return "مكثّف"
        }
    }

    /// عدد النصائح اليومية المقابلة للشدّة.
    var dailyTipCount: Int {
        switch self {
        case .low: return 1
        case .medium: return 3
        case .high: return 5
        }
    }
}

enum UserGoal: String, Codable, CaseIterable {
    case adherence  // متابعة الالتزام
    case weight     // تتبّع الوزن

    var labelAr: String {
        switch self {
        case .adherence: return "متابعة الالتزام"
        case .weight: return "تتبّع الوزن"
        }
    }
}

@Model
final class UserProfile {
    var name: String
    var age: Int?
    var goalRaw: String
    var disclaimerAcceptedAt: Date?

    // الإشعارات
    var notificationsEnabled: Bool
    var mealRemindersEnabled: Bool
    var tipsEnabled: Bool
    var fastingRemindersEnabled: Bool
    var logRemindersEnabled: Bool
    var dailyTipsIntensityRaw: String
    var quietHoursStart: Date
    var quietHoursEnd: Date
    /// النوافذ الزمنية المختارة للتذكيرات المرنة (ساعات اليوم 0-23).
    var reminderHours: [Int]

    var goal: UserGoal {
        get { UserGoal(rawValue: goalRaw) ?? .adherence }
        set { goalRaw = newValue.rawValue }
    }

    var dailyTipsIntensity: NotificationIntensity {
        get { NotificationIntensity(rawValue: dailyTipsIntensityRaw) ?? .medium }
        set { dailyTipsIntensityRaw = newValue.rawValue }
    }

    init(
        name: String = "",
        age: Int? = nil,
        goal: UserGoal = .adherence,
        disclaimerAcceptedAt: Date? = nil
    ) {
        self.name = name
        self.age = age
        self.goalRaw = goal.rawValue
        self.disclaimerAcceptedAt = disclaimerAcceptedAt
        self.notificationsEnabled = false
        self.mealRemindersEnabled = true
        self.tipsEnabled = true
        self.fastingRemindersEnabled = true
        self.logRemindersEnabled = true
        self.dailyTipsIntensityRaw = NotificationIntensity.medium.rawValue
        // افتراضي: لا تزعج من 11 مساءً حتى 7 صباحاً.
        let cal = Calendar.current
        self.quietHoursStart = cal.date(from: DateComponents(hour: 23, minute: 0)) ?? .now
        self.quietHoursEnd = cal.date(from: DateComponents(hour: 7, minute: 0)) ?? .now
        self.reminderHours = [11, 16, 20]
    }
}
