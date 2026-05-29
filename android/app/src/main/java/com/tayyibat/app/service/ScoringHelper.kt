package com.tayyibat.app.service

import com.tayyibat.app.data.model.EditableItem
import com.tayyibat.app.data.model.Verdict
import kotlin.math.roundToInt

/**
 * إعادة حساب نسبة الالتزام محلياً بعد تعديل المستخدم لعناصر الوجبة.
 * (التحليل الأصلي يأتي من Gemini؛ هذا يُستخدم فقط عند التعديل اليدوي.)
 */
object ScoringHelper {
    private fun portionWeight(portion: String): Double = when {
        portion.contains("صغير") -> 1.0
        portion.contains("كبير") -> 3.0
        else -> 2.0 // متوسطة أو غير معروف
    }

    private fun verdictFactor(verdict: Verdict): Double = when (verdict) {
        Verdict.TAYYIB -> 1.0
        Verdict.CONDITIONAL -> 0.5
        Verdict.KHABITH -> 0.0
    }

    /** يحسب النتيجة من العناصر مع تطبيق سقف 60 عند وجود عنصر خبيث صريح. */
    fun recompute(items: List<EditableItem>): Int {
        if (items.isEmpty()) return 0

        var totalWeight = 0.0
        var earned = 0.0
        var hasKhabith = false

        for (item in items) {
            val w = portionWeight(item.estimatedPortion)
            totalWeight += w
            earned += w * verdictFactor(item.verdict)
            if (item.verdict == Verdict.KHABITH) hasKhabith = true
        }

        if (totalWeight <= 0) return 0
        var score = (earned / totalWeight * 100).roundToInt()
        if (hasKhabith) score = minOf(score, 60)
        return score.coerceIn(0, 100)
    }
}
