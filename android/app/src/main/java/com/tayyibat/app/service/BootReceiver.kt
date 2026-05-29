package com.tayyibat.app.service

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.tayyibat.app.data.db.AppDatabase
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/** يعيد جدولة الإشعارات بعد إعادة تشغيل الجهاز (تُمحى الإنذارات عند إعادة التشغيل). */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return
        val pending = goAsync()
        val appContext = context.applicationContext
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val db = AppDatabase.get(appContext)
                val profile = db.profileDao().get()
                if (profile != null && profile.notificationsEnabled) {
                    NotificationScheduler.reschedule(appContext, profile, db)
                }
            } finally {
                pending.finish()
            }
        }
    }
}
