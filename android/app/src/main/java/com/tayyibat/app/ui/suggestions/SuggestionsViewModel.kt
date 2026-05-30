package com.tayyibat.app.ui.suggestions

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.tayyibat.app.AppGraph
import com.tayyibat.app.data.model.MealSuggestion
import com.tayyibat.app.data.model.WeeklyPlan
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/** حالة شاشة الاقتراحات الذكية (اقتراح وجبة + خطة أسبوعية). */
data class SuggestionsUiState(
    val mealLoading: Boolean = false,
    val meal: MealSuggestion? = null,
    val mealError: String? = null,
    val planLoading: Boolean = false,
    val plan: WeeklyPlan? = null,
    val planError: String? = null,
)

class SuggestionsViewModel(app: Application) : AndroidViewModel(app) {
    private val gemini = AppGraph.gemini

    private val _state = MutableStateFlow(SuggestionsUiState())
    val state: StateFlow<SuggestionsUiState> = _state.asStateFlow()

    fun suggestMeal() {
        if (_state.value.mealLoading) return
        _state.value = _state.value.copy(mealLoading = true, mealError = null)
        viewModelScope.launch {
            try {
                val result = gemini.suggestMeal()
                _state.value = _state.value.copy(mealLoading = false, meal = result)
            } catch (e: Exception) {
                _state.value = _state.value.copy(
                    mealLoading = false,
                    mealError = e.message ?: "تعذّر جلب الاقتراح",
                )
            }
        }
    }

    fun generatePlan() {
        if (_state.value.planLoading) return
        _state.value = _state.value.copy(planLoading = true, planError = null)
        viewModelScope.launch {
            try {
                val result = gemini.generateWeeklyPlan()
                _state.value = _state.value.copy(planLoading = false, plan = result)
            } catch (e: Exception) {
                _state.value = _state.value.copy(
                    planLoading = false,
                    planError = e.message ?: "تعذّر توليد الخطة",
                )
            }
        }
    }
}
