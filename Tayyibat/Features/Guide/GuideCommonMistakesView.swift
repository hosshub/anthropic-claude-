import SwiftUI

/// ٠٩ — الأخطاء الشائعة وتصحيحها.
struct GuideCommonMistakesView: View {
    private let mistakes = RulesService.shared.rules.commonMistakes

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(mistakes) { mistake in
                    CardContainer {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "xmark.octagon.fill")
                                    .foregroundStyle(Theme.khabith)
                                Text(mistake.mistakeAr)
                                    .font(.bodyText.weight(.semibold))
                                    .foregroundStyle(Theme.textPrimary)
                                    .lineSpacing(4)
                                Spacer(minLength: 0)
                            }
                            .padding(.bottom, 10)

                            Divider()

                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(Theme.primary)
                                Text(mistake.correctionAr)
                                    .font(.bodyText)
                                    .foregroundStyle(Theme.textPrimary)
                                    .lineSpacing(4)
                                Spacer(minLength: 0)
                            }
                            .padding(.top, 10)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("الأخطاء الشائعة")
        .navigationBarTitleDisplayMode(.inline)
    }
}
