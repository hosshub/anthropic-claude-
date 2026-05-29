package com.tayyibat.app

import com.tayyibat.app.data.model.AnalysisResult
import com.tayyibat.app.service.GeminiApiService
import kotlinx.serialization.json.Json
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class AnalysisDecodeTest {
    private val json = Json { ignoreUnknownKeys = true; isLenient = true }

    @Test fun decodesFullObject() {
        val raw = """
        {
          "identified_items": [
            {"name_ar":"أرز","confidence":0.9,"estimated_portion":"متوسطة","verdict":"tayyib","category":"نشويات","reasoning_ar":"مسموح"}
          ],
          "overall_score": 85,
          "score_label_ar": "جيد",
          "score_explanation_ar": "وجبة جيدة",
          "improvement_suggestions_ar": ["قلل الكمية"],
          "warnings": []
        }
        """.trimIndent()
        val result = json.decodeFromString(AnalysisResult.serializer(), raw)
        assertEquals(85, result.overallScore)
        assertEquals(1, result.identifiedItems.size)
        assertEquals("أرز", result.identifiedItems[0].nameAr)
    }

    @Test fun toleratesMissingKeys() {
        val raw = """{"overall_score": 40}"""
        val result = json.decodeFromString(AnalysisResult.serializer(), raw)
        assertEquals(40, result.overallScore)
        assertTrue(result.identifiedItems.isEmpty())
    }

    @Test fun stripsMarkdownFences() {
        val fenced = "```json\n{\"overall_score\": 70}\n```"
        val stripped = GeminiApiService.stripFences(fenced)
        val result = json.decodeFromString(AnalysisResult.serializer(), stripped)
        assertEquals(70, result.overallScore)
    }
}
