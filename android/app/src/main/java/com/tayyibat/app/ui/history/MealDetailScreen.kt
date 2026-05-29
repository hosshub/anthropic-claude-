package com.tayyibat.app.ui.history

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Lightbulb
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.produceState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.tayyibat.app.AppGraph
import com.tayyibat.app.data.model.MealWithItems
import com.tayyibat.app.ui.components.CardContainer
import com.tayyibat.app.ui.components.DetailScaffold
import com.tayyibat.app.ui.components.MedicalDisclaimerFooter
import com.tayyibat.app.ui.components.VerdictBadge
import com.tayyibat.app.ui.components.rememberImageBitmap
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Gold
import com.tayyibat.app.ui.theme.Primary
import com.tayyibat.app.ui.theme.Theme
import com.tayyibat.app.ui.theme.scoreColor
import com.tayyibat.app.ui.theme.scoreLabel
import com.tayyibat.app.util.DateUtils

@Composable
fun MealDetailScreen(mealId: String, onBack: () -> Unit) {
    val meal by produceState<MealWithItems?>(initialValue = null, mealId) {
        value = AppGraph.db.mealDao().mealById(mealId)
    }

    DetailScaffold(title = "تفاصيل الوجبة", onBack = onBack) { modifier ->
        val mw = meal ?: return@DetailScaffold
        val bitmap = rememberImageBitmap(mw.meal.imageData)
        Column(
            modifier.verticalScroll(rememberScrollState()).padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            if (bitmap != null) {
                Image(
                    bitmap = bitmap, contentDescription = null, contentScale = ContentScale.Crop,
                    modifier = Modifier.fillMaxWidth().height(240.dp).clip(RoundedCornerShape(Theme.cornerRadius)),
                )
            }
            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Text("${mw.meal.overallScore}%", style = AppType.scoreNumber, color = scoreColor(mw.meal.overallScore))
                Text(
                    mw.meal.scoreLabelAr.ifEmpty { scoreLabel(mw.meal.overallScore) },
                    style = AppType.sectionTitle, color = scoreColor(mw.meal.overallScore),
                )
                Text(DateUtils.abbreviatedDate(mw.meal.capturedAt) + " · " + DateUtils.shortTime(mw.meal.capturedAt), style = AppType.caption, color = Theme.colors.textSecondary)
                if (mw.meal.wasEdited) {
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                        Icon(Icons.Filled.Edit, contentDescription = null, tint = Gold, modifier = Modifier.size(14.dp))
                        Text("عُدّلت يدوياً", style = AppType.caption, color = Gold)
                    }
                }
            }

            if (mw.meal.scoreExplanationAr.isNotEmpty()) {
                Text(mw.meal.scoreExplanationAr, style = AppType.bodyText, color = Theme.colors.textSecondary, textAlign = TextAlign.Center)
            }

            Column(Modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text("العناصر", style = AppType.sectionTitle, color = Theme.colors.textPrimary)
                mw.items.forEach { item ->
                    CardContainer {
                        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                            Text(item.nameAr, style = AppType.cardTitle, color = Theme.colors.textPrimary)
                            VerdictBadge(item.verdict)
                        }
                        Text(item.reasoning, style = AppType.bodyText, color = Theme.colors.textSecondary, modifier = Modifier.padding(top = 6.dp))
                    }
                }
            }

            if (mw.meal.improvementSuggestions.isNotEmpty()) {
                CardContainer {
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                        Icon(Icons.Filled.Lightbulb, contentDescription = null, tint = Primary, modifier = Modifier.size(18.dp))
                        Text("اقتراحات للتحسين", style = AppType.cardTitle, color = Primary)
                    }
                    mw.meal.improvementSuggestions.forEach {
                        Text("• $it", style = AppType.bodyText, color = Theme.colors.textPrimary, modifier = Modifier.padding(top = 4.dp))
                    }
                }
            }

            MedicalDisclaimerFooter()
        }
    }
}
