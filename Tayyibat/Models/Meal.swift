import Foundation
import SwiftData

@Model
final class Meal {
    var id: UUID
    var capturedAt: Date
    @Attribute(.externalStorage) var imageData: Data
    var overallScore: Int
    var scoreLabelAr: String
    var scoreExplanationAr: String
    var improvementSuggestions: [String]
    @Relationship(deleteRule: .cascade, inverse: \FoodItem.meal) var items: [FoodItem]
    var userNotes: String?
    var wasEdited: Bool

    init(
        id: UUID = UUID(),
        capturedAt: Date = .now,
        imageData: Data,
        overallScore: Int,
        scoreLabelAr: String = "",
        scoreExplanationAr: String = "",
        improvementSuggestions: [String] = [],
        items: [FoodItem] = [],
        userNotes: String? = nil,
        wasEdited: Bool = false
    ) {
        self.id = id
        self.capturedAt = capturedAt
        self.imageData = imageData
        self.overallScore = overallScore
        self.scoreLabelAr = scoreLabelAr
        self.scoreExplanationAr = scoreExplanationAr
        self.improvementSuggestions = improvementSuggestions
        self.items = items
        self.userNotes = userNotes
        self.wasEdited = wasEdited
    }
}

@Model
final class FoodItem {
    var nameAr: String
    var verdictRaw: String
    var category: String
    var reasoning: String
    var confidence: Double
    var estimatedPortion: String
    var ruleViolated: String?
    /// v2 — تصنيف المنطقة (أخضر/أصفر/أحمر). يبقى اختيارياً للتوافق مع وجبات v1.
    var zoneRaw: String?
    /// v2 — تنبيه خاص للعنصر الأصفر (مراقبة الهضم/الطاقة ونحوها).
    var cautionAr: String?
    var meal: Meal?

    var verdict: Verdict {
        get { Verdict.from(verdictRaw) }
        set { verdictRaw = newValue.rawValue }
    }

    /// المنطقة المعتمدة: zoneRaw الصريح إن وُجد، وإلا تُشتقّ من الحكم القديم.
    var zone: FoodZone {
        FoodZone.from(zoneRaw) ?? FoodZone.fromVerdict(verdict)
    }

    init(
        nameAr: String,
        verdict: Verdict,
        category: String,
        reasoning: String,
        confidence: Double,
        estimatedPortion: String = "متوسطة",
        ruleViolated: String? = nil,
        zone: FoodZone? = nil,
        cautionAr: String? = nil
    ) {
        self.nameAr = nameAr
        self.verdictRaw = verdict.rawValue
        self.category = category
        self.reasoning = reasoning
        self.confidence = confidence
        self.estimatedPortion = estimatedPortion
        self.ruleViolated = ruleViolated
        self.zoneRaw = zone?.rawValue
        self.cautionAr = cautionAr
    }
}
