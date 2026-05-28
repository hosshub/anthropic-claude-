import Foundation
import SwiftData

@Model
final class DailySummary {
    @Attribute(.unique) var date: Date
    var averageScore: Int
    var mealsCount: Int
    var fastedToday: Bool

    init(date: Date, averageScore: Int = 0, mealsCount: Int = 0, fastedToday: Bool = false) {
        self.date = Calendar.current.startOfDay(for: date)
        self.averageScore = averageScore
        self.mealsCount = mealsCount
        self.fastedToday = fastedToday
    }
}
