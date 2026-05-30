import SwiftUI

/// نبذة محايدة عن فلسفة النظام — ٣ بطاقات من الدليل (نسخة 2).
struct PhilosophyView: View {
    let onContinue: () -> Void
    private let cards = RulesService.shared.rules.philosophyCards

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("عن نظام الطيبات")
                        .font(.screenTitle)
                        .foregroundStyle(Theme.textPrimary)

                    ForEach(cards) { card in
                        cardView(card)
                    }

                    Text("هذا التطبيق أداة محايدة لمن اختار اتباع النظام، ولا يتبنّى موقفاً طبياً منه.")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.top, 6)
                }
                .padding(20)
            }
            PrimaryButton(title: "متابعة", systemImage: "arrow.left", action: onContinue)
                .padding(20)
        }
        .background(Theme.background)
    }

    private func cardView(_ card: RulesData.PhilosophyCard) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(card.titleAr)
                .font(.cardTitle.weight(.bold))
                .foregroundStyle(Theme.primary)
            Text(card.bodyAr)
                .font(.bodyText)
                .foregroundStyle(Theme.textPrimary)
                .lineSpacing(5)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Theme.cardShadow, radius: 6, y: 3)
    }
}
