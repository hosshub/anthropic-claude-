import SwiftUI
import SwiftData

/// شاشة برنامج ١٥ يوم (تفاعلية). يقرأ حالة البرنامج من UserProfile.
struct Program15DayView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]
    private var profile: UserProfile? { profiles.first }

    @State private var selectedDay: Int = 1
    @State private var showCapture = false

    private var status: ProgramStatus {
        profile?.programStatus ?? .notStarted
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                introCard
                switch status {
                case .notStarted:
                    phasesPreviewCard
                    startButton
                case .inProgress(let day):
                    progressHeader(currentDay: day)
                    phasePills(currentDay: day)
                    daySelector(currentDay: day)
                    if let detail = Program15DayData.day(selectedDay) {
                        dayDetailCard(detail, isCurrent: detail.day == day)
                    }
                    stopButton
                case .completed:
                    completionCard
                    restartButton
                }
                MedicalDisclaimerFooter()
                    .padding(.top, 4)
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("برنامج ١٥ يوم")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showCapture) {
            CaptureFlowView()
        }
        .onAppear { syncSelectedDay() }
        .onChange(of: status) { _, _ in syncSelectedDay() }
    }

    private func syncSelectedDay() {
        if case .inProgress(let day) = status {
            selectedDay = day
        } else {
            selectedDay = 1
        }
    }

    // MARK: - Intro

    private var introCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 8) {
                Label(Program15DayData.titleAr, systemImage: "calendar.badge.clock")
                    .font(.cardTitle.weight(.bold))
                    .foregroundStyle(Theme.primary)
                Text(Program15DayData.philosophyAr)
                    .font(.bodyText)
                    .foregroundStyle(Theme.textSecondary)
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Not started: phases preview

    private var phasesPreviewCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("مراحل الرحلة")
                    .font(.cardTitle.weight(.semibold))
                    .foregroundStyle(Theme.primary)
                ForEach(Program15DayData.phases) { phase in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(phase.color).frame(width: 38, height: 38)
                            Text(arabicNumeral(phase.number))
                                .font(.cardTitle.weight(.bold))
                                .foregroundStyle(.white)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(phase.titleAr)
                                .font(.bodyText.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            Text(phase.daysRangeAr)
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                            Text(phase.focusAr)
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }

    private var startButton: some View {
        PrimaryButton(title: "ابدأ البرنامج اليوم",
                      systemImage: "play.fill") { startProgram() }
    }

    // MARK: - In progress: header + selector

    private func progressHeader(currentDay: Int) -> some View {
        CardContainer {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(Theme.primary.opacity(0.15), lineWidth: 8)
                        .frame(width: 64, height: 64)
                    Circle()
                        .trim(from: 0, to: CGFloat(currentDay) / 15)
                        .stroke(Theme.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))
                    Text("\(arabicNumeral(currentDay))/\(arabicNumeral(15))")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.primary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("اليوم \(arabicNumeral(currentDay))")
                        .font(.cardTitle.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                    if let detail = Program15DayData.day(currentDay) {
                        Text(detail.focusAr)
                            .font(.bodyText)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }

    private func phasePills(currentDay: Int) -> some View {
        HStack(spacing: 6) {
            ForEach(Program15DayData.phases) { phase in
                let isActive = phase.dayRange.contains(currentDay)
                VStack(spacing: 6) {
                    Circle().fill(phase.color).frame(width: 10, height: 10)
                    Text(phase.titleAr)
                        .font(.caption2.weight(isActive ? .semibold : .regular))
                        .foregroundStyle(isActive ? Theme.textPrimary : Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
                .background(
                    isActive ? phase.color.opacity(0.18) : Color.clear,
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                )
            }
        }
    }

    private func daySelector(currentDay: Int) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(1...15, id: \.self) { d in
                        Button {
                            withAnimation { selectedDay = d }
                        } label: {
                            Text(arabicNumeral(d))
                                .font(.cardTitle.weight(.bold))
                                .foregroundStyle(dayChipForeground(d, current: currentDay))
                                .frame(width: 44, height: 44)
                                .background(dayChipBackground(d, current: currentDay), in: Circle())
                                .overlay(
                                    Circle().stroke(
                                        d == currentDay ? Theme.gold : Color.clear,
                                        lineWidth: 2
                                    )
                                )
                        }
                        .buttonStyle(.plain)
                        .id(d)
                    }
                }
                .padding(.vertical, 4)
            }
            .onAppear {
                DispatchQueue.main.async {
                    withAnimation { proxy.scrollTo(currentDay, anchor: .center) }
                }
            }
        }
    }

    private func dayChipBackground(_ d: Int, current: Int) -> Color {
        if d == selectedDay { return Theme.primary }
        if d == current { return Theme.gold.opacity(0.18) }
        if d < current { return Theme.primary.opacity(0.15) }
        return Theme.surface
    }

    private func dayChipForeground(_ d: Int, current: Int) -> Color {
        d == selectedDay ? .white : Theme.textPrimary
    }

    private func dayDetailCard(_ detail: ProgramDay, isCurrent: Bool) -> some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("اليوم \(arabicNumeral(detail.day))")
                        .font(.cardTitle.weight(.bold))
                        .foregroundStyle(Theme.primary)
                    if isCurrent {
                        Text("اليوم الحالي")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Theme.gold.opacity(0.18), in: Capsule())
                            .foregroundStyle(Theme.gold)
                    } else if detail.day < currentDayValue {
                        Text("اكتمل")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Theme.primary.opacity(0.12), in: Capsule())
                            .foregroundStyle(Theme.primary)
                    }
                    Spacer()
                }
                Text(detail.focusAr)
                    .font(.sectionTitle.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)

                Divider()

                VStack(alignment: .leading, spacing: 6) {
                    Label("وجبة مقترحة", systemImage: "fork.knife")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.primary)
                    Text(detail.exampleMealAr)
                        .font(.bodyText)
                        .foregroundStyle(Theme.textPrimary)
                        .lineSpacing(4)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Label("نصيحة اليوم", systemImage: "lightbulb.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.gold)
                    Text(detail.tipAr)
                        .font(.bodyText)
                        .foregroundStyle(Theme.textPrimary)
                        .lineSpacing(4)
                }

                if isCurrent {
                    PrimaryButton(title: "صوّر وجبة اليوم",
                                  systemImage: "camera.fill") { showCapture = true }
                        .padding(.top, 4)
                }
            }
        }
    }

    private var currentDayValue: Int {
        if case .inProgress(let d) = status { return d }
        return 0
    }

    private var stopButton: some View {
        Button(role: .destructive) {
            stopProgram()
        } label: {
            Label("أوقف البرنامج", systemImage: "stop.fill")
                .font(.bodyText.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 46)
        }
        .buttonStyle(.bordered)
        .tint(Theme.khabith)
    }

    // MARK: - Completed

    private var completionCard: some View {
        CardContainer {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Theme.primary)
                Text("أكملت البرنامج 🎉")
                    .font(.sectionTitle.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                Text("اعرف الآن أي وجبات تعطيك راحة وشبعاً بدون ثقل. كرّر أفضل ٥ منها كقاعدة لك.")
                    .font(.bodyText)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
            }
        }
    }

    private var restartButton: some View {
        PrimaryButton(title: "ابدأ من جديد",
                      systemImage: "arrow.clockwise") { startProgram() }
    }

    // MARK: - Actions

    private func startProgram() {
        profile?.programStartedAt = .now
        try? context.save()
        selectedDay = 1
    }

    private func stopProgram() {
        profile?.programStartedAt = nil
        try? context.save()
        selectedDay = 1
    }

    // MARK: - Helpers

    private func arabicNumeral(_ n: Int) -> String {
        let map: [Character: Character] = [
            "0": "٠", "1": "١", "2": "٢", "3": "٣", "4": "٤",
            "5": "٥", "6": "٦", "7": "٧", "8": "٨", "9": "٩"
        ]
        return String("\(n)".map { map[$0] ?? $0 })
    }
}
