import Foundation
import SwiftData

/// يحدّث الملخصات اليومية اعتماداً على الوجبات المحفوظة.
enum SummaryService {
    /// يعيد حساب ملخص يوم معيّن من وجباته ويحفظه.
    @discardableResult
    static func updateSummary(for date: Date, context: ModelContext) -> DailySummary {
        let day = Calendar.current.startOfDay(for: date)
        let meals = mealsOfDay(day, context: context)
        let average = meals.isEmpty ? 0 : Int((Double(meals.map(\.overallScore).reduce(0, +)) / Double(meals.count)).rounded())

        let summary = summary(for: day, context: context) ?? {
            let new = DailySummary(date: day)
            context.insert(new)
            return new
        }()
        summary.averageScore = average
        summary.mealsCount = meals.count
        try? context.save()
        return summary
    }

    static func mealsOfDay(_ date: Date, context: ModelContext) -> [Meal] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        guard let end = cal.date(byAdding: .day, value: 1, to: start) else { return [] }
        let predicate = #Predicate<Meal> { $0.capturedAt >= start && $0.capturedAt < end }
        let descriptor = FetchDescriptor<Meal>(predicate: predicate, sortBy: [SortDescriptor(\.capturedAt, order: .reverse)])
        return (try? context.fetch(descriptor)) ?? []
    }

    static func summary(for date: Date, context: ModelContext) -> DailySummary? {
        let day = Calendar.current.startOfDay(for: date)
        let predicate = #Predicate<DailySummary> { $0.date == day }
        let descriptor = FetchDescriptor<DailySummary>(predicate: predicate)
        return (try? context.fetch(descriptor))?.first
    }

    /// يضبط حالة الصيام لليوم في الملخص.
    static func setFasting(_ fasted: Bool, for date: Date, context: ModelContext) {
        let day = Calendar.current.startOfDay(for: date)
        let summary = summary(for: day, context: context) ?? {
            let new = DailySummary(date: day)
            context.insert(new)
            return new
        }()
        summary.fastedToday = fasted
        try? context.save()
    }

    /// عدد الأيام المتتالية (Streak) التي تجاوز متوسطها 80% حتى اليوم.
    static func currentStreak(context: ModelContext) -> Int {
        let cal = Calendar.current
        var streak = 0
        var day = cal.startOfDay(for: .now)
        while let summary = summary(for: day, context: context), summary.averageScore >= 80, summary.mealsCount > 0 {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }
}
