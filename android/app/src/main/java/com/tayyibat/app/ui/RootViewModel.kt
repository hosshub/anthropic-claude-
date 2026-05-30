package com.tayyibat.app.ui

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.tayyibat.app.AppGraph
import com.tayyibat.app.config.AppConfig
import com.tayyibat.app.data.GuestSession
import com.tayyibat.app.data.model.UserGoal
import com.tayyibat.app.data.model.UserProfile
import com.tayyibat.app.service.NotificationScheduler
import com.tayyibat.app.service.TipsService
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

/** يدير حالة الجذر: الملف الشخصي، المصادقة، واستعادة الجلسة. */
class RootViewModel(app: Application) : AndroidViewModel(app) {
    private val db = AppGraph.db
    val auth = AppGraph.auth

    val authState = auth.state

    val profile: StateFlow<UserProfile?> =
        db.profileDao().observe().stateIn(viewModelScope, SharingStarted.Eagerly, null)

    private val _didAttemptRestore = kotlinx.coroutines.flow.MutableStateFlow(!AppConfig.authEnabled)
    val didAttemptRestore: StateFlow<Boolean> = _didAttemptRestore

    /** "المتابعة كضيف" — يسمح باستخدام التطبيق دون تسجيل. */
    val guestMode: StateFlow<Boolean> = GuestSession.guestMode

    fun continueAsGuest() = GuestSession.setGuest(true)

    init {
        viewModelScope.launch {
            TipsService.seedIfNeeded(getApplication(), db.tipDao())
        }
        if (AppConfig.authEnabled) {
            viewModelScope.launch {
                auth.restoreIfPossible()
                _didAttemptRestore.value = true
            }
        }
    }

    /** يحفظ/يكمل الإعداد الأولي. */
    fun completeOnboarding(
        name: String,
        age: Int?,
        goal: UserGoal,
        notificationsEnabled: Boolean,
        reminderHours: List<Int>,
    ) {
        viewModelScope.launch {
            val existing = db.profileDao().get() ?: UserProfile()
            val updated = existing.copy(
                name = name.trim(),
                age = age,
                goalRaw = goal.raw,
                notificationsEnabled = notificationsEnabled,
                reminderHours = reminderHours,
                disclaimerAcceptedAt = System.currentTimeMillis(),
            )
            db.profileDao().upsert(updated)
            NotificationScheduler.reschedule(getApplication(), updated, db)
        }
    }
}
