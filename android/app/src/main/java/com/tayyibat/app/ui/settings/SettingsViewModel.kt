package com.tayyibat.app.ui.settings

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.tayyibat.app.AppGraph
import com.tayyibat.app.data.model.NotificationIntensity
import com.tayyibat.app.data.model.UserGoal
import com.tayyibat.app.data.model.UserProfile
import com.tayyibat.app.service.DataExportService
import com.tayyibat.app.service.NotificationScheduler
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import java.io.File

class SettingsViewModel(app: Application) : AndroidViewModel(app) {
    private val db = AppGraph.db
    val auth = AppGraph.auth

    val profile: StateFlow<UserProfile?> =
        db.profileDao().observe().stateIn(viewModelScope, SharingStarted.Eagerly, null)

    private fun update(transform: (UserProfile) -> UserProfile) {
        viewModelScope.launch {
            val current = db.profileDao().get() ?: return@launch
            db.profileDao().upsert(transform(current))
        }
    }

    fun updateName(name: String) = update { it.copy(name = name) }
    fun updateGoal(goal: UserGoal) = update { it.copy(goalRaw = goal.raw) }

    /** يحدّث الملف ثم يعيد جدولة الإشعارات. */
    fun updateAndReschedule(transform: (UserProfile) -> UserProfile) {
        viewModelScope.launch {
            val current = db.profileDao().get() ?: return@launch
            val updated = transform(current)
            db.profileDao().upsert(updated)
            NotificationScheduler.reschedule(getApplication(), updated, db)
        }
    }

    fun setIntensity(intensity: NotificationIntensity) =
        updateAndReschedule { it.copy(dailyTipsIntensityRaw = intensity.raw) }

    fun exportData(onReady: (File?) -> Unit) {
        viewModelScope.launch {
            onReady(DataExportService.exportFile(getApplication(), db))
        }
    }

    fun deleteAllData() {
        viewModelScope.launch { DataExportService.deleteAllTrackingData(db) }
    }

    fun signOut() = auth.signOut()
}
