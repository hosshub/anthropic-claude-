import XCTest
@testable import Tayyibat

final class FastingCalculatorTests: XCTestCase {

    private var gregorian: Calendar { Calendar(identifier: .gregorian) }

    private func nextDate(weekday: Int) -> Date {
        gregorian.nextDate(after: .now, matching: DateComponents(weekday: weekday), matchingPolicy: .nextTime)!
    }

    func testMondayIsSuggested() {
        let monday = nextDate(weekday: 2) // 2 = الإثنين
        XCTAssertTrue(FastingCalculator.suggestedTypes(for: monday).contains(.monday))
    }

    func testThursdayIsSuggested() {
        let thursday = nextDate(weekday: 5) // 5 = الخميس
        XCTAssertTrue(FastingCalculator.suggestedTypes(for: thursday).contains(.thursday))
    }

    func testSundayHasNoWeeklyFast() {
        let sunday = nextDate(weekday: 1) // 1 = الأحد
        let types = FastingCalculator.suggestedTypes(for: sunday)
        XCTAssertFalse(types.contains(.monday))
        XCTAssertFalse(types.contains(.thursday))
    }

    func testHijriDayInValidRange() {
        let day = FastingCalculator.hijriDay(for: .now)
        XCTAssertTrue((1...30).contains(day))
    }
}
