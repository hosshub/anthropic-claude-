import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Meal.capturedAt, order: .reverse) private var meals: [Meal]
    @Query private var summaries: [DailySummary]

    @State private var selectedDate: Date?

    private var calendar: Calendar { .current }

    private var scoresByDay: [Date: Int] {
        var dict: [Date: Int] = [:]
        for s in summaries where s.mealsCount > 0 {
            dict[calendar.startOfDay(for: s.date)] = s.averageScore
        }
        return dict
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if meals.isEmpty {
                    ContentUnavailableView(
                        "لا سجلّات بعد",
                        systemImage: "calendar.badge.plus",
                        description: Text("صوّر أول وجبة لتبدأ المتابعة")
                    )
                    .padding(.top, 80)
                } else {
                    VStack(spacing: 20) {
                        AdherenceChart(title: "آخر ٧ أيام", data: weeklyData, useBars: true)
                        AdherenceChart(title: "آخر ٣٠ يوماً", data: monthlyData, useBars: false)
                        CalendarMonthView(month: .now, scores: scoresByDay) { date in
                            selectedDate = calendar.startOfDay(for: date)
                        }
                        statsSection
                        MedicalDisclaimerFooter()
                    }
                    .padding(20)
                }
            }
            .background(Theme.background)
            .navigationTitle("السجل")
            .navigationDestination(item: $selectedDate) { date in
                DayDetailView(date: date)
            }
        }
    }

    // MARK: - Chart data

    private var weeklyData: [DayScore] { dayScores(daysBack: 7) }
    private var monthlyData: [DayScore] { dayScores(daysBack: 30) }

    private func dayScores(daysBack: Int) -> [DayScore] {
        let today = calendar.startOfDay(for: .now)
        return (0..<daysBack).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return DayScore(date: day, score: scoresByDay[day] ?? 0)
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 14) {
                Text("إحصائيات").font(.sectionTitle).foregroundStyle(Theme.textPrimary)
                statRow("أكثر طعام طيّب", value: topFood(.tayyib) ?? "—", color: Theme.primary)
                statRow("أكثر طعام خبيث", value: topFood(.khabith) ?? "—", color: Theme.khabith)
                statRow("أيام صيام مكتملة", value: "\(fastingDaysCompleted)", color: Theme.gold)
                statRow("إجمالي الوجبات", value: "\(meals.count)", color: Theme.textPrimary)
            }
        }
    }

    private func statRow(_ title: String, value: String, color: Color) -> some View {
        HStack {
            Text(title).font(.bodyText).foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value).font(.cardTitle).foregroundStyle(color)
        }
    }

    private func topFood(_ verdict: Verdict) -> String? {
        let names = meals.flatMap { $0.items }.filter { $0.verdict == verdict }.map(\.nameAr)
        let counts = Dictionary(grouping: names, by: { $0 }).mapValues(\.count)
        return counts.max(by: { $0.value < $1.value })?.key
    }

    private var fastingDaysCompleted: Int {
        summaries.filter { $0.fastedToday }.count
    }
}
