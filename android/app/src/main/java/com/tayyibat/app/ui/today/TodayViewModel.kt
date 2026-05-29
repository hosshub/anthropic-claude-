package com.tayyibat.app.ui.today

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.tayyibat.app.AppGraph
import com.tayyibat.app.data.model.FastingType
import com.tayyibat.app.data.model.MealWithItems
import com.tayyibat.app.service.FastingCalculator
import com.tayyibat.app.service.SummaryService
import com.tayyibat.app.service.TipsService
import com.tayyibat.app.util.DateUtils
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import java.time.LocalDate
import kotlin.math.roundToInt

class TodayViewModel(app: Application) : AndroidViewModel(app) {
    private val db = AppGraph.db

    val todayMeals: StateFlow<List<MealWithItems>> =
        db.mealDao().observeMealsBetween(DateUtils.todayStartMillis(), DateUtils.startOfTomorrowMillis())
            .stateIn(viewModelScope, SharingStarted.Eagerly, emptyList())

    private val _streak = MutableStateFlow(0)
    val streak: StateFlow<Int> = _streak

    private val _tipOfDay = MutableStateFlow("")
    val tipOfDay: StateFlow<String> = _tipOfDay

    private val _fastedToday = MutableStateFlow(false)
    val fastedToday: StateFlow<Boolean> = _fastedToday

    val suggestedFasting: List<FastingType> = FastingCalculator.suggestedTypes(LocalDate.now())

    init {
        viewModelScope.launch {
            _tipOfDay.value = TipsService.tipOfTheDay(db.tipDao())
            _streak.value = SummaryService.currentStreak(db.summaryDao())
            _fastedToday.value = SummaryService.summaryForDay(DateUtils.now(), db.summaryDao())?.fastedToday ?: false
        }
        // أعد حساب الـ streak كلما تغيّرت وجبات اليوم.
        viewModelScope.launch {
            todayMeals.collect {
                _streak.value = SummaryService.currentStreak(db.summaryDao())
            }
        }
    }

    fun todayScore(meals: List<MealWithItems>): Int =
        if (meals.isEmpty()) 0
        else (meals.sumOf { it.meal.overallScore }.toDouble() / meals.size).roundToInt()

    fun setFasting(value: Boolean) {
        _fastedToday.value = value
        viewModelScope.launch {
            SummaryService.setFasting(value, DateUtils.now(), db.summaryDao())
        }
    }
}
