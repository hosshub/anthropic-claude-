import SwiftUI

struct BehavioralRulesView: View {
    private let rules = RulesService.shared.rules.behavioralRules

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(rules.enumerated()), id: \.offset) { index, rule in
                    CardContainer {
                        HStack(alignment: .top, spacing: 14) {
                            Text("\(index + 1)")
                                .font(.cardTitle.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(Theme.primary, in: Circle())
                            Text(rule)
                                .font(.bodyText)
                                .foregroundStyle(Theme.textPrimary)
                                .lineSpacing(5)
                            Spacer(minLength: 0)
                        }
                    }
                }
                MedicalDisclaimerFooter()
            }
            .padding(20)
        }
        .background(Theme.background)
        .navigationTitle("القواعد السلوكية")
        .navigationBarTitleDisplayMode(.inline)
    }
}
