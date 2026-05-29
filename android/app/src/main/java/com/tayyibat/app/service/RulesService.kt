package com.tayyibat.app.service

import android.content.Context
import com.tayyibat.app.R
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

/** نموذج بيانات ملف القواعد المرفق. */
@Serializable
data class RulesData(
    val version: String = "1.0",
    @SerialName("system_name") val systemName: String = "",
    val categories: List<Category> = emptyList(),
    @SerialName("behavioral_rules") val behavioralRules: List<String> = emptyList(),
    val fasting: Fasting = Fasting(),
    @SerialName("medical_disclaimer") val medicalDisclaimer: String = "",
) {
    @Serializable
    data class Category(
        val id: String,
        @SerialName("name_ar") val nameAr: String,
        val icon: String = "",
        val note: String? = null,
        val allowed: List<String> = emptyList(),
        val forbidden: List<String> = emptyList(),
    )

    @Serializable
    data class Fasting(
        val weekly: List<String> = emptyList(),
        @SerialName("white_days_hijri") val whiteDaysHijri: List<Int> = emptyList(),
        val notes: String = "",
    )
}

/** يحمّل ملف القواعد ويوفّره للواجهات وللـ prompt. */
object RulesService {
    private val json = Json { ignoreUnknownKeys = true }

    lateinit var rawJson: String
        private set
    lateinit var rules: RulesData
        private set

    fun init(context: Context) {
        if (::rules.isInitialized) return
        rawJson = context.resources.openRawResource(R.raw.tayyibat_rules)
            .bufferedReader().use { it.readText() }
        rules = json.decodeFromString(RulesData.serializer(), rawJson)
    }

    data class LookupResult(val category: RulesData.Category, val term: String, val allowed: Boolean)

    /** بحث بسيط: هل هذا الطعام مسموح؟ يرجع الفئة والحكم إن وُجد. */
    fun lookup(query: String): List<LookupResult> {
        val q = query.trim()
        if (q.isEmpty()) return emptyList()
        val results = mutableListOf<LookupResult>()
        for (category in rules.categories) {
            for (term in category.allowed) if (term.contains(q)) results.add(LookupResult(category, term, true))
            for (term in category.forbidden) if (term.contains(q)) results.add(LookupResult(category, term, false))
        }
        return results
    }
}
