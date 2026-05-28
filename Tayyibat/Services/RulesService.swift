import Foundation

/// نموذج بيانات ملف القواعد المرفق.
struct RulesData: Codable {
    var version: String
    var systemName: String
    var categories: [Category]
    var behavioralRules: [String]
    var fasting: Fasting
    var medicalDisclaimer: String

    struct Category: Codable, Identifiable {
        var id: String
        var nameAr: String
        var icon: String
        var note: String?
        var allowed: [String]
        var forbidden: [String]

        enum CodingKeys: String, CodingKey {
            case id, icon, note, allowed, forbidden
            case nameAr = "name_ar"
        }
    }

    struct Fasting: Codable {
        var weekly: [String]
        var whiteDaysHijri: [Int]
        var notes: String

        enum CodingKeys: String, CodingKey {
            case weekly, notes
            case whiteDaysHijri = "white_days_hijri"
        }
    }

    enum CodingKeys: String, CodingKey {
        case version, categories, fasting
        case systemName = "system_name"
        case behavioralRules = "behavioral_rules"
        case medicalDisclaimer = "medical_disclaimer"
    }
}

/// يحمّل ملف القواعد ويوفّره للواجهات وللـ prompt.
@Observable
final class RulesService {
    static let shared = RulesService()

    private(set) var rules: RulesData

    /// النص الكامل لقواعد JSON كي يُضمَّن في الـ prompt المرسل لـ Claude.
    let rawJSON: String

    private init() {
        guard let url = Bundle.main.url(forResource: "tayyibat_rules", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            fatalError("تعذّر العثور على ملف القواعد tayyibat_rules.json")
        }
        self.rawJSON = String(data: data, encoding: .utf8) ?? "{}"
        do {
            self.rules = try JSONDecoder().decode(RulesData.self, from: data)
        } catch {
            fatalError("تعذّر فك ترميز ملف القواعد: \(error)")
        }
    }

    /// بحث بسيط: هل هذا الطعام مسموح؟ يرجع الفئة والحكم إن وُجد.
    func lookup(_ query: String) -> [(category: RulesData.Category, term: String, allowed: Bool)] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return [] }
        var results: [(RulesData.Category, String, Bool)] = []
        for category in rules.categories {
            for term in category.allowed where term.contains(q) {
                results.append((category, term, true))
            }
            for term in category.forbidden where term.contains(q) {
                results.append((category, term, false))
            }
        }
        return results
    }
}
