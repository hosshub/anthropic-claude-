import SwiftUI
import SwiftData

/// قائمة وجبات يوم معيّن.
struct DayDetailView: View {
    let date: Date
    @Environment(\.modelContext) private var context

    private var meals: [Meal] { SummaryService.mealsOfDay(date, context: context) }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if meals.isEmpty {
                    ContentUnavailableView("لا وجبات في هذا اليوم", systemImage: "tray")
                        .padding(.top, 60)
                } else {
                    ForEach(meals) { meal in
                        NavigationLink {
                            MealDetailView(meal: meal)
                        } label: {
                            mealRow(meal)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .background(Theme.background)
        .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func mealRow(_ meal: Meal) -> some View {
        CardContainer {
            HStack(spacing: 14) {
                if let image = UIImage(data: meal.imageData) {
                    Image(uiImage: image)
                        .resizable().scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(meal.scoreLabelAr.isEmpty ? Theme.scoreLabel(meal.overallScore) : meal.scoreLabelAr)
                        .font(.cardTitle).foregroundStyle(Theme.textPrimary)
                    Text(meal.capturedAt.formatted(date: .omitted, time: .shortened))
                        .font(.caption).foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Text("\(meal.overallScore)%")
                    .font(.cardTitle.weight(.bold))
                    .foregroundStyle(Theme.scoreColor(meal.overallScore))
            }
        }
    }
}
