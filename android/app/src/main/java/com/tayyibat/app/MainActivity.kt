package com.tayyibat.app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.lifecycle.lifecycleScope
import com.tayyibat.app.config.AppConfig
import com.tayyibat.app.ui.RootScreen
import com.tayyibat.app.ui.theme.TayyibatTheme
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        handleOAuth(intent)
        setContent {
            TayyibatTheme {
                RootScreen()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleOAuth(intent)
    }

    /** يلتقط إعادة توجيه OAuth (tayyibat://login-callback) ويمرّرها لخدمة المصادقة. */
    private fun handleOAuth(intent: Intent?) {
        val data: Uri = intent?.data ?: return
        if (data.scheme == AppConfig.AUTH_REDIRECT_SCHEME) {
            lifecycleScope.launch { AppGraph.auth.handleOAuthCallback(data) }
        }
    }
}
