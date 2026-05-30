import SwiftUI
import UIKit

/// تفاصيل وجبة محفوظة (للقراءة).
struct MealDetailView: View {
    let meal: Meal

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let image = UIImage(data: meal.imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 240)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                }

                VStack(spacing: 8) {
                    Text("\(meal.overallScore)%")
                        .font(.scoreNumber)
                        .foregroundStyle(Theme.scoreColor(meal.overallScore))
                    Text(meal.scoreLabelAr.isEmpty ? Theme.scoreLabel(meal.overallScore) : meal.scoreLabelAr)
                        .font(.sectionTitle)
                        .foregroundStyle(Theme.scoreColor(meal.overallScore))
                    Text(meal.capturedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                    if meal.wasEdited {
                        Label("عُدّلت يدوياً", systemImage: "pencil")
                            .font(.caption).foregroundStyle(Theme.gold)
                    }
                }

                if !meal.scoreExplanationAr.isEmpty {
                    Text(meal.scoreExplanationAr)
                        .arabicBody()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.textSecondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("العناصر").font(.sectionTitle).foregroundStyle(Theme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach(meal.items) { item in
                        CardContainer {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(item.nameAr).font(.cardTitle).foregroundStyle(Theme.textPrimary)
                                    Spacer()
                                    VerdictBadge(zone: item.zone)
                                }
                                if item.zone == .yellow, let caution = item.cautionAr, !caution.isEmpty {
                                    Label(caution, systemImage: "eye.fill")
                                        .font(.caption)
                                        .foregroundStyle(Theme.gold)
                                }
                                Text(item.reasoning)
                                    .font(.bodyText).foregroundStyle(Theme.textSecondary).lineSpacing(4)
                            }
                        }
                    }
                }

                if !meal.improvementSuggestions.isEmpty {
                    CardContainer {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("اقتراحات للتحسين", systemImage: "lightbulb")
                                .font(.cardTitle).foregroundStyle(Theme.primary)
                            ForEach(meal.improvementSuggestions, id: \.self) { s in
                                Text("• \(s)").font(.bodyText).foregroundStyle(Theme.textPrimary)
                            }
                        }
                    }
                }

                MedicalDisclaimerFooter()
            }
            .padding(20)
        }
        .background(Theme.background)
        .navigationTitle("تفاصيل الوجبة")
        .navigationBarTitleDisplayMode(.inline)
    }
}
