package com.tayyibat.app.data

import android.content.Context
import android.content.SharedPreferences
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * علامة "المتابعة كضيف": يتخطّى المستخدم شاشة التسجيل ويستخدم التطبيق بلا حساب.
 * تُحفظ محلياً فلا تتكرر شاشة الدخول كل تشغيل.
 */
object GuestSession {
    private const val PREFS = "tayyibat_session"
    private const val KEY_GUEST = "guest_mode"

    private var prefs: SharedPreferences? = null
    private val _guestMode = MutableStateFlow(false)
    val guestMode: StateFlow<Boolean> = _guestMode.asStateFlow()

    fun init(context: Context) {
        val p = context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        prefs = p
        _guestMode.value = p.getBoolean(KEY_GUEST, false)
    }

    fun setGuest(value: Boolean) {
        prefs?.edit()?.putBoolean(KEY_GUEST, value)?.apply()
        _guestMode.value = value
    }
}
