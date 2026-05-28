import SwiftUI
import UIKit

/// شاشة التحميل أثناء تحليل الوجبة، بتأثير لمعان.
struct AnalyzingView: View {
    let image: UIImage?

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 220, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shimmer()
            } else {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Theme.surface)
                    .frame(width: 220, height: 220)
                    .shimmer()
            }

            VStack(spacing: 8) {
                ProgressView().tint(Theme.primary)
                Text("نحلّل وجبتك الآن…")
                    .font(.sectionTitle)
                    .foregroundStyle(Theme.textPrimary)
                Text("نتعرّف على العناصر ونحسب نسبة الالتزام")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background.ignoresSafeArea())
    }
}
