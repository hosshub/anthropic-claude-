package com.tayyibat.app.ui.result

import android.content.Intent
import androidx.compose.animation.AnimatedVisibility
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
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Lightbulb
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.tayyibat.app.data.model.AnalysisResult
import com.tayyibat.app.data.model.EditableItem
import com.tayyibat.app.service.ScoringHelper
import com.tayyibat.app.ui.components.CardContainer
import com.tayyibat.app.ui.components.MedicalDisclaimerFooter
import com.tayyibat.app.ui.components.PrimaryButton
import com.tayyibat.app.ui.components.ScoreRing
import com.tayyibat.app.ui.components.VerdictBadge
import com.tayyibat.app.ui.components.clickableNoRipple
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Gold
import com.tayyibat.app.ui.theme.Primary
import com.tayyibat.app.ui.theme.Theme
import com.tayyibat.app.ui.theme.scoreColor
import com.tayyibat.app.ui.theme.scoreLabel

@Composable
fun ResultScreen(
    result: AnalysisResult,
    imageData: ByteArray,
    onSave: (List<EditableItem>) -> Unit,
    onRetake: () -> Unit,
) {
    val context = LocalContext.current
    val items = remember { mutableStateListOf<EditableItem>().apply { addAll(result.identifiedItems.map { EditableItem.from(it) }) } }
    var editing by remember { mutableStateOf<EditableItem?>(null) }
    var expandedId by remember { mutableStateOf<String?>(null) }

    val displayScore = if (items.any { it.wasEdited }) ScoringHelper.recompute(items) else result.overallScore

    Box(Modifier.fillMaxSize().background(Theme.colors.background)) {
        Column(
            Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(20.dp).padding(bottom = 90.dp),
            verticalArrangement = Arrangement.spacedBy(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            // ترويسة النتيجة
            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(12.dp)) {
                ScoreRing(score = displayScore, showLabel = false)
                Text(scoreLabel(displayScore), style = AppType.sectionTitle, color = scoreColor(displayScore))
                Text(result.scoreExplanationAr, style = AppType.bodyText, color = Theme.colors.textSecondary, textAlign = TextAlign.Center)
            }

            if (result.warnings.isNotEmpty()) {
                CardContainer {
                    Text("ملاحظات", style = AppType.cardTitle, color = Gold)
                    result.warnings.forEach { w ->
                        Text("• $w", style = AppType.bodyText, color = Theme.colors.textSecondary)
                    }
                }
            }

            // العناصر
            Column(Modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text("العناصر المحدَّدة", style = AppType.sectionTitle, color = Theme.colors.textPrimary)
                items.forEach { item ->
                    ItemRow(
                        item = item,
                        expanded = expandedId == item.id,
                        onToggleExpand = { expandedId = if (expandedId == item.id) null else item.id },
                        onEdit = { editing = item },
                    )
                }
            }

            if (result.improvementSuggestionsAr.isNotEmpty()) {
                CardContainer {
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                        Icon(Icons.Filled.Lightbulb, contentDescription = null, tint = Primary, modifier = Modifier.size(18.dp))
                        Text("اقتراحات للتحسين", style = AppType.cardTitle, color = Primary)
                    }
                    result.improvementSuggestionsAr.forEach { s ->
                        Text("• $s", style = AppType.bodyText, color = Theme.colors.textPrimary, modifier = Modifier.padding(top = 4.dp))
                    }
                }
            }

            MedicalDisclaimerFooter()
        }

        // شريط الإجراءات السفلي
        Row(
            Modifier.fillMaxWidth().align(Alignment.BottomCenter).background(Theme.colors.surface).padding(16.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            CircleAction(Icons.Filled.Share) {
                val names = items.joinToString("، ") { "${it.nameAr} (${it.verdict.labelAr})" }
                val text = "نتيجتي في الطيبات: $displayScore% — ${scoreLabel(displayScore)}.\nالعناصر: $names"
                val intent = Intent(Intent.ACTION_SEND).apply {
                    type = "text/plain"
                    putExtra(Intent.EXTRA_TEXT, text)
                }
                context.startActivity(Intent.createChooser(intent, "مشاركة"))
            }
            PrimaryButton("حفظ في السجل", icon = Icons.Filled.Check, modifier = Modifier.weight(1f)) {
                onSave(items.toList())
            }
        }
    }

    editing?.let { item ->
        EditItemDialog(
            item = item,
            onDismiss = { editing = null },
            onSave = { updated ->
                val index = items.indexOfFirst { it.id == updated.id }
                if (index >= 0) items[index] = updated
                editing = null
            },
        )
    }
}

@Composable
private fun ItemRow(
    item: EditableItem,
    expanded: Boolean,
    onToggleExpand: () -> Unit,
    onEdit: () -> Unit,
) {
    CardContainer {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
            Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                Text(item.nameAr, style = AppType.cardTitle, color = Theme.colors.textPrimary)
                Text("${item.category} • ${item.estimatedPortion}", style = AppType.caption, color = Theme.colors.textSecondary)
            }
            VerdictBadge(item.verdict)
        }
        if (item.isLowConfidence) {
            Text("ثقة منخفضة — يُفضّل المراجعة", style = AppType.caption, color = Gold, modifier = Modifier.padding(top = 6.dp))
        }
        AnimatedVisibility(expanded) {
            Text(item.reasoning, style = AppType.bodyText, color = Theme.colors.textSecondary, modifier = Modifier.padding(top = 6.dp))
        }
        Row(Modifier.padding(top = 8.dp), horizontalArrangement = Arrangement.spacedBy(16.dp)) {
            Text(
                if (expanded) "إخفاء التفسير" else "التفسير",
                style = AppType.caption.copy(fontWeight = FontWeight.SemiBold), color = Primary,
                modifier = Modifier.clickableNoRipple(onToggleExpand),
            )
            Text(
                "تعديل", style = AppType.caption.copy(fontWeight = FontWeight.SemiBold), color = Primary,
                modifier = Modifier.clickableNoRipple(onEdit),
            )
            if (item.wasEdited) {
                Text("مُعدّل", style = AppType.caption, color = Gold)
            }
        }
    }
}

@Composable
private fun CircleAction(icon: androidx.compose.ui.graphics.vector.ImageVector, onClick: () -> Unit) {
    Box(
        Modifier.size(54.dp).clip(CircleShape).background(Theme.colors.background).clickableNoRipple(onClick),
        contentAlignment = Alignment.Center,
    ) {
        Icon(icon, contentDescription = null, tint = Primary)
    }
}
