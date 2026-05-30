import Foundation

/// تمثيل قابل للتعديل لعنصر طعام داخل شاشة النتيجة قبل الحفظ.
struct EditableItem: Identifiable {
    let id = UUID()
    var nameAr: String
    var verdict: Verdict
    var zone: FoodZone
    var category: String
    var reasoning: String
    var confidence: Double
    var estimatedPortion: String
    var ruleViolated: String?
    var cautionAr: String?
    var wasEdited: Bool = false

    init(from item: AnalysisResult.Item) {
        self.nameAr = item.nameAr
        let derivedVerdict = Verdict.from(item.verdict)
        self.verdict = derivedVerdict
        // المنطقة الصريحة من v2 إن وُجدت، وإلا تُشتقّ من الحكم القديم.
        self.zone = FoodZone.from(item.zone) ?? FoodZone.fromVerdict(derivedVerdict)
        self.category = item.category
        self.reasoning = item.reasoningAr
        self.confidence = item.confidence
        self.estimatedPortion = item.estimatedPortion
        self.ruleViolated = item.ruleViolated
        self.cautionAr = item.cautionAr
    }

    var isLowConfidence: Bool { confidence < 0.7 }
}

