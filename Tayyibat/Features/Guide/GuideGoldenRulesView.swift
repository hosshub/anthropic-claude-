import SwiftUI

/// ٠٢ — القواعد الذهبية الست.
struct GuideGoldenRulesView: View {
    private let rules = RulesService.shared.rules.goldenRules

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(rules) { rule in
                    CardContainer {
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Theme.primary.opacity(0.12))
                                    .frame(width: 46, height: 46)
                                Image(systemName: rule.icon)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(Theme.primary)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text("\(rule.id).")
                                        .font(.cardTitle.weight(.bold))
                                        .foregroundStyle(Theme.primary)
                                    Text(rule.ruleAr)
                                        .font(.cardTitle.weight(.semibold))
                                        .foregroundStyle(Theme.textPrimary)
                                }
                                Text(rule.applicationAr)
                                    .font(.bodyText)
                                    .foregroundStyle(Theme.textSecondary)
                                    .lineSpacing(4)
                            }
                            Spacer(minLength: 0)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("القواعد الذهبية")
        .navigationBarTitleDisplayMode(.inline)
    }
}
