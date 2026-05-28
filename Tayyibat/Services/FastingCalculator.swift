import Foundation

/// حساب أيام الصيام المستحبة (الإثنين/الخميس + الأيام البيض الهجرية).
enum FastingCalculator {
    private static var gregorian: Calendar { Calendar(identifier: .gregorian) }
    private static var hijri: Calendar { Calendar(identifier: .islamicUmmAlQura) }

    /// أنواع الصيام المستحبة المقترحة لهذا اليوم (قد تكون فارغة).
    static func suggestedTypes(for date: Date) -> [FastingType] {
        var types: [FastingType] = []

        let weekday = gregorian.component(.weekday, from: date) // 1=الأحد ... 7=السبت
        if weekday == 2 { types.append(.monday) }
        if weekday == 5 { types.append(.thursday) }

        let hijriDay = hijri.component(.day, from: date)
        if [13, 14, 15].contains(hijriDay) { types.append(.whiteDay) }

        return types
    }

    static func isRecommendedFastingDay(_ date: Date) -> Bool {
        !suggestedTypes(for: date).isEmpty
    }

    /// اليوم الهجري (1-30) لتاريخ ميلادي معيّن.
    static func hijriDay(for date: Date) -> Int {
        hijri.component(.day, from: date)
    }

    /// أقرب أيام صيام مستحبة ابتداءً من تاريخ معيّن.
    static func upcomingFastingDays(from start: Date = .now, days: Int = 14) -> [(date: Date, types: [FastingType])] {
        var result: [(Date, [FastingType])] = []
        let startDay = gregorian.startOfDay(for: start)
        for offset in 0..<days {
            guard let day = gregorian.date(byAdding: .day, value: offset, to: startDay) else { continue }
            let types = suggestedTypes(for: day)
            if !types.isEmpty { result.append((day, types)) }
        }
        return result
    }
}
