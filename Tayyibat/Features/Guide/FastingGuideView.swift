import SwiftUI

struct FastingGuideView: View {
    private let fasting = RulesService.shared.rules.fasting

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                CardContainer {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("الصيام الأسبوعي", systemImage: "calendar")
                            .font(.cardTitle).foregroundStyle(Theme.primary)
                        Text(fasting.weekly.joined(separator: " و"))
                            .font(.bodyText).foregroundStyle(Theme.textPrimary)
                    }
                }

                CardContainer {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("الأيام البيض", systemImage: "moon.stars.fill")
                            .font(.cardTitle).foregroundStyle(Theme.gold)
                        Text("أيام \(fasting.whiteDaysHijri.map(String.init).joined(separator: "، ")) من كل شهر هجري")
                            .font(.bodyText).foregroundStyle(Theme.textPrimary)
                    }
                }

                CardContainer {
                    Text(fasting.notes)
                        .font(.bodyText).foregroundStyle(Theme.textSecondary).lineSpacing(5)
                }

                upcomingCard
                MedicalDisclaimerFooter()
            }
            .padding(20)
        }
        .background(Theme.background)
        .navigationTitle("الصيام")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var upcomingCard: some View {
        let upcoming = FastingCalculator.upcomingFastingDays(days: 14)
        return CardContainer {
            VStack(alignment: .leading, spacing: 10) {
                Text("أيام الصيام القادمة")
                    .font(.cardTitle).foregroundStyle(Theme.textPrimary)
                if upcoming.isEmpty {
                    Text("لا أيام صيام مستحبة خلال الأسبوعين القادمين")
                        .font(.bodyText).foregroundStyle(Theme.textSecondary)
                } else {
                    ForEach(Array(upcoming.enumerated()), id: \.offset) { _, entry in
                        HStack {
                            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.bodyText).foregroundStyle(Theme.textPrimary)
                            Spacer()
                            Text(entry.types.map(\.labelAr).joined(separator: " و"))
                                .font(.caption).foregroundStyle(Theme.gold)
                        }
                        Divider()
                    }
                }
            }
        }
    }
}
