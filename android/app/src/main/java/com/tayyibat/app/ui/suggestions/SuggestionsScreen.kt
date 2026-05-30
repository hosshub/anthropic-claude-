package com.tayyibat.app.ui.suggestions

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Restaurant
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.tayyibat.app.data.model.MealSuggestion
import com.tayyibat.app.data.model.WeeklyPlan
import com.tayyibat.app.ui.components.CardContainer
import com.tayyibat.app.ui.components.DetailScaffold
import com.tayyibat.app.ui.components.MedicalDisclaimerFooter
import com.tayyibat.app.ui.components.PrimaryButton
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Gold
import com.tayyibat.app.ui.theme.Khabith
import com.tayyibat.app.ui.theme.Primary
import com.tayyibat.app.ui.theme.Theme

@Composable
fun SuggestionsScreen(
    onBack: () -> Unit,
    vm: SuggestionsViewModel = viewModel(),
) {
    val state by vm.state.collectAsStateWithLifecycle()

    DetailScaffold("اقتراحات ذكية", onBack) { modifier ->
        Column(
            modifier.verticalScroll(rememberScrollState()).padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp),
        ) {
            // اقتراح وجبة
            CardContainer {
                SectionHeader(Icons.Filled.Restaurant, "اقترح وجبة طيبة")
                Text(
                    "دع الذكاء الاصطناعي يقترح لك وجبة من الطيبات وفق قواعد النظام.",
                    style = AppType.bodyText, color = Theme.colors.textSecondary,
                    modifier = Modifier.padding(top = 4.dp),
                )
                PrimaryButton(
                    "اقترح وجبة",
                    icon = Icons.Filled.AutoAwesome,
                    enabled = !state.mealLoading,
                    modifier = Modifier.padding(top = 12.dp),
                ) { vm.suggestMeal() }

                if (state.mealLoading) {
                    LoadingRow("نجهّز اقتراحاً طيباً…")
                }
                state.mealError?.let {
                    Text(it, style = AppType.bodyText, color = Khabith, modifier = Modifier.padding(top = 10.dp))
                }
                state.meal?.let { MealSuggestionCard(it) }
            }

            // خطة أسبوعية
            CardContainer {
                SectionHeader(Icons.Filled.CalendarMonth, "خطة الأسبوع")
                Text(
                    "خطة وجبات لسبعة أيام من الطيبات، مع مراعاة الصيام المستحب.",
                    style = AppType.bodyText, color = Theme.colors.textSecondary,
                    modifier = Modifier.padding(top = 4.dp),
                )
                PrimaryButton(
                    "ولّد خطة الأسبوع",
                    icon = Icons.Filled.CalendarMonth,
                    enabled = !state.planLoading,
                    modifier = Modifier.padding(top = 12.dp),
                ) { vm.generatePlan() }

                if (state.planLoading) {
                    LoadingRow("نُعدّ خطة أسبوعك…")
                }
                state.planError?.let {
                    Text(it, style = AppType.bodyText, color = Khabith, modifier = Modifier.padding(top = 10.dp))
                }
            }

            state.plan?.let { WeeklyPlanView(it) }

            MedicalDisclaimerFooter()
        }
    }
}

@Composable
private fun SectionHeader(icon: androidx.compose.ui.graphics.vector.ImageVector, title: String) {
    androidx.compose.foundation.layout.Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Icon(icon, contentDescription = null, tint = Primary, modifier = Modifier.size(20.dp))
        Text(title, style = AppType.cardTitle, color = Theme.colors.textPrimary)
    }
}

@Composable
private fun LoadingRow(text: String) {
    androidx.compose.foundation.layout.Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(10.dp),
        modifier = Modifier.padding(top = 12.dp),
    ) {
        CircularProgressIndicator(modifier = Modifier.size(20.dp), color = Primary, strokeWidth = 2.dp)
        Text(text, style = AppType.caption, color = Theme.colors.textSecondary)
    }
}

@Composable
private fun MealSuggestionCard(meal: MealSuggestion) {
    Column(Modifier.fillMaxWidth().padding(top = 12.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
        Text(meal.nameAr, style = AppType.sectionTitle, color = Primary)
        if (meal.bestTimeAr.isNotEmpty()) {
            Text(meal.bestTimeAr, style = AppType.caption, color = Gold)
        }
        meal.componentsAr.forEach { c ->
            Text("• $c", style = AppType.bodyText, color = Theme.colors.textPrimary)
        }
        if (meal.reasoningAr.isNotEmpty()) {
            Text(meal.reasoningAr, style = AppType.bodyText, color = Theme.colors.textSecondary, modifier = Modifier.padding(top = 4.dp))
        }
    }
}

@Composable
private fun WeeklyPlanView(plan: WeeklyPlan) {
    Column(Modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        if (plan.introAr.isNotEmpty()) {
            Text(plan.introAr, style = AppType.bodyText, color = Theme.colors.textSecondary)
        }
        plan.days.forEach { day ->
            CardContainer {
                Text(day.dayAr, style = AppType.cardTitle.copy(fontWeight = FontWeight.Bold), color = Primary)
                day.mealsAr.forEach { m ->
                    Text("• $m", style = AppType.bodyText, color = Theme.colors.textPrimary, modifier = Modifier.padding(top = 4.dp))
                }
                if (day.noteAr.isNotEmpty()) {
                    Text(day.noteAr, style = AppType.caption, color = Gold, modifier = Modifier.padding(top = 6.dp))
                }
            }
        }
    }
}
