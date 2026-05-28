import SwiftUI

struct ResultView: View {
    let result: AnalysisResult
    let imageData: Data
    let onSave: ([EditableItem]) -> Void
    let onRetake: () -> Void

    @State private var items: [EditableItem]
    @State private var editingItem: EditableItem?
    @State private var expandedID: UUID?

    init(result: AnalysisResult, imageData: Data, onSave: @escaping ([EditableItem]) -> Void, onRetake: @escaping () -> Void) {
        self.result = result
        self.imageData = imageData
        self.onSave = onSave
        self.onRetake = onRetake
        _items = State(initialValue: result.identifiedItems.map(EditableItem.init))
    }

    /// النتيجة المعروضة: تُعاد حسابتها محلياً إذا عدّل المستخدم عنصراً.
    private var displayScore: Int {
        guard items.contains(where: { $0.wasEdited }) else { return result.overallScore }
        let temp = items.map {
            FoodItem(nameAr: $0.nameAr, verdict: $0.verdict, category: $0.category,
                     reasoning: $0.reasoning, confidence: $0.confidence, estimatedPortion: $0.estimatedPortion)
        }
        return ScoringHelper.recompute(items: temp)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                scoreHeader

                if !result.warnings.isEmpty {
                    warningsCard
                }

                itemsSection

                if !result.improvementSuggestionsAr.isEmpty {
                    suggestionsSection
                }

                MedicalDisclaimerFooter()
            }
            .padding(20)
        }
        .background(Theme.background)
        .safeAreaInset(edge: .bottom) { actionBar }
        .sheet(item: $editingItem) { item in
            EditItemView(item: item) { updated in
                if let index = items.firstIndex(where: { $0.id == updated.id }) {
                    items[index] = updated
                }
            }
        }
    }

    private var scoreHeader: some View {
        VStack(spacing: 12) {
            ScoreRing(score: displayScore, showLabel: false)
            Text(Theme.scoreLabel(displayScore))
                .font(.sectionTitle)
                .foregroundStyle(Theme.scoreColor(displayScore))
            Text(result.scoreExplanationAr)
                .font(.bodyText)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.textSecondary)
                .lineSpacing(5)
        }
    }

    private var warningsCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 8) {
                Label("ملاحظات", systemImage: "exclamationmark.bubble")
                    .font(.cardTitle)
                    .foregroundStyle(Theme.gold)
                ForEach(result.warnings, id: \.self) { w in
                    Text("• \(w)").font(.bodyText).foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("العناصر المحدَّدة")
                .font(.sectionTitle)
                .foregroundStyle(Theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(items) { item in
                itemRow(item)
            }
        }
    }

    private func itemRow(_ item: EditableItem) -> some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.nameAr).font(.cardTitle).foregroundStyle(Theme.textPrimary)
                        Text("\(item.category) • \(item.estimatedPortion)")
                            .font(.caption).foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    VerdictBadge(verdict: item.verdict)
                }

                if item.isLowConfidence {
                    Label("ثقة منخفضة — يُفضّل المراجعة", systemImage: "questionmark.circle")
                        .font(.caption)
                        .foregroundStyle(Theme.gold)
                }

                if expandedID == item.id {
                    Text(item.reasoning)
                        .font(.bodyText)
                        .foregroundStyle(Theme.textSecondary)
                        .lineSpacing(5)
                        .padding(.top, 2)
                }

                HStack(spacing: 16) {
                    Button(expandedID == item.id ? "إخفاء التفسير" : "التفسير") {
                        withAnimation { expandedID = expandedID == item.id ? nil : item.id }
                    }
                    Button("تعديل") { editingItem = item }
                    if item.wasEdited {
                        Text("مُعدّل").font(.caption).foregroundStyle(Theme.gold)
                    }
                    Spacer()
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.primary)
            }
        }
    }

    private var suggestionsSection: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 10) {
                Label("اقتراحات للتحسين", systemImage: "lightbulb")
                    .font(.cardTitle)
                    .foregroundStyle(Theme.primary)
                ForEach(result.improvementSuggestionsAr, id: \.self) { s in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.caption).foregroundStyle(Theme.primary).padding(.top, 3)
                        Text(s).font(.bodyText).foregroundStyle(Theme.textPrimary)
                    }
                }
            }
        }
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button(action: onRetake) {
                Image(systemName: "camera.rotate")
                    .font(.title3)
                    .foregroundStyle(Theme.primary)
                    .frame(width: 54, height: 54)
                    .background(Theme.surface, in: Circle())
            }
            ShareLink(item: shareText) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
                    .foregroundStyle(Theme.primary)
                    .frame(width: 54, height: 54)
                    .background(Theme.surface, in: Circle())
            }
            PrimaryButton(title: "حفظ في السجل", systemImage: "checkmark") {
                onSave(items)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
    }

    private var shareText: String {
        let names = items.map { "\($0.nameAr) (\($0.verdict.labelAr))" }.joined(separator: "، ")
        return "نتيجتي في الطيبات: \(displayScore)% — \(Theme.scoreLabel(displayScore)).\nالعناصر: \(names)"
    }
}

/// فوتر التنبيه الطبي المختصر.
struct MedicalDisclaimerFooter: View {
    var body: some View {
        Text("تنبيه: هذا التطبيق لا يقدّم استشارة طبية. النتائج لأغراض التتبّع فقط.")
            .font(.caption)
            .multilineTextAlignment(.center)
            .foregroundStyle(Theme.textSecondary)
            .padding(.top, 8)
    }
}
