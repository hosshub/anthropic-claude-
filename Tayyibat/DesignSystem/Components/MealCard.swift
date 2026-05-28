import SwiftUI

/// بطاقة وجبة مصغّرة تُعرض في سجل اليوم.
struct MealCard: View {
    let meal: Meal

    private var image: UIImage? { UIImage(data: meal.imageData) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 110)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Theme.surface)
                        .frame(width: 150, height: 110)
                        .overlay(Image(systemName: "photo").foregroundStyle(Theme.textSecondary))
                }
                Text("\(meal.overallScore)%")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.scoreColor(meal.overallScore), in: Capsule())
                    .foregroundStyle(.white)
                    .padding(8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(meal.capturedAt.formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(width: 150)
    }
}

/// بطاقة "نصيحة اليوم".
struct TipCard: View {
    let text: String
    var icon: String = "lightbulb.fill"

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Theme.gold)
            VStack(alignment: .leading, spacing: 4) {
                Text("نصيحة اليوم")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
                Text(text)
                    .font(.bodyText)
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Theme.gold.opacity(0.10), in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
    }
}

/// حاوية بطاقة عامة.
struct CardContainer<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .shadow(color: Theme.cardShadow, radius: 8, y: 4)
    }
}
