import Foundation
import SwiftData

/// يصدّر بيانات المتابعة إلى ملف JSON قابل للمشاركة.
enum DataExportService {
    private struct Export: Codable {
        var exportedAt: Date
        var meals: [MealExport]
        var summaries: [SummaryExport]
    }
    private struct MealExport: Codable {
        var capturedAt: Date
        var overallScore: Int
        var scoreLabel: String
        var wasEdited: Bool
        var items: [ItemExport]
    }
    private struct ItemExport: Codable {
        var nameAr: String
        var verdict: String
        var category: String
        var confidence: Double
    }
    private struct SummaryExport: Codable {
        var date: Date
        var averageScore: Int
        var mealsCount: Int
        var fastedToday: Bool
    }

    /// ينشئ ملف JSON مؤقتاً ويعيد مساره للمشاركة.
    static func exportFile(context: ModelContext) -> URL? {
        let meals = (try? context.fetch(FetchDescriptor<Meal>(sortBy: [SortDescriptor(\.capturedAt)]))) ?? []
        let summaries = (try? context.fetch(FetchDescriptor<DailySummary>(sortBy: [SortDescriptor(\.date)]))) ?? []

        let export = Export(
            exportedAt: .now,
            meals: meals.map { meal in
                MealExport(
                    capturedAt: meal.capturedAt,
                    overallScore: meal.overallScore,
                    scoreLabel: meal.scoreLabelAr,
                    wasEdited: meal.wasEdited,
                    items: meal.items.map {
                        ItemExport(nameAr: $0.nameAr, verdict: $0.verdictRaw, category: $0.category, confidence: $0.confidence)
                    }
                )
            },
            summaries: summaries.map {
                SummaryExport(date: $0.date, averageScore: $0.averageScore, mealsCount: $0.mealsCount, fastedToday: $0.fastedToday)
            }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(export) else { return nil }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("tayyibat_export.json")
        try? data.write(to: url)
        return url
    }

    /// يحذف كل بيانات المتابعة (الوجبات والملخصات وأيام الصيام).
    static func deleteAllTrackingData(context: ModelContext) {
        try? context.delete(model: Meal.self)
        try? context.delete(model: FoodItem.self)
        try? context.delete(model: DailySummary.self)
        try? context.delete(model: FastingDay.self)
        try? context.save()
    }
}
