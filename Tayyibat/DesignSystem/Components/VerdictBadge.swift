import SwiftUI

/// شارة صغيرة تُظهر إشارة المنطقة (أخضر/أصفر/أحمر) عبر نقطة ملوّنة + الاسم.
/// يبقى المهيّئ القديم `init(verdict:)` للتوافق مع شاشات v1.
struct VerdictBadge: View {
    let zone: FoodZone

    init(zone: FoodZone) { self.zone = zone }

    init(verdict: Verdict) { self.zone = FoodZone.fromVerdict(verdict) }

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(zone.color)
                .frame(width: 9, height: 9)
            Text(zone.labelAr)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(zone.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(zone.color.opacity(0.12), in: Capsule())
    }
}
