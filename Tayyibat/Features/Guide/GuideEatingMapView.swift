import SwiftUI

/// ٠٣ — خريطة الأكل (المناطق الثلاث).
struct GuideEatingMapView: View {
    private let zones = RulesService.shared.rules.zones

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                zoneSection(.green, data: zones.green)
                zoneSection(.yellow, data: zones.yellow)
                zoneSection(.red, data: zones.red)
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("خريطة الأكل")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func zoneSection(_ zone: FoodZone, data: RulesData.Zone) -> some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Circle().fill(zone.color).frame(width: 14, height: 14)
                    Text(data.labelAr)
                        .font(.sectionTitle.weight(.bold))
                        .foregroundStyle(zone.color)
                    Spacer()
                }
                Text(data.subtitleAr)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                if let watchword = data.watchwordAr {
                    Text(watchword)
                        .font(.caption)
                        .italic()
                        .foregroundStyle(Theme.textSecondary)
                }
                ForEach(data.groups) { group in
                    groupRow(group, zone: zone)
                }
            }
        }
    }

    @ViewBuilder
    private func groupRow(_ group: RulesData.ZoneGroup, zone: FoodZone) -> some View {
        if let category = group.categoryAr, let items = group.items {
            VStack(alignment: .leading, spacing: 4) {
                Text(category)
                    .font(.cardTitle.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                ForEach(items, id: \.self) { item in
                    HStack(spacing: 8) {
                        Circle().fill(zone.color).frame(width: 6, height: 6)
                        Text(item)
                            .font(.bodyText)
                            .foregroundStyle(Theme.textPrimary)
                    }
                }
            }
        } else if let itemAr = group.itemAr {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Circle().fill(zone.color).frame(width: 8, height: 8)
                    Text(itemAr)
                        .font(.cardTitle.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                }
                if let examples = group.examplesAr {
                    Text("أمثلة: \(examples)")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                if let guidance = group.guidanceAr {
                    Text(guidance)
                        .font(.caption)
                        .italic()
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }
}
