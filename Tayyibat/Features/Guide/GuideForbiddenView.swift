import SwiftUI

/// ٠٤ — الممنوعات الصريحة (المنطقة الحمراء).
struct GuideForbiddenView: View {
    private let red = RulesService.shared.rules.zones.red

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                CardContainer {
                    HStack(spacing: 10) {
                        Image(systemName: "xmark.octagon.fill")
                            .foregroundStyle(Theme.khabith)
                        Text(red.subtitleAr)
                            .font(.bodyText.weight(.semibold))
                            .foregroundStyle(Theme.khabith)
                        Spacer()
                    }
                }
                ForEach(red.groups) { group in
                    if let category = group.categoryAr, let items = group.items {
                        CardContainer {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(category)
                                    .font(.cardTitle.weight(.bold))
                                    .foregroundStyle(Theme.khabith)
                                ForEach(items, id: \.self) { item in
                                    HStack(spacing: 8) {
                                        Image(systemName: "xmark")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(Theme.khabith.opacity(0.7))
                                        Text(item)
                                            .font(.bodyText)
                                            .foregroundStyle(Theme.textPrimary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("الممنوعات الصريحة")
        .navigationBarTitleDisplayMode(.inline)
    }
}
