package com.tayyibat.app.ui.settings

import androidx.compose.runtime.Composable
import com.tayyibat.app.ui.components.DetailScaffold
import com.tayyibat.app.ui.onboarding.DisclaimerContent

/** عرض التنبيه الطبي للقراءة فقط (من الإعدادات). */
@Composable
fun DisclaimerScreen(onBack: () -> Unit) {
    DetailScaffold("تنبيه طبي", onBack) {
        DisclaimerContent(showAcceptButton = false)
    }
}
