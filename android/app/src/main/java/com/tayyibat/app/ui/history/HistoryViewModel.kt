package com.tayyibat.app.ui.history

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.tayyibat.app.AppGraph
import com.tayyibat.app.data.model.DailySummary
import com.tayyibat.app.data.model.MealWithItems
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn

class HistoryViewModel(app: Application) : AndroidViewModel(app) {
    private val db = AppGraph.db

    val meals: StateFlow<List<MealWithItems>> =
        db.mealDao().observeAllMeals().stateIn(viewModelScope, SharingStarted.Eagerly, emptyList())

    val summaries: StateFlow<List<DailySummary>> =
        db.summaryDao().observeAll().stateIn(viewModelScope, SharingStarted.Eagerly, emptyList())
}
