import XCTest
import SwiftData
@testable import Tayyibat

final class TipsRotationTests: XCTestCase {

    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Meal.self, FoodItem.self, FastingDay.self,
            DailySummary.self, UserProfile.self, NotificationTip.self,
            configurations: config
        )
        return ModelContext(container)
    }

    func testNextTipAvoidsRecentRepeats() throws {
        let context = try makeContext()
        // أدخل 20 نصيحة صباحية.
        for i in 0..<20 {
            context.insert(NotificationTip(category: .morning, textAr: "نصيحة \(i)"))
        }
        try context.save()

        var seen: [String] = []
        for _ in 0..<15 {
            if let tip = TipsService.nextTip(for: .morning, context: context) {
                seen.append(tip)
            }
        }
        // 15 سحبة من 20 نصيحة يجب ألا تكرّر أي نصيحة (نافذة منع التكرار = 10).
        XCTAssertEqual(seen.count, 15)
        XCTAssertEqual(Set(seen).count, 15)
    }

    func testTipOfTheDayIsStableWithinDay() throws {
        let context = try makeContext()
        for i in 0..<5 {
            context.insert(NotificationTip(category: .general, textAr: "عامة \(i)"))
        }
        try context.save()

        let a = TipsService.tipOfTheDay(context: context)
        let b = TipsService.tipOfTheDay(context: context)
        XCTAssertEqual(a, b)
        XCTAssertFalse(a.isEmpty)
    }
}
