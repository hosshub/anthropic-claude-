package com.tayyibat.app.ui.capture

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.tayyibat.app.ui.components.PrimaryButton
import com.tayyibat.app.ui.components.SecondaryButton
import com.tayyibat.app.ui.components.clickableNoRipple
import com.tayyibat.app.ui.components.rememberImageBitmap
import com.tayyibat.app.ui.result.ResultScreen
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Khabith
import com.tayyibat.app.ui.theme.Primary
import com.tayyibat.app.ui.theme.Theme

@Composable
fun CaptureScreen(
    onDone: () -> Unit,
    vm: CaptureViewModel = viewModel(),
) {
    val step by vm.step.collectAsStateWithLifecycle()

    when (val s = step) {
        is CaptureStep.Camera -> CameraCapture(
            onCapture = { vm.beginAnalysis(it) },
            onCancel = onDone,
        )
        is CaptureStep.Analyzing -> AnalyzingView(s.image)
        is CaptureStep.Result -> ResultScreen(
            result = s.result,
            imageData = s.image,
            onSave = { items -> vm.save(s.result, items, s.image, onDone) },
            onRetake = { vm.reset() },
        )
        is CaptureStep.Error -> ErrorView(
            message = s.message,
            onRetry = { vm.beginAnalysis(s.image) },
            onRetake = { vm.reset() },
            onCancel = onDone,
        )
    }
}

@Composable
private fun AnalyzingView(image: ByteArray) {
    val bitmap = rememberImageBitmap(image)
    Column(
        Modifier.fillMaxSize().background(Theme.colors.background),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        if (bitmap != null) {
            Image(
                bitmap = bitmap, contentDescription = null, contentScale = ContentScale.Crop,
                modifier = Modifier.size(220.dp).clip(RoundedCornerShape(24.dp)),
            )
        } else {
            Box(Modifier.size(220.dp).clip(RoundedCornerShape(24.dp)).background(Theme.colors.surface))
        }
        Box(Modifier.size(28.dp))
        CircularProgressIndicator(color = Primary)
        Box(Modifier.size(8.dp))
        Text("نحلّل وجبتك الآن…", style = AppType.sectionTitle, color = Theme.colors.textPrimary)
        Text("نتعرّف على العناصر ونحسب نسبة الالتزام", style = AppType.caption, color = Theme.colors.textSecondary)
    }
}

@Composable
private fun ErrorView(message: String, onRetry: () -> Unit, onRetake: () -> Unit, onCancel: () -> Unit) {
    Column(
        Modifier.fillMaxSize().background(Theme.colors.background).padding(20.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Icon(Icons.Filled.Warning, contentDescription = null, tint = Khabith, modifier = Modifier.size(50.dp))
        Box(Modifier.size(16.dp))
        Text("تعذّر تحليل الوجبة", style = AppType.sectionTitle, color = Theme.colors.textPrimary)
        Text(message, style = AppType.bodyText, color = Theme.colors.textSecondary, textAlign = TextAlign.Center, modifier = Modifier.padding(16.dp))
        Box(Modifier.size(16.dp))
        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            PrimaryButton("إعادة المحاولة", icon = Icons.Filled.Refresh, onClick = onRetry)
            SecondaryButton("إعادة التقاط", onClick = onRetake)
            Text(
                "إلغاء", style = AppType.bodyText, color = Theme.colors.textSecondary,
                modifier = Modifier.clickableNoRipple(onCancel).padding(8.dp),
            )
        }
    }
}
