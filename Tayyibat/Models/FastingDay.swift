import Foundation
import SwiftData

/// نوع يوم الصيام المقترح/المسجّل.
enum FastingType: String, Codable, CaseIterable {
    case monday          // الإثنين
    case thursday        // الخميس
    case whiteDay        // الأيام البيض (13/14/15 هجرياً)
    case intermittent    // صيام متقطع
    case voluntary       // تطوّعي آخر

    var labelAr: String {
        switch self {
        case .monday: return "صيام الإثنين"
        case .thursday: return "صيام الخميس"
        case .whiteDay: return "الأيام البيض"
        case .intermittent: return "صيام متقطع"
        case .voluntary: return "صيام تطوّعي"
        }
    }
}

@Model
final class FastingDay {
    var date: Date
    var typeRaw: String
    var completed: Bool

    var type: FastingType {
        get { FastingType(rawValue: typeRaw) ?? .voluntary }
        set { typeRaw = newValue.rawValue }
    }

    init(date: Date, type: FastingType, completed: Bool = false) {
        self.date = Calendar.current.startOfDay(for: date)
        self.typeRaw = type.rawValue
        self.completed = completed
    }
}
