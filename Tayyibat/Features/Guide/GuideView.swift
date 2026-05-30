import SwiftUI

/// تبويب الدليل — الفهرس الذكي ٣×٣ (نسخة 2).
struct GuideView: View {
    private let sections = GuideSection.allCases
    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("الفهرس الذكي")
                            .font(.screenTitle)
                            .foregroundStyle(Theme.textPrimary)
                        Text("الدليل في ٩ أقسام")
                            .font(.bodyText)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(sections) { section in
                            NavigationLink {
                                section.destination
                            } label: {
                                GuideIndexCard(section: section)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)

                    MedicalDisclaimerFooter()
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                }
                .padding(.vertical, 16)
            }
            .background(Theme.background)
            .navigationTitle("الدليل")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/// أقسام الفهرس التسعة، بترتيب الدليل.
enum GuideSection: String, CaseIterable, Identifiable {
    case philosophy, goldenRules, eatingMap, forbidden, plate, program15, mealBanks, weeklyPrep, mistakes

    var id: String { rawValue }

    var number: String {
        switch self {
        case .philosophy: return "٠١"
        case .goldenRules: return "٠٢"
        case .eatingMap: return "٠٣"
        case .forbidden: return "٠٤"
        case .plate: return "٠٥"
        case .program15: return "٠٦"
        case .mealBanks: return "٠٧"
        case .weeklyPrep: return "٠٨"
        case .mistakes: return "٠٩"
        }
    }

    var titleAr: String {
        switch self {
        case .philosophy: return "فلسفة النظام"
        case .goldenRules: return "القواعد الذهبية"
        case .eatingMap: return "خريطة الأكل"
        case .forbidden: return "الممنوعات الصريحة"
        case .plate: return "طبق الطيبات"
        case .program15: return "برنامج ١٥ يوم"
        case .mealBanks: return "بنك الوجبات"
        case .weeklyPrep: return "التحضير الأسبوعي"
        case .mistakes: return "الأخطاء الشائعة"
        }
    }

    var icon: String {
        switch self {
        case .philosophy: return "lightbulb.fill"
        case .goldenRules: return "star.fill"
        case .eatingMap: return "map.fill"
        case .forbidden: return "xmark.octagon.fill"
        case .plate: return "fork.knife"
        case .program15: return "calendar"
        case .mealBanks: return "tray.full.fill"
        case .weeklyPrep: return "checklist"
        case .mistakes: return "exclamationmark.triangle.fill"
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .philosophy: GuidePhilosophyView()
        case .goldenRules: GuideGoldenRulesView()
        case .eatingMap: GuideEatingMapView()
        case .forbidden: GuideForbiddenView()
        case .plate: GuideTayyibatPlateView()
        case .program15: GuideProgramFifteenDayView()
        case .mealBanks: GuideMealBanksView()
        case .weeklyPrep: GuideWeeklyPrepView()
        case .mistakes: GuideCommonMistakesView()
        }
    }
}

/// بطاقة خضراء داكنة في الشبكة.
struct GuideIndexCard: View {
    let section: GuideSection

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(section.number)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.white.opacity(0.55))
                Spacer()
                Image(systemName: section.icon)
                    .font(.body)
                    .foregroundStyle(Color.white.opacity(0.85))
            }
            Spacer(minLength: 0)
            Text(section.titleAr)
                .font(.bodyText.weight(.semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
        }
        .padding(12)
        .frame(height: 112)
        .background(Theme.primary, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Theme.cardShadow, radius: 6, y: 3)
    }
}
