import Foundation

/// نتيجة تحليل الوجبة كما تصل من Claude (DTO قابل للترميز).
/// فك الترميز متسامح: المفاتيح الناقصة تأخذ قيماً افتراضية بدل أن يفشل التحليل.
struct AnalysisResult: Codable {
    var identifiedItems: [Item]
    var overallScore: Int
    var scoreLabelAr: String
    var scoreExplanationAr: String
    var improvementSuggestionsAr: [String]
    var warnings: [String]

    struct Item: Codable, Identifiable {
        var id = UUID()
        var nameAr: String
        var confidence: Double
        var estimatedPortion: String
        var verdict: String
        var category: String
        var reasoningAr: String
        var ruleViolated: String?

        enum CodingKeys: String, CodingKey {
            case nameAr = "name_ar"
            case confidence
            case estimatedPortion = "estimated_portion"
            case verdict
            case category
            case reasoningAr = "reasoning_ar"
            case ruleViolated = "rule_violated"
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            id = UUID()
            nameAr = try c.decodeIfPresent(String.self, forKey: .nameAr) ?? "غير معروف"
            confidence = try c.decodeIfPresent(Double.self, forKey: .confidence) ?? 0.5
            estimatedPortion = try c.decodeIfPresent(String.self, forKey: .estimatedPortion) ?? "متوسطة"
            verdict = try c.decodeIfPresent(String.self, forKey: .verdict) ?? "conditional"
            category = try c.decodeIfPresent(String.self, forKey: .category) ?? "عام"
            reasoningAr = try c.decodeIfPresent(String.self, forKey: .reasoningAr) ?? ""
            ruleViolated = try c.decodeIfPresent(String.self, forKey: .ruleViolated)
        }
    }

    enum CodingKeys: String, CodingKey {
        case identifiedItems = "identified_items"
        case overallScore = "overall_score"
        case scoreLabelAr = "score_label_ar"
        case scoreExplanationAr = "score_explanation_ar"
        case improvementSuggestionsAr = "improvement_suggestions_ar"
        case warnings
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        identifiedItems = try c.decodeIfPresent([Item].self, forKey: .identifiedItems) ?? []
        overallScore = try c.decodeIfPresent(Int.self, forKey: .overallScore) ?? 0
        scoreLabelAr = try c.decodeIfPresent(String.self, forKey: .scoreLabelAr) ?? ""
        scoreExplanationAr = try c.decodeIfPresent(String.self, forKey: .scoreExplanationAr) ?? ""
        improvementSuggestionsAr = try c.decodeIfPresent([String].self, forKey: .improvementSuggestionsAr) ?? []
        warnings = try c.decodeIfPresent([String].self, forKey: .warnings) ?? []
    }
}

extension AnalysisResult {
    /// تحويل إلى نموذج SwiftData قابل للحفظ.
    func toMeal(imageData: Data, capturedAt: Date = .now) -> Meal {
        let foodItems = identifiedItems.map { item in
            FoodItem(
                nameAr: item.nameAr,
                verdict: Verdict.from(item.verdict),
                category: item.category,
                reasoning: item.reasoningAr,
                confidence: item.confidence,
                estimatedPortion: item.estimatedPortion,
                ruleViolated: item.ruleViolated
            )
        }
        return Meal(
            capturedAt: capturedAt,
            imageData: imageData,
            overallScore: overallScore,
            scoreLabelAr: scoreLabelAr,
            scoreExplanationAr: scoreExplanationAr,
            improvementSuggestions: improvementSuggestionsAr,
            items: foodItems
        )
    }
}
