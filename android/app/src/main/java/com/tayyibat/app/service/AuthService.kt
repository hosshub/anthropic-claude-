package com.tayyibat.app.service

import android.content.Context
import android.content.Intent
import android.net.Uri
import com.tayyibat.app.config.AppConfig
import com.tayyibat.app.data.SecureStore
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.withContext
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.put
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import java.security.MessageDigest
import java.security.SecureRandom

/**
 * مصادقة المستخدم عبر Supabase (GoTrue) باستخدام REST مباشرةً.
 * - البريد/كلمة المرور: مباشرةً.
 * - Google (وغيره): عبر المتصفح مع PKCE وإعادة توجيه عميق (deep link).
 */
class AuthService(private val appContext: Context) {

    @Serializable
    data class StoredSession(
        val accessToken: String,
        val refreshToken: String,
        val email: String? = null,
    )

    data class UiState(
        val isAuthenticated: Boolean = false,
        val userEmail: String? = null,
        val isWorking: Boolean = false,
        val lastError: String? = null,
        val infoMessage: String? = null,
    )

    private val json = Json { ignoreUnknownKeys = true; isLenient = true }
    private val _state = MutableStateFlow(UiState())
    val state: StateFlow<UiState> = _state.asStateFlow()

    private var accessToken: String? = null
    private var refreshToken: String? = null
    private var pendingVerifier: String? = null

    val isEnabled: Boolean get() = AppConfig.authEnabled

    // استعادة الجلسة عند الإقلاع
    suspend fun restoreIfPossible() {
        if (!isEnabled) return
        val stored = loadSession() ?: return
        refreshToken = stored.refreshToken
        _state.value = _state.value.copy(userEmail = stored.email)
        val ok = postToken("token?grant_type=refresh_token", buildJsonObject {
            put("refresh_token", stored.refreshToken)
        })
        if (!ok) signOut()
    }

    suspend fun signIn(email: String, password: String) {
        if (!isEnabled) { setError("لم تُضبط مصادقة Supabase بعد."); return }
        clearMessages()
        postToken("token?grant_type=password", buildJsonObject {
            put("email", email); put("password", password)
        })
    }

    suspend fun signUp(email: String, password: String) = withContext(Dispatchers.IO) {
        if (!isEnabled) { setError("لم تُضبط مصادقة Supabase بعد."); return@withContext }
        clearMessages()
        working(true)
        try {
            val (code, body) = post(
                "${AppConfig.SUPABASE_URL}/auth/v1/signup",
                mapOf("apikey" to AppConfig.SUPABASE_ANON_KEY, "Content-Type" to "application/json"),
                buildJsonObject { put("email", email); put("password", password) }.toString(),
            )
            if (code !in 200..299) {
                setError(errorMessage(body) ?: "تعذّر إنشاء الحساب.")
                return@withContext
            }
            val token = runCatching { json.decodeFromString(TokenResponse.serializer(), body) }.getOrNull()
            if (token != null) {
                setSession(token.access_token, token.refresh_token, token.user?.email)
            } else {
                _state.value = _state.value.copy(
                    infoMessage = "أنشأنا حسابك. تحقّق من بريدك لتأكيد الحساب، ثم سجّل الدخول.",
                )
            }
        } finally {
            working(false)
        }
    }

    // Google / OAuth عبر المتصفح + PKCE
    fun buildGoogleAuthIntent(): Intent {
        val verifier = randomUrlSafe(64)
        pendingVerifier = verifier
        val challenge = codeChallenge(verifier)
        val url = "${AppConfig.SUPABASE_URL}/auth/v1/authorize" +
            "?provider=google" +
            "&redirect_to=${enc(AppConfig.AUTH_REDIRECT_URL)}" +
            "&code_challenge=${enc(challenge)}" +
            "&code_challenge_method=s256"
        return Intent(Intent.ACTION_VIEW, Uri.parse(url))
    }

    /** يعالج إعادة التوجيه القادمة من المتصفح (deep link). */
    suspend fun handleOAuthCallback(uri: Uri) {
        val code = uri.getQueryParameter("code")
        val verifier = pendingVerifier
        if (code != null && verifier != null) {
            postToken("token?grant_type=pkce", buildJsonObject {
                put("auth_code", code); put("code_verifier", verifier)
            })
            pendingVerifier = null
            return
        }
        // قد يصل الرمز عبر الـ fragment في بعض التهيئات.
        val fragment = uri.fragment
        if (fragment != null) {
            val pairs = parsePairs(fragment)
            val access = pairs["access_token"]; val refresh = pairs["refresh_token"]
            if (access != null && refresh != null) {
                setSession(access, refresh, null)
                fetchUser()
                return
            }
            pairs["error_description"]?.let { setError(it.replace("+", " ")); return }
        }
        setError("تعذّر إتمام تسجيل الدخول.")
    }

    private suspend fun fetchUser() = withContext(Dispatchers.IO) {
        val token = accessToken ?: return@withContext
        runCatching {
            val (code, body) = get(
                "${AppConfig.SUPABASE_URL}/auth/v1/user",
                mapOf("apikey" to AppConfig.SUPABASE_ANON_KEY, "Authorization" to "Bearer $token"),
            )
            if (code == 200) {
                val email = json.parseToJsonElement(body).jsonObject["email"]?.jsonPrimitive?.content
                if (email != null) {
                    _state.value = _state.value.copy(userEmail = email)
                    loadSession()?.let { saveSession(it.copy(email = email)) }
                }
            }
        }
    }

    fun signOut() {
        accessToken = null
        refreshToken = null
        SecureStore.clearSession(appContext)
        _state.value = UiState()
    }

    fun setError(message: String) {
        _state.value = _state.value.copy(lastError = message, isWorking = false)
    }

    fun clearMessages() {
        _state.value = _state.value.copy(lastError = null, infoMessage = null)
    }

    // نقطة token
    private suspend fun postToken(path: String, body: JsonObject): Boolean = withContext(Dispatchers.IO) {
        working(true)
        try {
            val (code, resp) = post(
                "${AppConfig.SUPABASE_URL}/auth/v1/$path",
                mapOf("apikey" to AppConfig.SUPABASE_ANON_KEY, "Content-Type" to "application/json"),
                body.toString(),
            )
            if (code !in 200..299) {
                setError(errorMessage(resp) ?: "تعذّر تسجيل الدخول.")
                return@withContext false
            }
            val token = json.decodeFromString(TokenResponse.serializer(), resp)
            setSession(token.access_token, token.refresh_token, token.user?.email)
            true
        } catch (e: Exception) {
            setError("تعذّر الاتصال: ${e.message}")
            false
        } finally {
            working(false)
        }
    }

    private fun setSession(access: String, refresh: String, email: String?) {
        accessToken = access
        refreshToken = refresh
        val newEmail = email ?: _state.value.userEmail
        saveSession(StoredSession(access, refresh, newEmail))
        _state.value = UiState(isAuthenticated = true, userEmail = newEmail)
    }

    private fun working(v: Boolean) {
        _state.value = _state.value.copy(isWorking = v)
    }

    // التخزين
    private fun saveSession(session: StoredSession) =
        SecureStore.saveSession(appContext, json.encodeToString(StoredSession.serializer(), session))

    private fun loadSession(): StoredSession? =
        SecureStore.loadSession(appContext)?.let {
            runCatching { json.decodeFromString(StoredSession.serializer(), it) }.getOrNull()
        }

    // نماذج الاستجابة
    @Serializable
    private data class TokenResponse(
        val access_token: String,
        val refresh_token: String,
        val user: SBUser? = null,
    )

    @Serializable
    private data class SBUser(val email: String? = null)

    private fun errorMessage(data: String): String? = runCatching {
        val obj = json.parseToJsonElement(data).jsonObject
        listOf("error_description", "msg", "error", "message")
            .firstNotNullOfOrNull { obj[it]?.jsonPrimitive?.content }
    }.getOrNull()

    private fun parsePairs(fragment: String): Map<String, String> =
        fragment.split("&").mapNotNull { part ->
            val kv = part.split("=", limit = 2)
            if (kv.size == 2) kv[0] to Uri.decode(kv[1]) else null
        }.toMap()

    // أدوات شبكة
    private fun post(url: String, headers: Map<String, String>, body: String): Pair<Int, String> =
        request(url, "POST", headers, body)

    private fun get(url: String, headers: Map<String, String>): Pair<Int, String> =
        request(url, "GET", headers, null)

    private fun request(urlString: String, method: String, headers: Map<String, String>, body: String?): Pair<Int, String> {
        val conn = URL(urlString).openConnection() as HttpURLConnection
        return try {
            conn.requestMethod = method
            conn.connectTimeout = 30_000
            conn.readTimeout = 30_000
            headers.forEach { (k, v) -> conn.setRequestProperty(k, v) }
            if (body != null) {
                conn.doOutput = true
                conn.outputStream.use { it.write(body.toByteArray(Charsets.UTF_8)) }
            }
            val code = conn.responseCode
            val stream = if (code in 200..299) conn.inputStream else conn.errorStream
            val text = stream?.bufferedReader()?.use { it.readText() } ?: ""
            code to text
        } finally {
            conn.disconnect()
        }
    }

    private fun enc(s: String) = URLEncoder.encode(s, "UTF-8")

    companion object {
        private fun base64Url(bytes: ByteArray): String =
            android.util.Base64.encodeToString(
                bytes,
                android.util.Base64.NO_WRAP or android.util.Base64.NO_PADDING or android.util.Base64.URL_SAFE,
            )

        fun randomUrlSafe(count: Int): String {
            val bytes = ByteArray(count)
            SecureRandom().nextBytes(bytes)
            return base64Url(bytes)
        }

        fun codeChallenge(verifier: String): String {
            val digest = MessageDigest.getInstance("SHA-256").digest(verifier.toByteArray(Charsets.UTF_8))
            return base64Url(digest)
        }
    }
}
