import SwiftUI

/// لوحة الألوان والقيم البصرية المشتركة للتطبيق.
enum Theme {
    // أخضر زمردي عميق — الحالات الإيجابية والطيبات.
    static let primary = Color(hex: 0x0F5132)
    // ذهبي رملي دافئ — لمسات ثانوية.
    static let gold = Color(hex: 0xC9A35B)
    // أحمر طوبي مكتوم — الخبائث والتحذير.
    static let khabith = Color(hex: 0x9B2C2C)

    // خلفية عاجية دافئة (فاتح) مع نظير للوضع الليلي.
    static let background = Color(light: 0xFAF7F2, dark: 0x14110D)
    static let surface = Color(light: 0xFFFFFF, dark: 0x1F1B15)
    static let textPrimary = Color(light: 0x1C1A16, dark: 0xF5F1E8)
    static let textSecondary = Color(light: 0x6B6457, dark: 0xB8B0A0)

    /// تدرّج الألوان حسب نسبة الالتزام.
    static func scoreColor(_ score: Int) -> Color {
        switch score {
        case 90...100: return primary
        case 70..<90: return Color(hex: 0x4C9A6A)
        case 50..<70: return gold
        default: return khabith
        }
    }

    static func scoreLabel(_ score: Int) -> String {
        switch score {
        case 90...100: return "ممتاز، وجبة طيبة"
        case 70..<90: return "جيد مع ملاحظات"
        case 50..<70: return "متوسط — راجع الملاحظات"
        default: return "بعيدة عن نظام الطيبات"
        }
    }

    static let cornerRadius: CGFloat = 18
    static let cardShadow = Color.black.opacity(0.06)
}

extension Color {
    init(hex: UInt) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }

    /// لون ديناميكي يتبدّل بين الوضع الفاتح والليلي.
    init(light: UInt, dark: UInt) {
        self.init(uiColor: UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255,
                alpha: 1
            )
        })
    }
}
