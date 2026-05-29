package com.tayyibat.app.service

import android.content.Context
import com.tayyibat.app.data.db.AppDatabase
import com.tayyibat.app.util.DateUtils
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.io.File
import java.time.Instant
import java.time.ZoneOffset
import java.time.format.DateTimeFormatter

/** يصدّر بيانات المتابعة إلى ملف JSON قابل للمشاركة. */
object DataExportService {
    private val json = Json { prettyPrint = true }

    @Serializable
    private data class Export(
        val exportedAt: String,
        val meals: List<MealExport>,
        val summaries: List<SummaryExport>,
    )

    @Serializable
    private data class MealExport(
        val capturedAt: String,
        val overallScore: Int,
        val scoreLabel: String,
        val wasEdited: Boolean,
        val items: List<ItemExport>,
    )

    @Serializable
    private data class ItemExport(
        val nameAr: String,
        val verdict: String,
        val category: String,
        val confidence: Double,
    )

    @Serializable
    private data class SummaryExport(
        val date: String,
        val averageScore: Int,
        val mealsCount: Int,
        val fastedToday: Boolean,
    )

    private fun iso(epochMillis: Long): String =
        DateTimeFormatter.ISO_INSTANT.format(Instant.ofEpochMilli(epochMillis).atOffset(ZoneOffset.UTC).toInstant())

    /** ينشئ ملف JSON في ذاكرة التخزين المؤقتة ويعيده للمشاركة. */
    suspend fun exportFile(context: Context, db: AppDatabase): File? = withContext(Dispatchers.IO) {
        val meals = db.mealDao().allMeals()
        val summaries = db.summaryDao().all()

        val export = Export(
            exportedAt = iso(DateUtils.now()),
            meals = meals.map { mw ->
                MealExport(
                    capturedAt = iso(mw.meal.capturedAt),
                    overallScore = mw.meal.overallScore,
                    scoreLabel = mw.meal.scoreLabelAr,
                    wasEdited = mw.meal.wasEdited,
                    items = mw.items.map {
                        ItemExport(it.nameAr, it.verdictRaw, it.category, it.confidence)
                    },
                )
            },
            summaries = summaries.map {
                SummaryExport(iso(it.date), it.averageScore, it.mealsCount, it.fastedToday)
            },
        )

        runCatching {
            val file = File(context.cacheDir, "tayyibat_export.json")
            file.writeText(json.encodeToString(export))
            file
        }.getOrNull()
    }

    /** يحذف كل بيانات المتابعة (الوجبات والملخصات وأيام الصيام). */
    suspend fun deleteAllTrackingData(db: AppDatabase) = withContext(Dispatchers.IO) {
        db.mealDao().deleteAllItems()
        db.mealDao().deleteAllMeals()
        db.summaryDao().deleteAll()
        db.fastingDao().deleteAll()
    }
}
