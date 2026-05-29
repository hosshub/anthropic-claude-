package com.tayyibat.app.ui.capture

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.tayyibat.app.AppGraph
import com.tayyibat.app.data.model.AnalysisResult
import com.tayyibat.app.data.model.EditableItem
import com.tayyibat.app.data.model.FoodItem
import com.tayyibat.app.data.model.Meal
import com.tayyibat.app.service.GeminiApiService
import com.tayyibat.app.service.ScoringHelper
import com.tayyibat.app.service.SummaryService
import com.tayyibat.app.util.DateUtils
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import java.util.UUID

/** خطوات رحلة الالتقاط: كاميرا → تحليل → نتيجة، مع معالجة الأخطاء. */
sealed interface CaptureStep {
    data object Camera : CaptureStep
    data class Analyzing(val image: ByteArray) : CaptureStep
    data class Result(val result: AnalysisResult, val image: ByteArray) : CaptureStep
    data class Error(val message: String, val image: ByteArray) : CaptureStep
}

class CaptureViewModel(app: Application) : AndroidViewModel(app) {
    private val db = AppGraph.db
    private val gemini = AppGraph.gemini

    private val _step = MutableStateFlow<CaptureStep>(CaptureStep.Camera)
    val step: StateFlow<CaptureStep> = _step

    fun reset() { _step.value = CaptureStep.Camera }

    fun beginAnalysis(rawData: ByteArray) {
        val prepared = GeminiApiService.prepareJpeg(rawData) ?: rawData
        _step.value = CaptureStep.Analyzing(prepared)
        viewModelScope.launch {
            try {
                val result = gemini.analyze(prepared)
                _step.value = CaptureStep.Result(result, prepared)
            } catch (e: Exception) {
                _step.value = CaptureStep.Error(e.message ?: "حدث خطأ غير متوقع", prepared)
            }
        }
    }

    /** يحفظ الوجبة (مع أي تعديلات يدوية) ويحدّث الملخص اليومي. */
    fun save(result: AnalysisResult, items: List<EditableItem>, imageData: ByteArray, onDone: () -> Unit) {
        viewModelScope.launch {
            val edited = items.any { it.wasEdited }
            val score = if (edited) ScoringHelper.recompute(items) else result.overallScore
            val mealId = UUID.randomUUID().toString()
            val capturedAt = DateUtils.now()

            val meal = Meal(
                id = mealId,
                capturedAt = capturedAt,
                imageData = imageData,
                overallScore = score,
                scoreLabelAr = result.scoreLabelAr,
                scoreExplanationAr = result.scoreExplanationAr,
                improvementSuggestions = result.improvementSuggestionsAr,
                wasEdited = edited,
            )
            val foodItems = items.map {
                FoodItem(
                    mealId = mealId,
                    nameAr = it.nameAr,
                    verdictRaw = it.verdict.raw,
                    category = it.category,
                    reasoning = it.reasoning,
                    confidence = it.confidence,
                    estimatedPortion = it.estimatedPortion,
                    ruleViolated = it.ruleViolated,
                )
            }
            db.mealDao().insertMealWithItems(meal, foodItems)
            SummaryService.updateSummary(capturedAt, db.mealDao(), db.summaryDao())
            onDone()
        }
    }
}
