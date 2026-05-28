import SwiftUI
import SwiftData

struct TodayView: View {
    let profile: UserProfile
    @Environment(\.modelContext) private var context

    @Query private var todayMeals: [Meal]
    @State private var showCapture = false
    @State private var fastedToday = false

    init(profile: UserProfile) {
        self.profile = profile
        let start = Calendar.current.startOfDay(for: .now)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
        _todayMeals = Query(
            filter: #Predicate<Meal> { $0.capturedAt >= start && $0.capturedAt < end },
            sort: [SortDescriptor(\.capturedAt, order: .reverse)]
        )
    }

    private var todayScore: Int {
        guard !todayMeals.isEmpty else { return 0 }
        return Int((Double(todayMeals.map(\.overallScore).reduce(0, +)) / Double(todayMeals.count)).rounded())
    }

    private var tayyibCount: Int { todayMeals.filter { $0.overallScore >= 70 }.count }
    private var streak: Int { SummaryService.currentStreak(context: context) }
    private var suggestedFasting: [FastingType] { FastingCalculator.suggestedTypes(for: .now) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    greeting
                    ringCard
                    captureButton
                    if !todayMeals.isEmpty { progressCard }
                    fastingCard
                    TipCard(text: TipsService.tipOfTheDay(context: context))
                    if !todayMeals.isEmpty { todayMealsSection }
                    MedicalDisclaimerFooter()
                }
                .padding(20)
            }
            .background(Theme.background)
            .navigationTitle("اليوم")
            .onAppear { fastedToday = SummaryService.summary(for: .now, context: context)?.fastedToday ?? false }
        }
        .fullScreenCover(isPresented: $showCapture) {
            CaptureFlowView()
        }
    }

    private var greeting: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(greetingText)
                    .font(.screenTitle)
                    .foregroundStyle(Theme.textPrimary)
                if streak > 0 {
                    Label("\(streak) أيام متتالية فوق ٨٠٪", systemImage: "flame.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.gold)
                }
            }
            Spacer()
        }
    }

    private var greetingText: String {
        let name = profile.name.isEmpty ? "" : "، \(profile.name)"
        let hour = Calendar.current.component(.hour, from: .now)
        let part = hour < 12 ? "صباح الخير" : (hour < 18 ? "مساء الخير" : "مساء الخير")
        return "\(part)\(name)"
    }

    private var ringCard: some View {
        CardContainer {
            VStack(spacing: 6) {
                ScoreRing(score: todayScore)
                if todayMeals.isEmpty {
                    Text("لم تسجّل وجبات اليوم بعد")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var captureButton: some View {
        PrimaryButton(title: "صوّر وجبتك", systemImage: "camera.fill") {
            showCapture = true
        }
    }

    private var progressCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("تقدّم اليوم").font(.cardTitle).foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text("\(tayyibCount)/\(todayMeals.count) طيبة")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.primary)
                }
                ProgressView(value: Double(tayyibCount), total: Double(max(todayMeals.count, 1)))
                    .tint(Theme.primary)
            }
        }
    }

    private var fastingCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: Binding(
                    get: { fastedToday },
                    set: { newValue in
                        fastedToday = newValue
                        SummaryService.setFasting(newValue, for: .now, context: context)
                    }
                )) {
                    HStack(spacing: 8) {
                        Image(systemName: "moon.stars.fill").foregroundStyle(Theme.gold)
                        Text("هل تصوم اليوم؟").font(.cardTitle).foregroundStyle(Theme.textPrimary)
                    }
                }
                .tint(Theme.primary)

                if !suggestedFasting.isEmpty {
                    Text("اليوم \(suggestedFasting.map(\.labelAr).joined(separator: " و")) — صيام مستحب")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }

    private var todayMealsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("سجل اليوم")
                .font(.sectionTitle)
                .foregroundStyle(Theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(todayMeals) { meal in
                        NavigationLink {
                            MealDetailView(meal: meal)
                        } label: {
                            MealCard(meal: meal)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
