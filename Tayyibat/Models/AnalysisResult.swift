import Foundation

/// نتيجة تحليل الوجبة كما تصل من Claude (DTO قابل للترميز).
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
    }

    enum CodingKeys: String, CodingKey {
        case identifiedItems = "identified_items"
        case overallScore = "overall_score"
        case scoreLabelAr = "score_label_ar"
        case scoreExplanationAr = "score_explanation_ar"
        case improvementSuggestionsAr = "improvement_suggestions_ar"
        case warnings
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
