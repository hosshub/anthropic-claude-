package com.tayyibat.app.service

import com.tayyibat.app.data.model.FastingType
import java.time.DayOfWeek
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.time.chrono.HijrahDate
import java.time.temporal.ChronoField

/**
 * حساب أيام الصيام المستحبة (الإثنين/الخميس + الأيام البيض الهجرية).
 * يعتمد التقويم الهجري على HijrahChronology (أم القرى) في java.time.
 */
object FastingCalculator {

    private fun localDate(epochMillis: Long): LocalDate =
        Instant.ofEpochMilli(epochMillis).atZone(ZoneId.systemDefault()).toLocalDate()

    /** أنواع الصيام المستحبة المقترحة لهذا اليوم (قد تكون فارغة). */
    fun suggestedTypes(date: LocalDate): List<FastingType> {
        val types = mutableListOf<FastingType>()
        when (date.dayOfWeek) {
            DayOfWeek.MONDAY -> types.add(FastingType.MONDAY)
            DayOfWeek.THURSDAY -> types.add(FastingType.THURSDAY)
            else -> {}
        }
        if (hijriDay(date) in listOf(13, 14, 15)) types.add(FastingType.WHITE_DAY)
        return types
    }

    fun suggestedTypes(epochMillis: Long): List<FastingType> = suggestedTypes(localDate(epochMillis))

    fun isRecommendedFastingDay(date: LocalDate): Boolean = suggestedTypes(date).isNotEmpty()

    /** اليوم الهجري (1-30) لتاريخ ميلادي معيّن. */
    fun hijriDay(date: LocalDate): Int {
        val hijri = HijrahDate.from(date)
        return hijri.get(ChronoField.DAY_OF_MONTH)
    }

    data class FastingEntry(val date: LocalDate, val types: List<FastingType>)

    /** أقرب أيام صيام مستحبة ابتداءً من تاريخ معيّن. */
    fun upcomingFastingDays(start: LocalDate = LocalDate.now(), days: Int = 14): List<FastingEntry> {
        val result = mutableListOf<FastingEntry>()
        for (offset in 0 until days) {
            val day = start.plusDays(offset.toLong())
            val types = suggestedTypes(day)
            if (types.isNotEmpty()) result.add(FastingEntry(day, types))
        }
        return result
    }
}
