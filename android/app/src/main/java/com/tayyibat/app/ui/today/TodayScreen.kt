package com.tayyibat.app.ui.today

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CameraAlt
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.tayyibat.app.data.model.MealWithItems
import com.tayyibat.app.data.model.UserProfile
import com.tayyibat.app.ui.components.CardContainer
import com.tayyibat.app.ui.components.MedicalDisclaimerFooter
import com.tayyibat.app.ui.components.PrimaryButton
import com.tayyibat.app.ui.components.ScoreRing
import com.tayyibat.app.ui.components.TipCard
import com.tayyibat.app.ui.components.clickableNoRipple
import com.tayyibat.app.ui.components.rememberImageBitmap
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Gold
import com.tayyibat.app.ui.theme.Primary
import com.tayyibat.app.ui.theme.Theme
import com.tayyibat.app.ui.theme.scoreColor
import com.tayyibat.app.util.DateUtils
import java.time.LocalTime

@Composable
fun TodayScreen(
    profile: UserProfile,
    modifier: Modifier = Modifier,
    onCapture: () -> Unit,
    onMealClick: (String) -> Unit,
    vm: TodayViewModel = viewModel(),
) {
    val meals by vm.todayMeals.collectAsStateWithLifecycle()
    val streak by vm.streak.collectAsStateWithLifecycle()
    val tip by vm.tipOfDay.collectAsStateWithLifecycle()
    val fasted by vm.fastedToday.collectAsStateWithLifecycle()

    val score = vm.todayScore(meals)
    val tayyibCount = meals.count { it.meal.overallScore >= 70 }

    Column(
        modifier
            .fillMaxWidth()
            .background(Theme.colors.background)
            .verticalScroll(rememberScrollState())
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp),
    ) {
        // التحية
        Column {
            Text(greeting(profile.name), style = AppType.screenTitle, color = Theme.colors.textPrimary)
            if (streak > 0) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    Icon(Icons.Filled.LocalFireDepartment, contentDescription = null, tint = Gold, modifier = Modifier.size(16.dp))
                    Text("$streak أيام متتالية فوق ٨٠٪", style = AppType.caption.copy(fontWeight = FontWeight.SemiBold), color = Gold)
                }
            }
        }

        // حلقة النتيجة
        CardContainer {
            Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
                ScoreRing(score = score)
                if (meals.isEmpty()) {
                    Text("لم تسجّل وجبات اليوم بعد", style = AppType.caption, color = Theme.colors.textSecondary)
                }
            }
        }

        PrimaryButton("صوّر وجبتك", icon = Icons.Filled.CameraAlt, onClick = onCapture)

        if (meals.isNotEmpty()) {
            CardContainer {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                    Text("تقدّم اليوم", style = AppType.cardTitle, color = Theme.colors.textPrimary)
                    Text("$tayyibCount/${meals.size} طيبة", style = AppType.caption.copy(fontWeight = FontWeight.SemiBold), color = Primary)
                }
                LinearProgressIndicator(
                    progress = { tayyibCount.toFloat() / meals.size.coerceAtLeast(1) },
                    color = Primary,
                    modifier = Modifier.fillMaxWidth().padding(top = 10.dp),
                )
            }
        }

        // الصيام
        CardContainer {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    Icon(Icons.Filled.DarkMode, contentDescription = null, tint = Gold)
                    Text("هل تصوم اليوم؟", style = AppType.cardTitle, color = Theme.colors.textPrimary)
                }
                Switch(checked = fasted, onCheckedChange = { vm.setFasting(it) })
            }
            if (vm.suggestedFasting.isNotEmpty()) {
                Text(
                    "اليوم ${vm.suggestedFasting.joinToString(" و") { it.labelAr }} — صيام مستحب",
                    style = AppType.caption, color = Theme.colors.textSecondary,
                    modifier = Modifier.padding(top = 8.dp),
                )
            }
        }

        TipCard(text = tip)

        if (meals.isNotEmpty()) {
            Text("سجل اليوم", style = AppType.sectionTitle, color = Theme.colors.textPrimary)
            LazyRow(horizontalArrangement = Arrangement.spacedBy(14.dp)) {
                items(meals, key = { it.meal.id }) { mw ->
                    MealCardSmall(mw, onClick = { onMealClick(mw.meal.id) })
                }
            }
        }

        MedicalDisclaimerFooter()
    }
}

@Composable
private fun MealCardSmall(mw: MealWithItems, onClick: () -> Unit) {
    val bitmap = rememberImageBitmap(mw.meal.imageData)
    Column(
        Modifier.width(150.dp).clickableNoRipple(onClick),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Box {
            if (bitmap != null) {
                Image(
                    bitmap = bitmap, contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.width(150.dp).height(110.dp).clip(RoundedCornerShape(14.dp)),
                )
            } else {
                Box(Modifier.width(150.dp).height(110.dp).clip(RoundedCornerShape(14.dp)).background(Theme.colors.surface))
            }
            Text(
                "${mw.meal.overallScore}%",
                style = AppType.caption.copy(fontWeight = FontWeight.Bold),
                color = androidx.compose.ui.graphics.Color.White,
                modifier = Modifier
                    .padding(8.dp)
                    .clip(RoundedCornerShape(50))
                    .background(scoreColor(mw.meal.overallScore))
                    .padding(horizontal = 8.dp, vertical = 4.dp),
            )
        }
        Text(DateUtils.shortTime(mw.meal.capturedAt), style = AppType.caption, color = Theme.colors.textSecondary)
    }
}

private fun greeting(name: String): String {
    val part = if (LocalTime.now().hour < 12) "صباح الخير" else "مساء الخير"
    return if (name.isEmpty()) part else "$part، $name"
}
