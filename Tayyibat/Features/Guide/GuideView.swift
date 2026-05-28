import SwiftUI

struct GuideView: View {
    private let rules = RulesService.shared.rules
    @State private var query = ""

    private var searchResults: [(category: RulesData.Category, term: String, allowed: Bool)] {
        RulesService.shared.lookup(query)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    searchSection

                    if query.isEmpty {
                        rulesLinks
                        categoriesGrid
                    }

                    MedicalDisclaimerFooter()
                }
                .padding(20)
            }
            .background(Theme.background)
            .navigationTitle("دليل النظام")
        }
    }

    private var searchSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(Theme.textSecondary)
                TextField("هل (اسم الطعام) مسموح؟", text: $query)
                if !query.isEmpty {
                    Button { query = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(Theme.textSecondary) }
                }
            }
            .padding(12)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            if !query.isEmpty {
                if searchResults.isEmpty {
                    Text("لم نجد \"\(query)\" في قوائم النظام. جرّب اسماً آخر.")
                        .font(.bodyText).foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ForEach(Array(searchResults.enumerated()), id: \.offset) { _, result in
                        searchResultRow(result)
                    }
                }
            }
        }
    }

    private func searchResultRow(_ result: (category: RulesData.Category, term: String, allowed: Bool)) -> some View {
        CardContainer {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.term).font(.cardTitle).foregroundStyle(Theme.textPrimary)
                    Text(result.category.nameAr).font(.caption).foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                VerdictBadge(verdict: result.allowed ? .tayyib : .khabith)
            }
        }
    }

    private var rulesLinks: some View {
        VStack(spacing: 12) {
            NavigationLink { BehavioralRulesView() } label: {
                guideLinkRow("list.number", "القواعد السلوكية الثمانية")
            }
            NavigationLink { FastingGuideView() } label: {
                guideLinkRow("moon.stars.fill", "الصيام المستحب")
            }
        }
    }

    private func guideLinkRow(_ icon: String, _ title: String) -> some View {
        CardContainer {
            HStack(spacing: 12) {
                Image(systemName: icon).foregroundStyle(Theme.primary).frame(width: 28)
                Text(title).font(.cardTitle).foregroundStyle(Theme.textPrimary)
                Spacer()
                Image(systemName: "chevron.left").foregroundStyle(Theme.textSecondary)
            }
        }
    }

    private var categoriesGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("فئات الطعام")
                .font(.sectionTitle).foregroundStyle(Theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(rules.categories) { category in
                NavigationLink { GuideCategoryDetailView(category: category) } label: {
                    categoryRow(category)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func categoryRow(_ category: RulesData.Category) -> some View {
        CardContainer {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .foregroundStyle(Theme.primary).frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.nameAr).font(.cardTitle).foregroundStyle(Theme.textPrimary)
                    HStack(spacing: 10) {
                        if !category.allowed.isEmpty {
                            Text("\(category.allowed.count) مسموح").font(.caption).foregroundStyle(Theme.primary)
                        }
                        if !category.forbidden.isEmpty {
                            Text("\(category.forbidden.count) ممنوع").font(.caption).foregroundStyle(Theme.khabith)
                        }
                    }
                }
                Spacer()
                Image(systemName: "chevron.left").foregroundStyle(Theme.textSecondary)
            }
        }
    }
}
