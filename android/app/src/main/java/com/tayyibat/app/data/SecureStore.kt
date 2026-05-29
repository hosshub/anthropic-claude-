package com.tayyibat.app.data

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey

/**
 * تخزين آمن مشفّر (بديل Keychain في iOS) لمفتاح Gemini API وجلسة Supabase.
 */
object SecureStore {
    private const val PREFS_NAME = "tayyibat_secure_prefs"
    private const val KEY_API = "gemini_api_key"
    private const val KEY_SESSION = "supabase_session"

    @Volatile private var prefs: SharedPreferences? = null

    private fun prefs(context: Context): SharedPreferences =
        prefs ?: synchronized(this) {
            prefs ?: run {
                val masterKey = MasterKey.Builder(context.applicationContext)
                    .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
                    .build()
                EncryptedSharedPreferences.create(
                    context.applicationContext,
                    PREFS_NAME,
                    masterKey,
                    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
                ).also { prefs = it }
            }
        }

    // مفتاح Gemini API
    fun saveApiKey(context: Context, key: String) {
        prefs(context).edit().putString(KEY_API, key).apply()
    }

    fun loadApiKey(context: Context): String? =
        prefs(context).getString(KEY_API, null)?.takeIf { it.isNotEmpty() }

    fun deleteApiKey(context: Context) {
        prefs(context).edit().remove(KEY_API).apply()
    }

    fun hasApiKey(context: Context): Boolean = !loadApiKey(context).isNullOrEmpty()

    // جلسة Supabase (JSON مُسلسَل)
    fun saveSession(context: Context, json: String) {
        prefs(context).edit().putString(KEY_SESSION, json).apply()
    }

    fun loadSession(context: Context): String? = prefs(context).getString(KEY_SESSION, null)

    fun clearSession(context: Context) {
        prefs(context).edit().remove(KEY_SESSION).apply()
    }
}
