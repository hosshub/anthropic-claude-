package com.tayyibat.app.ui.history

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.produceState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.tayyibat.app.AppGraph
import com.tayyibat.app.data.model.MealWithItems
import com.tayyibat.app.service.SummaryService
import com.tayyibat.app.ui.components.CardContainer
import com.tayyibat.app.ui.components.DetailScaffold
import com.tayyibat.app.ui.components.clickableNoRipple
import com.tayyibat.app.ui.components.rememberImageBitmap
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Theme
import com.tayyibat.app.ui.theme.scoreColor
import com.tayyibat.app.ui.theme.scoreLabel
import com.tayyibat.app.util.DateUtils

@Composable
fun DayDetailScreen(dayMillis: Long, onBack: () -> Unit, onMealClick: (String) -> Unit) {
    val meals by produceState<List<MealWithItems>>(initialValue = emptyList(), dayMillis) {
        value = SummaryService.mealsOfDay(dayMillis, AppGraph.db.mealDao())
    }

    DetailScaffold(title = DateUtils.abbreviatedDate(dayMillis), onBack = onBack) { modifier ->
        Column(
            modifier.verticalScroll(rememberScrollState()).padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            if (meals.isEmpty()) {
                Text("لا وجبات في هذا اليوم", style = AppType.bodyText, color = Theme.colors.textSecondary, modifier = Modifier.padding(top = 60.dp))
            } else {
                meals.forEach { mw -> MealRow(mw) { onMealClick(mw.meal.id) } }
            }
        }
    }
}

@Composable
private fun MealRow(mw: MealWithItems, onClick: () -> Unit) {
    val bitmap = rememberImageBitmap(mw.meal.imageData)
    CardContainer(Modifier.clickableNoRipple(onClick)) {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(14.dp), verticalAlignment = Alignment.CenterVertically) {
            if (bitmap != null) {
                Image(
                    bitmap = bitmap, contentDescription = null, contentScale = ContentScale.Crop,
                    modifier = Modifier.size(64.dp).clip(RoundedCornerShape(12.dp)),
                )
            }
            Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(
                    mw.meal.scoreLabelAr.ifEmpty { scoreLabel(mw.meal.overallScore) },
                    style = AppType.cardTitle, color = Theme.colors.textPrimary,
                )
                Text(DateUtils.shortTime(mw.meal.capturedAt), style = AppType.caption, color = Theme.colors.textSecondary)
            }
            Text("${mw.meal.overallScore}%", style = AppType.cardTitle.copy(fontWeight = FontWeight.Bold), color = scoreColor(mw.meal.overallScore))
        }
    }
}
