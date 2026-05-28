import XCTest
@testable import Tayyibat

final class ScoringTests: XCTestCase {

    private func item(_ verdict: Verdict, portion: String = "متوسطة") -> FoodItem {
        FoodItem(nameAr: "اختبار", verdict: verdict, category: "عام", reasoning: "", confidence: 1, estimatedPortion: portion)
    }

    func testEmptyIsZero() {
        XCTAssertEqual(ScoringHelper.recompute(items: []), 0)
    }

    func testAllTayyibIsFull() {
        let items = [item(.tayyib), item(.tayyib, portion: "حصة كبيرة")]
        XCTAssertEqual(ScoringHelper.recompute(items: items), 100)
    }

    func testAllConditionalIsHalf() {
        XCTAssertEqual(ScoringHelper.recompute(items: [item(.conditional)]), 50)
    }

    func testKhabithCapsAtSixty() {
        // طيّب كبير (وزن 3) + خبيث صغير (وزن 1) => 75% لكن السقف 60 لوجود خبيث.
        let items = [item(.tayyib, portion: "حصة كبيرة"), item(.khabith, portion: "حصة صغيرة")]
        XCTAssertEqual(ScoringHelper.recompute(items: items), 60)
    }

    func testScoreBounds() {
        let score = ScoringHelper.recompute(items: [item(.khabith)])
        XCTAssertGreaterThanOrEqual(score, 0)
        XCTAssertLessThanOrEqual(score, 100)
    }
}
