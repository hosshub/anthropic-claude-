import SwiftUI

/// تقويم شهري؛ كل يوم بنقطة لونية حسب متوسط الالتزام.
struct CalendarMonthView: View {
    let month: Date
    /// متوسط النسبة لكل يوم (مفتاح: بداية اليوم).
    let scores: [Date: Int]
    let onSelect: (Date) -> Void

    private var calendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale(identifier: "ar")
        return c
    }

    private let weekdaySymbols = ["أحد", "إثن", "ثلا", "أرب", "خمي", "جمع", "سبت"]

    var body: some View {
        CardContainer {
            VStack(spacing: 12) {
                Text(monthTitle)
                    .font(.cardTitle)
                    .foregroundStyle(Theme.textPrimary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    ForEach(weekdaySymbols, id: \.self) { sym in
                        Text(sym).font(.caption2).foregroundStyle(Theme.textSecondary)
                    }
                    ForEach(Array(gridDays.enumerated()), id: \.offset) { _, day in
                        if let day {
                            dayCell(day)
                        } else {
                            Color.clear.frame(height: 38)
                        }
                    }
                }
            }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let score = scores[calendar.startOfDay(for: date)]
        let isToday = calendar.isDateInToday(date)
        return Button { onSelect(date) } label: {
            VStack(spacing: 3) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.caption.weight(isToday ? .bold : .regular))
                    .foregroundStyle(isToday ? Theme.primary : Theme.textPrimary)
                Circle()
                    .fill(score != nil ? Theme.scoreColor(score!) : Color.clear)
                    .frame(width: 7, height: 7)
            }
            .frame(maxWidth: .infinity, minHeight: 38)
            .background(isToday ? Theme.primary.opacity(0.08) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .disabled(score == nil)
    }

    private var monthTitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ar")
        f.dateFormat = "MMMM yyyy"
        return f.string(from: month)
    }

    /// مصفوفة الأيام مع فراغات في البداية لمحاذاة بداية الأسبوع.
    private var gridDays: [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: month) else { return [] }
        let firstDay = interval.start
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)?.count ?? 30
        let firstWeekday = calendar.component(.weekday, from: firstDay) // 1=أحد
        // الترويسة ثابتة تبدأ بالأحد، لذا نحسب الفراغات بناءً على الأحد=1.
        let leading = firstWeekday - 1

        var result: [Date?] = Array(repeating: nil, count: leading)
        for offset in 0..<daysInMonth {
            if let day = calendar.date(byAdding: .day, value: offset, to: firstDay) {
                result.append(day)
            }
        }
        return result
    }
}
