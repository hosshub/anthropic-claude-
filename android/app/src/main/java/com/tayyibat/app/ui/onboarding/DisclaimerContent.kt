package com.tayyibat.app.ui.onboarding

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.ArrowDownward
import androidx.compose.material.icons.filled.Info
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.tayyibat.app.service.RulesService
import com.tayyibat.app.ui.components.MedicalDisclaimerFooter
import com.tayyibat.app.ui.components.PrimaryButton
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Khabith
import com.tayyibat.app.ui.theme.Theme

/** محتوى التنبيه الطبي. يتطلب التمرير للأسفل قبل تفعيل زر الموافقة (إن وُجد). */
@Composable
fun DisclaimerContent(
    showAcceptButton: Boolean,
    onAccept: () -> Unit = {},
) {
    val scroll = rememberScrollState()
    var reachedBottom by remember { mutableStateOf(false) }

    LaunchedEffect(scroll) {
        snapshotFlow { scroll.value to scroll.maxValue }.collect { (value, max) ->
            if (max == 0 || value >= max - 8) reachedBottom = true
        }
    }

    Column(Modifier.fillMaxSize().background(Theme.colors.background)) {
        // الترويسة
        Row(
            Modifier.fillMaxWidth().background(Khabith).padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            Icon(Icons.Filled.Info, contentDescription = null, tint = Color.White)
            Text("تنبيه طبي", style = AppType.screenTitle, color = Color.White)
        }

        Column(
            Modifier.weight(1f).verticalScroll(scroll).padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Text(
                "هذا النظام مثير للجدل ولم تعتمده الهيئات الطبية الرسمية. اقرأ بعناية قبل المتابعة.",
                style = AppType.cardTitle, color = Khabith,
            )
            Text(RulesService.rules.medicalDisclaimer, style = AppType.bodyText, color = Theme.colors.textPrimary)
            Text("ما لا يقدّمه هذا التطبيق:", style = AppType.sectionTitle, color = Theme.colors.textPrimary)
            Bullet("لا يقدّم استشارة طبية أو تشخيصاً.")
            Bullet("لا يدّعي علاج أو شفاء أي مرض.")
            Bullet("لا يتناول موضوع الأدوية إطلاقاً؛ لا توقف دواءً موصوفاً لك.")
            Bullet("هو مجرد أداة لتتبع نظام غذائي اخترته أنت بمحض إرادتك.")
            Text(
                "استشر طبيبك أو أخصائي تغذية قبل اتباع أي نظام غذائي، خاصةً إن كنت تعاني مرضاً مزمناً، أو كنت حاملاً أو مرضعاً، أو كان عمرك أقل من 18 سنة.",
                style = AppType.bodyText, color = Theme.colors.textPrimary,
            )
        }

        if (showAcceptButton) {
            Column(
                Modifier.fillMaxWidth().background(Theme.colors.surface).padding(20.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                if (!reachedBottom) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp),
                    ) {
                        Icon(Icons.Filled.ArrowDownward, contentDescription = null, tint = Theme.colors.textSecondary, modifier = Modifier.size(16.dp))
                        Text("مرّر للأسفل لقراءة التنبيه كاملاً", style = AppType.caption, color = Theme.colors.textSecondary)
                    }
                }
                PrimaryButton(
                    title = "أوافق وأتحمل المسؤولية",
                    icon = Icons.AutoMirrored.Filled.ArrowForward,
                    enabled = reachedBottom,
                    onClick = onAccept,
                )
            }
        }
    }
}

@Composable
private fun Bullet(text: String) {
    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        Box(
            Modifier.padding(top = 7.dp).size(6.dp).background(Theme.colors.textPrimary, CircleShape),
        )
        Text(text, style = AppType.bodyText, color = Theme.colors.textPrimary)
    }
}
