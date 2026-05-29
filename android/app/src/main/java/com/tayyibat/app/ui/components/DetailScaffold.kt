package com.tayyibat.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Theme

/** هيكل شاشة تفصيلية بسيط: شريط علوي بزر رجوع + محتوى. */
@Composable
fun DetailScaffold(
    title: String,
    onBack: () -> Unit,
    content: @Composable (Modifier) -> Unit,
) {
    Column(Modifier.fillMaxSize().background(Theme.colors.background)) {
        Row(
            Modifier.fillMaxWidth().background(Theme.colors.surface).padding(horizontal = 8.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Box(
                Modifier.size(40.dp).clickableNoRipple(onBack),
                contentAlignment = Alignment.Center,
            ) {
                // في RTL، يشير سهم الرجوع تلقائياً لليمين.
                Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "رجوع", tint = Theme.colors.textPrimary)
            }
            Text(title, style = AppType.cardTitle, color = Theme.colors.textPrimary)
        }
        content(Modifier.fillMaxSize())
    }
}
