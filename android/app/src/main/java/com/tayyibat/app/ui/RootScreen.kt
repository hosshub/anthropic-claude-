package com.tayyibat.app.ui

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.tayyibat.app.config.AppConfig
import com.tayyibat.app.ui.auth.AuthScreen
import com.tayyibat.app.ui.navigation.AppNavHost
import com.tayyibat.app.ui.onboarding.OnboardingFlow

/** نقطة التفرّع بين: استعادة الجلسة، شاشة الدخول، الإعداد الأولي، أو الواجهة الرئيسية. */
@Composable
fun RootScreen(vm: RootViewModel = viewModel()) {
    val profile by vm.profile.collectAsStateWithLifecycle()
    val authState by vm.authState.collectAsStateWithLifecycle()
    val didAttemptRestore by vm.didAttemptRestore.collectAsStateWithLifecycle()

    when {
        AppConfig.authEnabled && !authState.isAuthenticated && !didAttemptRestore -> {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator()
            }
        }
        AppConfig.authEnabled && !authState.isAuthenticated -> {
            AuthScreen(auth = vm.auth)
        }
        profile?.disclaimerAcceptedAt != null -> {
            AppNavHost(profile = profile!!)
        }
        else -> {
            OnboardingFlow(
                onComplete = { name, age, goal, notif, hours ->
                    vm.completeOnboarding(name, age, goal, notif, hours)
                },
            )
        }
    }
}
