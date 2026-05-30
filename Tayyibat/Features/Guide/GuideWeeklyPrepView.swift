import SwiftUI

/// ٠٨ — التحضير الأسبوعي (قائمة من بيانات القواعد).
struct GuideWeeklyPrepView: View {
    private let tasks = RulesService.shared.rules.weeklyPrep

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                CardContainer {
                    HStack(spacing: 10) {
                        Image(systemName: "checklist").foregroundStyle(Theme.primary)
                        Text("قائمة تحضير الأسبوع — أعدّها مرة واحدة وارتح أكثر.")
                            .font(.bodyText)
                            .foregroundStyle(Theme.textPrimary)
                    }
                }

                ForEach(tasks) { task in
                    CardContainer {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "circle")
                                .foregroundStyle(Theme.primary)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(task.titleAr)
                                    .font(.bodyText)
                                    .foregroundStyle(Theme.textPrimary)
                                    .lineSpacing(4)
                                HStack(spacing: 10) {
                                    if let mins = task.estimatedMinutes {
                                        Label("\(mins) د", systemImage: "clock")
                                            .font(.caption2)
                                            .foregroundStyle(Theme.textSecondary)
                                    }
                                    Label("صالح \(task.validDays) يوم", systemImage: "snowflake")
                                        .font(.caption2)
                                        .foregroundStyle(Theme.textSecondary)
                                    Text(categoryLabel(task.category))
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Theme.primary.opacity(0.1), in: Capsule())
                                        .foregroundStyle(Theme.primary)
                                }
                            }
                            Spacer(minLength: 0)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("التحضير الأسبوعي")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func categoryLabel(_ raw: String) -> String {
        switch raw {
        case "starch": return "نشويات"
        case "protein": return "بروتين"
        case "pantry": return "مؤن"
        case "kitchen": return "المطبخ"
        case "planning": return "تخطيط"
        default: return raw
        }
    }
}
