import SwiftUI

struct GuideCategoryDetailView: View {
    let category: RulesData.Category

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let note = category.note {
                    Label(note, systemImage: "info.circle")
                        .font(.bodyText)
                        .foregroundStyle(Theme.gold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if !category.allowed.isEmpty {
                    itemList(title: "مسموح (طيّبات)", items: category.allowed, verdict: .tayyib)
                }
                if !category.forbidden.isEmpty {
                    itemList(title: "ممنوع (خبائث)", items: category.forbidden, verdict: .khabith)
                }

                MedicalDisclaimerFooter()
            }
            .padding(20)
        }
        .background(Theme.background)
        .navigationTitle(category.nameAr)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func itemList(title: String, items: [String], verdict: Verdict) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title).font(.sectionTitle).foregroundStyle(verdict.color)
                Spacer()
                Image(systemName: verdict.symbol).foregroundStyle(verdict.color)
            }
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: verdict.symbol)
                        .font(.caption).foregroundStyle(verdict.color).padding(.top, 3)
                    Text(item).font(.bodyText).foregroundStyle(Theme.textPrimary)
                    Spacer()
                }
                .padding(.vertical, 4)
                Divider()
            }
        }
        .padding(16)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
    }
}
