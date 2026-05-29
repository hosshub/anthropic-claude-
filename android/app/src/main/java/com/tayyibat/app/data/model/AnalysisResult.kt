package com.tayyibat.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import java.util.UUID

/**
 * نتيجة تحليل الوجبة كما تصل من Claude.
 * فك الترميز متسامح: المفاتيح الناقصة تأخذ قيماً افتراضية بدل أن يفشل التحليل
 * (تُضبط القيم الافتراضية على مستوى الخصائص، ويُفعَّل ignoreUnknownKeys في الـ Json).
 */
@Serializable
data class AnalysisResult(
    @SerialName("identified_items") val identifiedItems: List<Item> = emptyList(),
    @SerialName("overall_score") val overallScore: Int = 0,
    @SerialName("score_label_ar") val scoreLabelAr: String = "",
    @SerialName("score_explanation_ar") val scoreExplanationAr: String = "",
    @SerialName("improvement_suggestions_ar") val improvementSuggestionsAr: List<String> = emptyList(),
    val warnings: List<String> = emptyList(),
) {
    @Serializable
    data class Item(
        @SerialName("name_ar") val nameAr: String = "غير معروف",
        val confidence: Double = 0.5,
        @SerialName("estimated_portion") val estimatedPortion: String = "متوسطة",
        val verdict: String = "conditional",
        val category: String = "عام",
        @SerialName("reasoning_ar") val reasoningAr: String = "",
        @SerialName("rule_violated") val ruleViolated: String? = null,
    )
}

/** تمثيل قابل للتعديل لعنصر طعام داخل شاشة النتيجة قبل الحفظ. */
data class EditableItem(
    val id: String = UUID.randomUUID().toString(),
    var nameAr: String,
    var verdict: Verdict,
    var category: String,
    var reasoning: String,
    var confidence: Double,
    var estimatedPortion: String,
    var ruleViolated: String? = null,
    var wasEdited: Boolean = false,
) {
    val isLowConfidence: Boolean get() = confidence < 0.7

    companion object {
        fun from(item: AnalysisResult.Item): EditableItem = EditableItem(
            nameAr = item.nameAr,
            verdict = Verdict.from(item.verdict),
            category = item.category,
            reasoning = item.reasoningAr,
            confidence = item.confidence,
            estimatedPortion = item.estimatedPortion,
            ruleViolated = item.ruleViolated,
        )
    }
}
