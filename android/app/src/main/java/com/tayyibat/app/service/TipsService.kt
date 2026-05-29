package com.tayyibat.app.service

import android.content.Context
import com.tayyibat.app.R
import com.tayyibat.app.data.db.TipDao
import com.tayyibat.app.data.model.NotificationTip
import com.tayyibat.app.data.model.TipCategory
import com.tayyibat.app.util.DateUtils
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import java.util.UUID

/** يدير بنك النصائح: التحميل، التخزين، والتدوير بدون تكرار. */
object TipsService {
    private const val RECENT_WINDOW = 10
    private val json = Json { ignoreUnknownKeys = true }

    @Serializable
    private data class TipBankFile(
        val version: String = "1.0",
        val tips: List<Entry> = emptyList(),
    ) {
        @Serializable
        data class Entry(val category: String, val text: String)
    }

    /** يحمّل النصائح من JSON إلى قاعدة البيانات إذا لم تكن موجودة بعد. */
    suspend fun seedIfNeeded(context: Context, dao: TipDao) {
        if (dao.count() > 0) return
        val raw = context.resources.openRawResource(R.raw.tips_bank)
            .bufferedReader().use { it.readText() }
        val bank = runCatching { json.decodeFromString(TipBankFile.serializer(), raw) }.getOrNull() ?: return
        val tips = bank.tips.map { entry ->
            NotificationTip(
                id = UUID.randomUUID().toString(),
                categoryRaw = (TipCategory.from(entry.category)).raw,
                textAr = entry.text,
            )
        }
        dao.insertAll(tips)
    }

    /** نصيحة اليوم للرئيسية — ثابتة خلال اليوم وتتغيّر يومياً. */
    suspend fun tipOfTheDay(dao: TipDao): String {
        val pool = dao.all()
            .filter { it.category == TipCategory.MORNING || it.category == TipCategory.GENERAL }
            .sortedBy { it.id }
        if (pool.isEmpty()) return "تذكّر: كُل عند الجوع الحقيقي، واختر من الطيبات."
        val dayIndex = DateUtils.dayOfYear()
        return pool[dayIndex % pool.size].textAr
    }

    /** يختار نصيحة من فئة معيّنة متجنباً آخر النصائح التي ظهرت، ويعلّمها كمعروضة. */
    suspend fun nextTip(category: TipCategory, dao: TipDao): String? {
        val all = dao.all()
        val pool = all.filter { it.category == category }
        if (pool.isEmpty()) return null

        val recentIds = all
            .filter { it.lastShownAt != null }
            .sortedByDescending { it.lastShownAt }
            .take(RECENT_WINDOW)
            .map { it.id }
            .toSet()

        val candidates = pool.filter { it.id !in recentIds }
        val chosen = (candidates.ifEmpty { pool })
            .minByOrNull { it.lastShownAt ?: Long.MIN_VALUE }
            ?: return null

        dao.update(chosen.copy(lastShownAt = DateUtils.now()))
        return chosen.textAr
    }
}
