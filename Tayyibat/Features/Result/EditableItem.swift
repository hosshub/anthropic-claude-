import Foundation

/// تمثيل قابل للتعديل لعنصر طعام داخل شاشة النتيجة قبل الحفظ.
struct EditableItem: Identifiable {
    let id = UUID()
    var nameAr: String
    var verdict: Verdict
    var category: String
    var reasoning: String
    var confidence: Double
    var estimatedPortion: String
    var ruleViolated: String?
    var wasEdited: Bool = false

    init(from item: AnalysisResult.Item) {
        self.nameAr = item.nameAr
        self.verdict = Verdict.from(item.verdict)
        self.category = item.category
        self.reasoning = item.reasoningAr
        self.confidence = item.confidence
        self.estimatedPortion = item.estimatedPortion
        self.ruleViolated = item.ruleViolated
    }

    var isLowConfidence: Bool { confidence < 0.7 }
}
