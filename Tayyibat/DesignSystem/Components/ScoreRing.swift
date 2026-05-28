import SwiftUI

/// حلقة دائرية تعرض نسبة الالتزام مع رقم في المنتصف.
struct ScoreRing: View {
    let score: Int
    var size: CGFloat = 180
    var lineWidth: CGFloat = 16
    var showLabel: Bool = true

    @State private var animatedFraction: CGFloat = 0

    private var fraction: CGFloat { CGFloat(max(0, min(100, score))) / 100 }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.scoreColor(score).opacity(0.15), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: animatedFraction)
                .stroke(
                    Theme.scoreColor(score),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(score)%")
                    .font(.scoreNumber)
                    .foregroundStyle(Theme.scoreColor(score))
                if showLabel {
                    Text("طيب اليوم")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .frame(width: size, height: size)
        .onAppear { animate() }
        .onChange(of: score) { _, _ in animate() }
        .accessibilityElement()
        .accessibilityLabel("نسبة الالتزام")
        .accessibilityValue("\(score) بالمئة")
    }

    private func animate() {
        animatedFraction = 0
        withAnimation(.spring(response: 0.9, dampingFraction: 0.8)) {
            animatedFraction = fraction
        }
    }
}
