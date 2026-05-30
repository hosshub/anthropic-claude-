import Foundation

/// نموذج بيانات ملف القواعد (نسخة 2 — إشارات ثلاثية).
struct RulesData: Codable {
    var version: String
    var systemName: String
    var zones: ZonesContainer
    var goldenRules: [GoldenRule]
    var philosophyCards: [PhilosophyCard]
    var weeklyPrep: [WeeklyPrepTask]
    var commonMistakes: [CommonMistake]
    var medicalDisclaimer: String

    struct ZonesContainer: Codable {
        var green: Zone
        var yellow: Zone
        var red: Zone
    }

    struct Zone: Codable {
        var labelAr: String
        var subtitleAr: String
        var watchwordAr: String?
        var groups: [ZoneGroup]

        enum CodingKeys: String, CodingKey {
            case labelAr = "label_ar"
            case subtitleAr = "subtitle_ar"
            case watchwordAr = "watchword_ar"
            case groups
        }
    }

    /// مجموعة داخل منطقة. خضراء/حمراء تستخدم `categoryAr` + `items`،
    /// والصفراء تستخدم `itemAr` + `examplesAr` + `guidanceAr`.
    struct ZoneGroup: Codable, Identifiable {
        var id = UUID()
        var categoryAr: String?
        var items: [String]?
        var itemAr: String?
        var examplesAr: String?
        var guidanceAr: String?

        enum CodingKeys: String, CodingKey {
            case categoryAr = "category_ar"
            case items
            case itemAr = "item_ar"
            case examplesAr = "examples_ar"
            case guidanceAr = "guidance_ar"
        }
    }

    struct GoldenRule: Codable, Identifiable {
        var id: Int
        var ruleAr: String
        var applicationAr: String
        var icon: String

        enum CodingKeys: String, CodingKey {
            case id
            case ruleAr = "rule_ar"
            case applicationAr = "application_ar"
            case icon
        }
    }

    struct PhilosophyCard: Codable, Identifiable {
        var id: Int
        var titleAr: String
        var bodyAr: String

        enum CodingKeys: String, CodingKey {
            case id
            case titleAr = "title_ar"
            case bodyAr = "body_ar"
        }
    }

    struct WeeklyPrepTask: Codable, Identifiable {
        var id: String
        var titleAr: String
        var estimatedMinutes: Int?
        var validDays: Int
        var category: String

        enum CodingKeys: String, CodingKey {
            case id
            case titleAr = "title_ar"
            case estimatedMinutes = "estimated_minutes"
            case validDays = "valid_days"
            case category
        }
    }

    struct CommonMistake: Codable, Identifiable {
        var id = UUID()
        var mistakeAr: String
        var correctionAr: String

        enum CodingKeys: String, CodingKey {
            case mistakeAr = "mistake_ar"
            case correctionAr = "correction_ar"
        }
    }

    enum CodingKeys: String, CodingKey {
        case version, zones
        case systemName = "system_name"
        case goldenRules = "golden_rules"
        case philosophyCards = "philosophy_cards"
        case weeklyPrep = "weekly_prep"
        case commonMistakes = "common_mistakes"
        case medicalDisclaimer = "medical_disclaimer"
    }
}

/// يحمّل ملف القواعد ويوفّره للواجهات وللـ prompt.
final class RulesService {
    static let shared = RulesService()

    private(set) var rules: RulesData

    /// النص الكامل لقواعد JSON كي يُضمَّن في الـ prompt المرسل للنموذج.
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
}
