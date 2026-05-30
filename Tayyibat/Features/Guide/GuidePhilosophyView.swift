import SwiftUI

/// ٠١ — فلسفة النظام (3 بطاقات من القواعد).
struct GuidePhilosophyView: View {
    private let cards = RulesService.shared.rules.philosophyCards

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(cards) { card in
                    CardContainer {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(card.titleAr)
                                .font(.cardTitle.weight(.bold))
                                .foregroundStyle(Theme.primary)
                            Text(card.bodyAr)
                                .font(.bodyText)
                                .foregroundStyle(Theme.textPrimary)
                                .lineSpacing(5)
                        }
                    }
                }
                MedicalDisclaimerFooter()
                    .padding(.top, 4)
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("فلسفة النظام")
        .navigationBarTitleDisplayMode(.inline)
    }
}
