package com.tayyibat.app

import com.tayyibat.app.data.model.EditableItem
import com.tayyibat.app.data.model.Verdict
import com.tayyibat.app.service.ScoringHelper
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class ScoringTest {
    private fun item(verdict: Verdict, portion: String = "متوسطة") = EditableItem(
        nameAr = "عنصر", verdict = verdict, category = "عام", reasoning = "",
        confidence = 0.9, estimatedPortion = portion,
    )

    @Test fun emptyIsZero() {
        assertEquals(0, ScoringHelper.recompute(emptyList()))
    }

    @Test fun allTayyibIsFull() {
        val items = listOf(item(Verdict.TAYYIB), item(Verdict.TAYYIB))
        assertEquals(100, ScoringHelper.recompute(items))
    }

    @Test fun conditionalIsHalf() {
        val items = listOf(item(Verdict.CONDITIONAL))
        assertEquals(50, ScoringHelper.recompute(items))
    }

    @Test fun khabithCapsAtSixty() {
        // عنصر طيب كبير + خبيث صغير: النسبة العالية تُقصّ إلى 60 بسبب الخبيث.
        val items = listOf(item(Verdict.TAYYIB, "حصة كبيرة"), item(Verdict.KHABITH, "حصة صغيرة"))
        assertTrue(ScoringHelper.recompute(items) <= 60)
    }
}
