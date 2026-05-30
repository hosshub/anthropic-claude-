import SwiftUI
import UIKit
import Charts

/// قسم "كيف يتجاوب جسمك؟" داخل تبويب السجل — يقرأ من BodyResponse + المناطق.
struct BodyIntelligenceSection: View {
    let meals: [Meal]
    private let calendar = Calendar.current

    private var thirtyDaysAgo: Date {
        calendar.date(byAdding: .day, value: -30, to: .now) ?? .now
    }
    private var sevenDaysAgo: Date {
        calendar.date(byAdding: .day, value: -7, to: .now) ?? .now
    }

    private var responsesIn30: [BodyResponse] {
        meals.compactMap { $0.bodyResponse }.filter { $0.loggedAt >= thirtyDaysAgo }
    }
    private var mealsWithResponseIn30: [Meal] {
        meals.filter { ($0.bodyResponse?.loggedAt ?? .distantPast) >= thirtyDaysAgo }
    }

    var body: some View {
        VStack(spacing: 14) {
            header
            metricsCard
            if responsesIn30.isEmpty {
                emptyResponsesCard
            } else {
                topComfortingCard
                heaviestCard
                sleepDistributionCard
            }
            zoneDistributionCard
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "heart.text.square.fill")
                .foregroundStyle(Theme.primary)
            Text("كيف يتجاوب جسمك؟")
                .font(.sectionTitle.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
            Spacer()
        }
    }

    // MARK: - Aggregate metrics

    private var avgSatisfaction: Double? {
        guard !responsesIn30.isEmpty else { return nil }
        return Double(responsesIn30.map(\.satisfyingFullness).reduce(0, +)) / Double(responsesIn30.count)
    }
    private var avgBloating: Double? {
        guard !responsesIn30.isEmpty else { return nil }
        return Double(responsesIn30.map(\.bloating).reduce(0, +)) / Double(responsesIn30.count)
    }

    private var metricsCard: some View {
        CardContainer {
            HStack(spacing: 14) {
                metricTile(label: "متوسط الشبع",
                           value: avgSatisfaction.map { String(format: "%.1f", $0) } ?? "—",
                           outOf: "/ ٥",
                           color: Theme.primary,
                           icon: "fork.knife.circle.fill")
                Divider()
                metricTile(label: "معدّل الانتفاخ",
                           value: avgBloating.map { String(format: "%.1f", $0) } ?? "—",
                           outOf: "/ ٥",
                           color: avgBloating.map(bloatingColor) ?? Theme.textSecondary,
                           icon: "wind")
            }
        }
    }

    private func metricTile(label: String, value: String, outOf: String, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon).foregroundStyle(color)
                Text(label).font(.caption).foregroundStyle(Theme.textSecondary)
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value).font(.scoreNumber).foregroundStyle(color)
                Text(outOf).font(.caption).foregroundStyle(Theme.textSecondary)
            }
            Text("آخر ٣٠ يوماً")
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyResponsesCard: some View {
        CardContainer {
            HStack(spacing: 10) {
                Image(systemName: "info.circle")
                    .foregroundStyle(Theme.gold)
                Text("ابدأ بتسجيل متابعة الجسم بعد وجباتك حتى يعرف التطبيق ما يناسبك ويظهر أنماطك هنا.")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }

    // MARK: - Top comforting / heaviest

    private var topComforting: [Meal] {
        mealsWithResponseIn30
            .filter { ($0.bodyResponse?.satisfyingFullness ?? 0) >= 4
                    && ($0.bodyResponse?.bloating ?? 0) <= 2 }
            .sorted { $0.capturedAt > $1.capturedAt }
            .prefix(3)
            .map { $0 }
    }

    private var heaviest: [Meal] {
        mealsWithResponseIn30
            .filter { ($0.bodyResponse?.bloating ?? 0) >= 3 }
            .sorted { ($0.bodyResponse?.bloating ?? 0) > ($1.bodyResponse?.bloating ?? 0) }
            .prefix(3)
            .map { $0 }
    }

    private var topComfortingCard: some View {
        Group {
            if !topComforting.isEmpty {
                mealsListCard(
                    title: "وجبات أعطتك راحة وشبعاً",
                    icon: "hand.thumbsup.fill",
                    accent: Theme.primary,
                    meals: topComforting,
                    badge: { meal in
                        Text("\(meal.bodyResponse?.satisfyingFullness ?? 0) / ٥ شبع")
                    }
                )
            }
        }
    }

    private var heaviestCard: some View {
        Group {
            if !heaviest.isEmpty {
                mealsListCard(
                    title: "وجبات أثقلت جسمك",
                    icon: "exclamationmark.triangle.fill",
                    accent: Theme.khabith,
                    meals: heaviest,
                    badge: { meal in
                        Text("انتفاخ \(meal.bodyResponse?.bloating ?? 0) / ٥")
                    }
                )
            }
        }
    }

    private func mealsListCard<Badge: View>(
        title: String,
        icon: String,
        accent: Color,
        meals: [Meal],
        @ViewBuilder badge: @escaping (Meal) -> Badge
    ) -> some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: icon).foregroundStyle(accent)
                    Text(title).font(.cardTitle.weight(.semibold)).foregroundStyle(Theme.textPrimary)
                }
                ForEach(meals) { meal in
                    NavigationLink {
                        MealDetailView(meal: meal)
                    } label: {
                        HStack(spacing: 12) {
                            thumbnail(for: meal)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mealLabel(meal))
                                    .font(.bodyText.weight(.semibold))
                                    .foregroundStyle(Theme.textPrimary)
                                    .lineLimit(1)
                                Text(meal.capturedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            Spacer()
                            badge(meal)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(accent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(accent.opacity(0.10), in: Capsule())
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func thumbnail(for meal: Meal) -> some View {
        Group {
            if let image = UIImage(data: meal.imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Theme.surface)
                    .frame(width: 44, height: 44)
            }
        }
    }

    private func mealLabel(_ meal: Meal) -> String {
        meal.items.first?.nameAr ?? "وجبة"
    }

    // MARK: - Sleep distribution

    private var sleepCounts: [(SleepImpact, Int)] {
        let buckets = Dictionary(grouping: responsesIn30, by: { $0.sleepImpact }).mapValues(\.count)
        return SleepImpact.allCases.map { ($0, buckets[$0] ?? 0) }
    }

    private var sleepDistributionCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "moon.stars.fill").foregroundStyle(Theme.primary)
                    Text("تأثير الوجبات على نومك").font(.cardTitle.weight(.semibold)).foregroundStyle(Theme.textPrimary)
                }
                Chart {
                    ForEach(Array(sleepCounts.enumerated()), id: \.offset) { _, entry in
                        let (impact, count) = entry
                        BarMark(
                            x: .value("عدد", count),
                            y: .value("النوم", impact.labelAr)
                        )
                        .foregroundStyle(sleepColor(impact))
                        .cornerRadius(4)
                    }
                }
                .chartXAxis(.hidden)
                .frame(height: 140)
            }
        }
    }

    private func sleepColor(_ impact: SleepImpact) -> Color {
        switch impact {
        case .positive: return Theme.primary
        case .neutral:  return Theme.textSecondary
        case .negative: return Theme.khabith
        case .unknown:  return Theme.textSecondary.opacity(0.5)
        }
    }

    // MARK: - Zone distribution

    private struct ZoneShare: Identifiable {
        let id = UUID()
        let zone: FoodZone
        let weeklyPercent: Double
        let monthlyPercent: Double
    }

    private var zoneShares: [ZoneShare] {
        let weekItems = meals.filter { $0.capturedAt >= sevenDaysAgo }.flatMap(\.items)
        let monthItems = meals.filter { $0.capturedAt >= thirtyDaysAgo }.flatMap(\.items)
        func share(_ items: [FoodItem], _ zone: FoodZone) -> Double {
            guard !items.isEmpty else { return 0 }
            let n = items.filter { $0.zone == zone }.count
            return Double(n) / Double(items.count) * 100
        }
        return FoodZone.allCases.map { z in
            ZoneShare(zone: z,
                      weeklyPercent: share(weekItems, z),
                      monthlyPercent: share(monthItems, z))
        }
    }

    private var zoneDistributionCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "circle.grid.3x3.fill").foregroundStyle(Theme.primary)
                    Text("توزّع الإشارات في طبقك").font(.cardTitle.weight(.semibold)).foregroundStyle(Theme.textPrimary)
                }
                zoneStackBar(title: "آخر ٧ أيام", value: \.weeklyPercent)
                zoneStackBar(title: "آخر ٣٠ يوماً", value: \.monthlyPercent)
            }
        }
    }

    private func zoneStackBar(title: String, value: KeyPath<ZoneShare, Double>) -> some View {
        let shares = zoneShares
        let hasData = shares.map { $0[keyPath: value] }.reduce(0, +) > 0
        return VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(Theme.textSecondary)
            if hasData {
                GeometryReader { geo in
                    HStack(spacing: 2) {
                        ForEach(shares) { share in
                            let width = geo.size.width * (share[keyPath: value] / 100)
                            Rectangle()
                                .fill(share.zone.color)
                                .frame(width: max(0, width))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                .frame(height: 14)
                HStack(spacing: 12) {
                    ForEach(shares) { share in
                        HStack(spacing: 4) {
                            Circle().fill(share.zone.color).frame(width: 8, height: 8)
                            Text("\(Int(share[keyPath: value].rounded()))% \(share.zone.labelAr)")
                                .font(.caption2)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            } else {
                Text("لا بيانات بعد").font(.caption).foregroundStyle(Theme.textSecondary)
            }
        }
    }

    private func bloatingColor(_ avg: Double) -> Color {
        switch avg {
        case ..<1.0: return Theme.primary
        case ..<2.5: return Theme.gold
        default: return Theme.khabith
        }
    }
}
