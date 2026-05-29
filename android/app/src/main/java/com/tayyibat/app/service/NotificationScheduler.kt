package com.tayyibat.app.service

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import com.tayyibat.app.data.db.AppDatabase
import com.tayyibat.app.data.model.NotificationIntensity
import com.tayyibat.app.data.model.TipCategory
import com.tayyibat.app.data.model.UserProfile
import com.tayyibat.app.util.DateUtils
import java.time.LocalDate

/**
 * يدير قناة وجدولة الإشعارات المحلية (تذكيرات + نصائح + صيام + سجل) عبر AlarmManager.
 * مكافئ لـ NotificationService في تطبيق iOS.
 */
object NotificationScheduler {
    const val CHANNEL_ID = "tayyibat_reminders"
    const val EXTRA_TITLE = "extra_title"
    const val EXTRA_BODY = "extra_body"
    const val EXTRA_NOTIF_ID = "extra_notif_id"

    private const val SCHEDULED_PREFS = "tayyibat_scheduled_alarms"
    private const val KEY_IDS = "ids"

    fun ensureChannel(context: Context) {
        val manager = context.getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            CHANNEL_ID,
            "تذكيرات الطيبات",
            NotificationManager.IMPORTANCE_DEFAULT,
        ).apply { description = "تذكيرات الوجبات والنصائح والصيام" }
        manager.createNotificationChannel(channel)
    }

    /** يلغي كل الإشعارات المعلّقة ويعيد جدولتها وفق تفضيلات المستخدم. */
    suspend fun reschedule(context: Context, profile: UserProfile, db: AppDatabase) {
        ensureChannel(context)
        cancelAll(context)
        if (!profile.notificationsEnabled) return

        if (profile.mealRemindersEnabled) scheduleMealReminders(context, profile)
        if (profile.tipsEnabled) scheduleTips(context, profile, db)
        if (profile.fastingRemindersEnabled) scheduleFastingReminders(context, profile)
        if (profile.logRemindersEnabled) scheduleLogReminder(context, profile)
    }

    // تذكيرات الوجبات (تذكير مرن يومي متكرر)
    private fun scheduleMealReminders(context: Context, profile: UserProfile) {
        for (hour in profile.reminderHours) {
            if (isInQuietHours(hour, profile)) continue
            scheduleDailyRepeating(
                context,
                id = "meal_$hour",
                hour = hour,
                title = "الطيبات",
                body = "هل تشعر بجوع حقيقي الآن؟ إن كان كذلك، تذكّر أن تختار من الطيبات 🍽️",
            )
        }
    }

    // النصائح (متناوبة على مدى الأيام القادمة)
    private suspend fun scheduleTips(context: Context, profile: UserProfile, db: AppDatabase) {
        val slots = tipSlots(profile.dailyTipsIntensity)
        val today = LocalDate.now()
        for (dayOffset in 0 until 7) {
            val day = today.plusDays(dayOffset.toLong())
            slots.forEachIndexed { index, slot ->
                if (isInQuietHours(slot.hour, profile)) return@forEachIndexed
                val fireAt = DateUtils.atHour(day, slot.hour)
                if (fireAt <= DateUtils.now()) return@forEachIndexed
                val tip = TipsService.nextTip(slot.category, db.tipDao()) ?: return@forEachIndexed
                scheduleOneShot(context, "tip_${dayOffset}_$index", fireAt, "نصيحة الطيبات", tip)
            }
        }
    }

    private data class Slot(val hour: Int, val category: TipCategory)

    private fun tipSlots(intensity: NotificationIntensity): List<Slot> = when (intensity) {
        NotificationIntensity.LOW -> listOf(Slot(9, TipCategory.MORNING))
        NotificationIntensity.MEDIUM -> listOf(
            Slot(9, TipCategory.MORNING),
            Slot(14, TipCategory.AFTERNOON),
            Slot(19, TipCategory.EVENING),
        )
        NotificationIntensity.HIGH -> listOf(
            Slot(8, TipCategory.MORNING),
            Slot(11, TipCategory.MORNING),
            Slot(14, TipCategory.AFTERNOON),
            Slot(17, TipCategory.EVENING),
            Slot(20, TipCategory.EVENING),
        )
    }

    // تذكيرات الصيام (ليلة ما قبل يوم الصيام)
    private fun scheduleFastingReminders(context: Context, profile: UserProfile) {
        val upcoming = FastingCalculator.upcomingFastingDays(days = 14)
        upcoming.forEachIndexed { index, entry ->
            val eveningBefore = entry.date.minusDays(1)
            val fireAt = DateUtils.atHour(eveningBefore, 20)
            if (fireAt <= DateUtils.now()) return@forEachIndexed
            val names = entry.types.joinToString(" و") { it.labelAr }
            scheduleOneShot(context, "fast_$index", fireAt, "تذكير الصيام", "غداً $names — هل تنوي الصيام؟ 🌙")
        }
    }

    // تذكير مراجعة اليوم (نهاية اليوم)
    private fun scheduleLogReminder(context: Context, profile: UserProfile) {
        if (isInQuietHours(21, profile)) return
        scheduleDailyRepeating(
            context,
            id = "log_review",
            hour = 21,
            title = "ملخص يومك",
            body = "كيف كان يومك مع الطيبات؟ راجع ملخصك وسجّل ما فاتك 📝",
        )
    }

    // أساسيات الجدولة
    private fun scheduleDailyRepeating(context: Context, id: String, hour: Int, title: String, body: String) {
        val alarm = context.getSystemService(AlarmManager::class.java)
        var first = DateUtils.atHour(LocalDate.now(), hour)
        if (first <= DateUtils.now()) first += AlarmManager.INTERVAL_DAY
        val pi = pendingIntent(context, id, title, body)
        alarm.setInexactRepeating(AlarmManager.RTC_WAKEUP, first, AlarmManager.INTERVAL_DAY, pi)
        remember(context, id)
    }

    private fun scheduleOneShot(context: Context, id: String, fireAt: Long, title: String, body: String) {
        val alarm = context.getSystemService(AlarmManager::class.java)
        val pi = pendingIntent(context, id, title, body)
        alarm.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, fireAt, pi)
        remember(context, id)
    }

    private fun pendingIntent(context: Context, id: String, title: String, body: String): PendingIntent {
        val intent = Intent(context, NotificationReceiver::class.java).apply {
            action = "com.tayyibat.app.NOTIFY.$id"
            putExtra(EXTRA_TITLE, title)
            putExtra(EXTRA_BODY, body)
            putExtra(EXTRA_NOTIF_ID, id.hashCode())
        }
        return PendingIntent.getBroadcast(
            context,
            id.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun cancelAll(context: Context) {
        val alarm = context.getSystemService(AlarmManager::class.java)
        val prefs = context.getSharedPreferences(SCHEDULED_PREFS, Context.MODE_PRIVATE)
        val ids = prefs.getStringSet(KEY_IDS, emptySet()) ?: emptySet()
        for (id in ids) {
            val intent = Intent(context, NotificationReceiver::class.java).apply {
                action = "com.tayyibat.app.NOTIFY.$id"
            }
            val pi = PendingIntent.getBroadcast(
                context, id.hashCode(), intent,
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE,
            )
            if (pi != null) alarm.cancel(pi)
        }
        prefs.edit().putStringSet(KEY_IDS, emptySet()).apply()
    }

    private fun remember(context: Context, id: String) {
        val prefs = context.getSharedPreferences(SCHEDULED_PREFS, Context.MODE_PRIVATE)
        val ids = HashSet(prefs.getStringSet(KEY_IDS, emptySet()) ?: emptySet())
        ids.add(id)
        prefs.edit().putStringSet(KEY_IDS, ids).apply()
    }

    /** هل الساعة تقع ضمن فترة "لا تزعج"؟ يدعم الالتفاف عبر منتصف الليل. */
    fun isInQuietHours(hour: Int, profile: UserProfile): Boolean {
        val start = profile.quietHoursStart
        val end = profile.quietHoursEnd
        if (start == end) return false
        return if (start < end) hour in start until end else hour >= start || hour < end
    }
}
