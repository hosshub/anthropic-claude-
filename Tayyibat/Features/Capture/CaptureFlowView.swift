import SwiftUI
import UIKit
import SwiftData

private enum CaptureStep {
    case camera
    case analyzing(Data)
    case result(AnalysisResult, Data)
    case error(String, Data)
}

/// يقود رحلة التقاط الوجبة: كاميرا → تحليل → نتيجة، مع معالجة الأخطاء.
struct CaptureFlowView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var step: CaptureStep = .camera

    var body: some View {
        Group {
            switch step {
            case .camera:
                CameraView(
                    onCapture: { data in beginAnalysis(rawData: data) },
                    onCancel: { dismiss() }
                )

            case .analyzing(let data):
                AnalyzingView(image: UIImage(data: data))

            case .result(let result, let data):
                ResultView(
                    result: result,
                    imageData: data,
                    onSave: { editedItems in save(result: result, items: editedItems, imageData: data) },
                    onRetake: { step = .camera }
                )

            case .error(let message, let data):
                errorView(message: message, data: data)
            }
        }
    }

    private func beginAnalysis(rawData: Data) {
        let prepared = ClaudeAPIService.prepareJPEG(from: rawData) ?? rawData
        step = .analyzing(prepared)
        Task {
            do {
                let result = try await ClaudeAPIService().analyze(imageData: prepared)
                await MainActor.run { step = .result(result, prepared) }
            } catch {
                let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                await MainActor.run { step = .error(message, prepared) }
            }
        }
    }

    /// يحفظ الوجبة (مع أي تعديلات يدوية) ويحدّث الملخص اليومي.
    private func save(result: AnalysisResult, items: [EditableItem], imageData: Data) {
        let foodItems = items.map { item in
            FoodItem(
                nameAr: item.nameAr,
                verdict: item.verdict,
                category: item.category,
                reasoning: item.reasoning,
                confidence: item.confidence,
                estimatedPortion: item.estimatedPortion,
                ruleViolated: item.ruleViolated
            )
        }
        let edited = items.contains { $0.wasEdited }
        let score = edited ? ScoringHelper.recompute(items: foodItems) : result.overallScore

        let meal = Meal(
            imageData: imageData,
            overallScore: score,
            scoreLabelAr: result.scoreLabelAr,
            scoreExplanationAr: result.scoreExplanationAr,
            improvementSuggestions: result.improvementSuggestionsAr,
            items: foodItems,
            wasEdited: edited
        )
        context.insert(meal)
        try? context.save()
        SummaryService.updateSummary(for: meal.capturedAt, context: context)
        dismiss()
    }

    private func errorView(message: String, data: Data) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(Theme.khabith)
            Text("تعذّر تحليل الوجبة")
                .font(.sectionTitle)
                .foregroundStyle(Theme.textPrimary)
            Text(message)
                .font(.bodyText)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.textSecondary)
                .padding(.horizontal, 32)
            Spacer()
            VStack(spacing: 10) {
                PrimaryButton(title: "إعادة المحاولة", systemImage: "arrow.clockwise") {
                    beginAnalysis(rawData: data)
                }
                SecondaryButton(title: "إعادة التقاط") { step = .camera }
                Button("إلغاء") { dismiss() }
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background.ignoresSafeArea())
    }
}
