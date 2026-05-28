import SwiftUI

/// شارة صغيرة تُظهر حكم العنصر (طيب/خبيث/مشروط).
struct VerdictBadge: View {
    let verdict: Verdict

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: verdict.symbol)
            Text(verdict.labelAr)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(verdict.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(verdict.color.opacity(0.12), in: Capsule())
    }
}
