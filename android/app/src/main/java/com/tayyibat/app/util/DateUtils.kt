package com.tayyibat.app.util

import java.time.Instant
import java.time.LocalDate
import java.time.LocalTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale

/** أدوات تواريخ مشتركة — كل التواريخ تُخزَّن كـ epochMillis في المنطقة المحلية. */
object DateUtils {
    private val zone: ZoneId get() = ZoneId.systemDefault()
    private val ar = Locale("ar")

    fun now(): Long = System.currentTimeMillis()

    fun localDate(epochMillis: Long): LocalDate =
        Instant.ofEpochMilli(epochMillis).atZone(zone).toLocalDate()

    fun startOfDayMillis(epochMillis: Long): Long =
        localDate(epochMillis).atStartOfDay(zone).toInstant().toEpochMilli()

    fun startOfDayMillis(date: LocalDate): Long =
        date.atStartOfDay(zone).toInstant().toEpochMilli()

    fun todayStartMillis(): Long = LocalDate.now(zone).atStartOfDay(zone).toInstant().toEpochMilli()

    fun startOfTomorrowMillis(): Long =
        LocalDate.now(zone).plusDays(1).atStartOfDay(zone).toInstant().toEpochMilli()

    fun hourOf(epochMillis: Long): Int =
        Instant.ofEpochMilli(epochMillis).atZone(zone).hour

    fun isToday(epochMillis: Long): Boolean = localDate(epochMillis) == LocalDate.now(zone)

    /** ترتيب اليوم في السنة (1-366) — لاختيار نصيحة اليوم بثبات. */
    fun dayOfYear(): Int = LocalDate.now(zone).dayOfYear

    /** الوقت المختصر، مثل 3:45 م. */
    fun shortTime(epochMillis: Long): String {
        val t = Instant.ofEpochMilli(epochMillis).atZone(zone).toLocalTime()
        return t.format(DateTimeFormatter.ofPattern("h:mm a", ar))
    }

    fun abbreviatedDate(epochMillis: Long): String {
        val d = localDate(epochMillis)
        return d.format(DateTimeFormatter.ofPattern("d MMM yyyy", ar))
    }

    fun abbreviatedDate(date: LocalDate): String =
        date.format(DateTimeFormatter.ofPattern("d MMM yyyy", ar))

    fun monthTitle(date: LocalDate): String =
        date.format(DateTimeFormatter.ofPattern("MMMM yyyy", ar))

    /** epochMillis لتاريخ معيّن بساعة محددة من اليوم. */
    fun atHour(date: LocalDate, hour: Int): Long =
        date.atTime(LocalTime.of(hour, 0)).atZone(zone).toInstant().toEpochMilli()
}
