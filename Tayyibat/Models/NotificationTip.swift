import Foundation
import SwiftData

enum TipCategory: String, Codable, CaseIterable {
    case morning    // صباحية 8-10ص
    case afternoon  // ظهرية 12-3م
    case evening    // مسائية 5-9م
    case general    // عامة
    case fasting    // صيام

    var labelAr: String {
        switch self {
        case .morning: return "صباحية"
        case .afternoon: return "ظهرية"
        case .evening: return "مسائية"
        case .general: return "عامة"
        case .fasting: return "صيام"
        }
    }
}

@Model
final class NotificationTip {
    @Attribute(.unique) var id: UUID
    var categoryRaw: String
    var textAr: String
    var lastShownAt: Date?

    var category: TipCategory {
        get { TipCategory(rawValue: categoryRaw) ?? .general }
        set { categoryRaw = newValue.rawValue }
    }

    init(id: UUID = UUID(), category: TipCategory, textAr: String, lastShownAt: Date? = nil) {
        self.id = id
        self.categoryRaw = category.rawValue
        self.textAr = textAr
        self.lastShownAt = lastShownAt
    }
}
