import SwiftUI

/// حكم النظام على عنصر الطعام.
enum Verdict: String, CaseIterable, Codable, Identifiable {
    case tayyib       // طيّب
    case khabith      // خبيث
    case conditional  // مشروط

    var id: String { rawValue }

    var labelAr: String {
        switch self {
        case .tayyib: return "طيّب"
        case .khabith: return "خبيث"
        case .conditional: return "مشروط"
        }
    }

    var symbol: String {
        switch self {
        case .tayyib: return "checkmark.seal.fill"
        case .khabith: return "xmark.seal.fill"
        case .conditional: return "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .tayyib: return Theme.primary
        case .khabith: return Theme.khabith
        case .conditional: return Theme.gold
        }
    }

    /// تحويل آمن من النص القادم من النموذج/الـ API.
    static func from(_ raw: String) -> Verdict {
        Verdict(rawValue: raw.lowercased()) ?? .conditional
    }
}
