import SwiftUI

/// إشارات النظام البصرية الثلاث (نسخة 2 من الدليل).
enum FoodZone: String, CaseIterable, Codable, Identifiable {
    case green
    case yellow
    case red

    var id: String { rawValue }

    var labelAr: String {
        switch self {
        case .green: return "أخضر"
        case .yellow: return "أصفر"
        case .red: return "أحمر"
        }
    }

    var subtitleAr: String {
        switch self {
        case .green: return "أساس النظام"
        case .yellow: return "بحساب، وحسب استجابة الجسم"
        case .red: return "ممنوع تماماً"
        }
    }

    /// لون الإشارة (يطابق ألوان الدليل).
    var color: Color {
        switch self {
        case .green: return Color(hex: 0x147A4A)
        case .yellow: return Color(hex: 0xC9A35B)
        case .red: return Color(hex: 0x9B2C2C)
        }
    }

    /// قراءة آمنة من نص (يقبل الحروف الكبيرة/الصغيرة).
    static func from(_ raw: String?) -> FoodZone? {
        guard let raw = raw?.lowercased(), !raw.isEmpty else { return nil }
        return FoodZone(rawValue: raw)
    }

    /// اشتقاق المنطقة من حكم v1 القديم (طيّب/خبيث/مشروط) لبيانات ما قبل الترقية.
    static func fromVerdict(_ verdict: Verdict) -> FoodZone {
        switch verdict {
        case .tayyib: return .green
        case .conditional: return .yellow
        case .khabith: return .red
        }
    }
}
