import XCTest
@testable import Tayyibat

final class AnalysisDecodeTests: XCTestCase {

    private let sample = """
    {
      "identified_items": [
        {
          "name_ar": "أرز",
          "confidence": 0.92,
          "estimated_portion": "متوسطة",
          "verdict": "tayyib",
          "category": "نشويات",
          "reasoning_ar": "الأرز من النشويات المسموحة",
          "rule_violated": null
        },
        {
          "name_ar": "دجاج",
          "confidence": 0.8,
          "estimated_portion": "حصة كبيرة",
          "verdict": "khabith",
          "category": "دواجن",
          "reasoning_ar": "الدواجن من الخبائث",
          "rule_violated": "الدواجن ممنوعة"
        }
      ],
      "overall_score": 55,
      "score_label_ar": "متوسط",
      "score_explanation_ar": "الطبق يحتوي على عنصر ممنوع.",
      "improvement_suggestions_ar": ["استبدل الدجاج بلحم ضأن"],
      "warnings": []
    }
    """

    func testDecodesAllFields() throws {
        let data = sample.data(using: .utf8)!
        let result = try JSONDecoder().decode(AnalysisResult.self, from: data)

        XCTAssertEqual(result.overallScore, 55)
        XCTAssertEqual(result.scoreLabelAr, "متوسط")
        XCTAssertEqual(result.identifiedItems.count, 2)
        XCTAssertEqual(result.identifiedItems.first?.nameAr, "أرز")
        XCTAssertEqual(result.identifiedItems.last?.ruleViolated, "الدواجن ممنوعة")
        XCTAssertEqual(result.improvementSuggestionsAr.count, 1)
    }

    func testStripsFences() {
        let fenced = "```json\n{\"a\":1}\n```"
        XCTAssertEqual(ClaudeAPIService.stripFences(fenced), "{\"a\":1}")
    }

    func testToMealMapsVerdicts() throws {
        let data = sample.data(using: .utf8)!
        let result = try JSONDecoder().decode(AnalysisResult.self, from: data)
        let meal = result.toMeal(imageData: Data())
        XCTAssertEqual(meal.items.count, 2)
        XCTAssertEqual(meal.items.first?.verdict, .tayyib)
        XCTAssertEqual(meal.items.last?.verdict, .khabith)
    }
}
