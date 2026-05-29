package com.tayyibat.app.service

import com.tayyibat.app.data.db.MealDao
import com.tayyibat.app.data.db.SummaryDao
import com.tayyibat.app.data.model.DailySummary
import com.tayyibat.app.data.model.MealWithItems
import com.tayyibat.app.util.DateUtils
import kotlin.math.roundToInt

/** يحدّث الملخصات اليومية اعتماداً على الوجبات المحفوظة. */
object SummaryService {

    /** يعيد حساب ملخص يوم معيّن من وجباته ويحفظه. */
    suspend fun updateSummary(forDayMillis: Long, mealDao: MealDao, summaryDao: SummaryDao): DailySummary {
        val dayStart = DateUtils.startOfDayMillis(forDayMillis)
        val meals = mealsOfDay(forDayMillis, mealDao)
        val average = if (meals.isEmpty()) 0
        else (meals.sumOf { it.meal.overallScore }.toDouble() / meals.size).roundToInt()

        val existing = summaryDao.summaryForDay(dayStart)
        val summary = (existing ?: DailySummary(date = dayStart)).copy(
            averageScore = average,
            mealsCount = meals.size,
        )
        summaryDao.upsert(summary)
        return summary
    }

    suspend fun mealsOfDay(dayMillis: Long, mealDao: MealDao): List<MealWithItems> {
        val start = DateUtils.startOfDayMillis(dayMillis)
        val end = start + 24L * 60 * 60 * 1000
        return mealDao.mealsBetween(start, end)
    }

    suspend fun summaryForDay(dayMillis: Long, summaryDao: SummaryDao): DailySummary? =
        summaryDao.summaryForDay(DateUtils.startOfDayMillis(dayMillis))

    /** يضبط حالة الصيام لليوم في الملخص. */
    suspend fun setFasting(fasted: Boolean, dayMillis: Long, summaryDao: SummaryDao) {
        val dayStart = DateUtils.startOfDayMillis(dayMillis)
        val existing = summaryDao.summaryForDay(dayStart) ?: DailySummary(date = dayStart)
        summaryDao.upsert(existing.copy(fastedToday = fasted))
    }

    /** عدد الأيام المتتالية (Streak) التي تجاوز متوسطها 80% حتى اليوم. */
    suspend fun currentStreak(summaryDao: SummaryDao): Int {
        var streak = 0
        var dayMillis = DateUtils.todayStartMillis()
        while (true) {
            val summary = summaryDao.summaryForDay(DateUtils.startOfDayMillis(dayMillis)) ?: break
            if (summary.averageScore >= 80 && summary.mealsCount > 0) {
                streak += 1
                dayMillis -= 24L * 60 * 60 * 1000
            } else break
        }
        return streak
    }
}
