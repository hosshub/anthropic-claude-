package com.tayyibat.app

import android.app.Application
import android.content.Context
import com.tayyibat.app.data.db.AppDatabase
import com.tayyibat.app.service.AuthService
import com.tayyibat.app.service.ClaudeApiService
import com.tayyibat.app.service.NotificationScheduler
import com.tayyibat.app.service.RulesService

/**
 * نقطة دخول التطبيق — تهيّئ الخدمات المشتركة (قاعدة البيانات، القواعد،
 * المصادقة، عميل Claude) عبر حاوية اعتماديات بسيطة.
 */
class TayyibatApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        RulesService.init(this)
        NotificationScheduler.ensureChannel(this)
        AppGraph.init(this)
    }
}

/** حاوية اعتماديات بسيطة بديلة عن إطار حقن كامل. */
object AppGraph {
    lateinit var db: AppDatabase
        private set
    lateinit var auth: AuthService
        private set
    lateinit var claude: ClaudeApiService
        private set

    fun init(context: Context) {
        if (::db.isInitialized) return
        val app = context.applicationContext
        db = AppDatabase.get(app)
        auth = AuthService(app)
        claude = ClaudeApiService(app)
    }
}
