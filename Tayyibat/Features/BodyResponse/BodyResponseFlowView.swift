import SwiftUI
import SwiftData

/// متابعة الجسم بعد الوجبة — تدفّق من ٥ أسئلة + شاشة شكر.
struct BodyResponseFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let meal: Meal

    @State private var step: Int = 0
    @State private var satisfaction: Int
    @State private var bloating: Int
    @State private var energy: Int
    @State private var sleep: SleepImpact
    @State private var worth: WorthRepeating
    @State private var notes: String

    private let totalSteps = 6   // ٥ أسئلة + شاشة شكر

    init(meal: Meal) {
        self.meal = meal
        let existing = meal.bodyResponse
        _satisfaction = State(initialValue: existing?.satisfyingFullness ?? 3)
        _bloating     = State(initialValue: existing?.bloating ?? 0)
        _energy       = State(initialValue: existing?.energyLevel ?? 3)
        _sleep        = State(initialValue: existing?.sleepImpact ?? .unknown)
        _worth        = State(initialValue: existing?.worthRepeating ?? .maybe)
        _notes        = State(initialValue: existing?.notes ?? "")
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            TabView(selection: $step) {
                satisfactionPage.tag(0)
                bloatingPage.tag(1)
                energyPage.tag(2)
                sleepPage.tag(3)
                worthPage.tag(4)
                thankYouPage.tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: step)
            footer
        }
        .background(Theme.background.ignoresSafeArea())
        .environment(\.layoutDirection, .rightToLeft)
    }

    // MARK: - Header / Footer

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                Button("لاحقاً") { dismiss() }
                    .font(.bodyText)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("كيف شعرت بعد الوجبة؟")
                    .font(.cardTitle.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text(stepIndicator)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            ProgressView(value: Double(step + 1), total: Double(totalSteps))
                .tint(Theme.primary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 6)
    }

    private var stepIndicator: String {
        step < totalSteps - 1 ? "\(step + 1) / \(totalSteps - 1)" : "تم"
    }

    private var footer: some View {
        HStack(spacing: 12) {
            if step > 0 && step < totalSteps - 1 {
                Button("السابق") {
                    withAnimation { step -= 1 }
                }
                .buttonStyle(.bordered)
                .tint(Theme.textSecondary)
            }
            Spacer()
            if step < totalSteps - 2 {
                Button("التالي") {
                    withAnimation { step += 1 }
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.primary)
            } else if step == totalSteps - 2 {
                Button("احفظ") { saveAndAdvance() }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.primary)
            } else {
                Button("أنهِ") { dismiss() }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.primary)
            }
        }
        .padding(20)
    }

    // MARK: - Pages

    private var satisfactionPage: some View {
        questionFrame(title: "هل شعرت بشبع مريح؟",
                      hint: emojiHintFor(satisfaction)) {
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { value in
                    emojiButton(emoji: satisfactionEmoji(value), selected: satisfaction == value) {
                        satisfaction = value
                    }
                }
            }
        }
    }

    private var bloatingPage: some View {
        questionFrame(title: "هل حدث انتفاخ أو ثقل؟",
                      hint: bloatingHint(bloating)) {
            VStack(spacing: 12) {
                Text("\(bloating)")
                    .font(.scoreNumber)
                    .foregroundStyle(bloating == 0 ? Theme.primary : (bloating <= 2 ? Theme.gold : Theme.khabith))
                Slider(value: Binding(
                    get: { Double(bloating) },
                    set: { bloating = Int($0.rounded()) }
                ), in: 0...5, step: 1)
                .tint(bloating == 0 ? Theme.primary : (bloating <= 2 ? Theme.gold : Theme.khabith))
                .padding(.horizontal, 6)
                HStack {
                    Text("٠ مرتاح").font(.caption2).foregroundStyle(Theme.textSecondary)
                    Spacer()
                    Text("٥ ثقل شديد").font(.caption2).foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }

    private var energyPage: some View {
        questionFrame(title: "كيف كانت طاقتك بعد الأكل؟",
                      hint: energyLabel(energy)) {
            VStack(spacing: 10) {
                ForEach((1...5).reversed(), id: \.self) { value in
                    Button {
                        energy = value
                    } label: {
                        HStack {
                            Image(systemName: energy == value ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(energy == value ? Theme.primary : Theme.textSecondary)
                            Text(energyLabel(value))
                                .font(.bodyText)
                                .foregroundStyle(Theme.textPrimary)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .background(
                            energy == value
                            ? Theme.primary.opacity(0.10)
                            : Theme.surface,
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var sleepPage: some View {
        questionFrame(title: "كيف كان نومك بعد الوجبة؟",
                      hint: "اختياري — يمكنك تركها على \"لا أعلم\" والعودة لاحقاً.") {
            VStack(spacing: 10) {
                ForEach(SleepImpact.allCases) { option in
                    Button {
                        sleep = option
                    } label: {
                        HStack {
                            Image(systemName: sleep == option ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(sleep == option ? Theme.primary : Theme.textSecondary)
                            Text(option.labelAr)
                                .font(.bodyText)
                                .foregroundStyle(Theme.textPrimary)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .background(
                            sleep == option
                            ? Theme.primary.opacity(0.10)
                            : Theme.surface,
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var worthPage: some View {
        questionFrame(title: "هل تستحق هذه الوجبة التكرار؟",
                      hint: "هذه الإجابة تساعد التطبيق يقترح ما يناسب جسمك.") {
            VStack(spacing: 14) {
                HStack(spacing: 14) {
                    ForEach(WorthRepeating.allCases) { option in
                        Button {
                            worth = option
                        } label: {
                            VStack(spacing: 6) {
                                Text(option.emoji).font(.system(size: 40))
                                Text(option.labelAr)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Theme.textPrimary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                worth == option
                                ? Theme.primary.opacity(0.12)
                                : Theme.surface,
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                if worth == .no {
                    TextField("لماذا؟ (اختياري)", text: $notes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)
                }
            }
        }
    }

    private var thankYouPage: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.primary)
            Text("شكراً لك")
                .font(.displayTitle)
                .foregroundStyle(Theme.textPrimary)
            Text("هذه الملاحظات تساعدك تعرف جسمك أكثر، ومع الوقت يساعدك التطبيق على اقتراح ما يناسبك.")
                .font(.bodyText)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.textSecondary)
                .lineSpacing(5)
                .padding(.horizontal, 24)
            Spacer()
        }
    }

    // MARK: - Reusable

    private func questionFrame<Content: View>(
        title: String,
        hint: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.sectionTitle.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                Text(hint)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            content()
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 22)
        .padding(.top, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func emojiButton(emoji: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(emoji)
                .font(.system(size: 36))
                .padding(8)
                .background(
                    selected ? Theme.primary.opacity(0.18) : Color.clear,
                    in: Circle()
                )
                .overlay(
                    Circle().stroke(selected ? Theme.primary : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }

    private func satisfactionEmoji(_ v: Int) -> String {
        switch v {
        case 1: return "😣"
        case 2: return "🙁"
        case 3: return "🙂"
        case 4: return "😌"
        default: return "😵"
        }
    }

    private func emojiHintFor(_ v: Int) -> String {
        switch v {
        case 1: return "لم أشعر بشبع"
        case 2: return "شبع خفيف"
        case 3: return "شبع مريح"
        case 4: return "شبع كامل"
        default: return "ممتلئ جداً"
        }
    }

    private func bloatingHint(_ v: Int) -> String {
        switch v {
        case 0: return "مرتاح تماماً"
        case 1, 2: return "ثقل خفيف"
        case 3: return "انتفاخ ملحوظ"
        case 4: return "ثقل واضح"
        default: return "ثقل شديد"
        }
    }

    private func energyLabel(_ v: Int) -> String {
        switch v {
        case 1: return "نعسان جداً"
        case 2: return "خامل"
        case 3: return "عادي"
        case 4: return "نشيط"
        default: return "نشيط جداً"
        }
    }

    // MARK: - Save

    private func saveAndAdvance() {
        let hours = max(0, Int(Date.now.timeIntervalSince(meal.capturedAt) / 3600))
        let trimmedNotes = notes.trimmingCharacters(in: .whitespaces)

        if let existing = meal.bodyResponse {
            existing.loggedAt = .now
            existing.hoursAfterMeal = hours
            existing.satisfyingFullness = satisfaction
            existing.bloating = bloating
            existing.energyLevel = energy
            existing.sleepImpact = sleep
            existing.worthRepeating = worth
            existing.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
        } else {
            let response = BodyResponse(
                loggedAt: .now,
                hoursAfterMeal: hours,
                satisfyingFullness: satisfaction,
                bloating: bloating,
                energyLevel: energy,
                sleepImpact: sleep,
                worthRepeating: worth,
                notes: trimmedNotes.isEmpty ? nil : trimmedNotes
            )
            context.insert(response)
            meal.bodyResponse = response
        }
        try? context.save()
        withAnimation { step += 1 }
    }
}
