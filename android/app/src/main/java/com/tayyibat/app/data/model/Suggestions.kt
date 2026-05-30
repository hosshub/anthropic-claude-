package com.tayyibat.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/** اقتراح وجبة طيبة قادم من Gemini (عبر الوسيط). */
@Serializable
data class MealSuggestion(
    @SerialName("name_ar") val nameAr: String = "",
    @SerialName("components_ar") val componentsAr: List<String> = emptyList(),
    @SerialName("reasoning_ar") val reasoningAr: String = "",
    @SerialName("best_time_ar") val bestTimeAr: String = "",
)

/** خطة وجبات أسبوعية (٧ أيام). */
@Serializable
data class WeeklyPlan(
    @SerialName("intro_ar") val introAr: String = "",
    val days: List<DayPlan> = emptyList(),
) {
    @Serializable
    data class DayPlan(
        @SerialName("day_ar") val dayAr: String = "",
        @SerialName("meals_ar") val mealsAr: List<String> = emptyList(),
        @SerialName("note_ar") val noteAr: String = "",
    )
}
