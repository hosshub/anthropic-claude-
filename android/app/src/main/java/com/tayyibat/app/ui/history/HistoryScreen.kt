package com.tayyibat.app.ui.history

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.tayyibat.app.data.model.Verdict
import com.tayyibat.app.ui.components.CardContainer
import com.tayyibat.app.ui.components.MedicalDisclaimerFooter
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Gold
import com.tayyibat.app.ui.theme.Khabith
import com.tayyibat.app.ui.theme.Primary
import com.tayyibat.app.ui.theme.Theme
import com.tayyibat.app.util.DateUtils
import java.time.LocalDate

@Composable
fun HistoryScreen(
    modifier: Modifier = Modifier,
    onDayClick: (Long) -> Unit,
    vm: HistoryViewModel = viewModel(),
) {
    val meals by vm.meals.collectAsStateWithLifecycle()
    val summaries by vm.summaries.collectAsStateWithLifecycle()

    val scoresByDay = summaries.filter { it.mealsCount > 0 }.associate { it.date to it.averageScore }

    fun dayScores(daysBack: Int): List<DayScore> {
        val today = LocalDate.now()
        return (daysBack - 1 downTo 0).map { offset ->
            val day = today.minusDays(offset.toLong())
            val millis = DateUtils.startOfDayMillis(day)
            DayScore(millis, scoresByDay[millis] ?: 0)
        }
    }

    Column(
        modifier
            .fillMaxSize()
            .background(Theme.colors.background)
            .verticalScroll(rememberScrollState())
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp),
    ) {
        if (meals.isEmpty()) {
            Text("لا سجلّات بعد", style = AppType.sectionTitle, color = Theme.colors.textPrimary, modifier = Modifier.padding(top = 80.dp))
            Text("صوّر أول وجبة لتبدأ المتابعة", style = AppType.bodyText, color = Theme.colors.textSecondary)
        } else {
            AdherenceChart("آخر ٧ أيام", dayScores(7), useBars = true)
            AdherenceChart("آخر ٣٠ يوماً", dayScores(30), useBars = false)
            CalendarMonth(month = LocalDate.now(), scoresByDay = scoresByDay, onSelect = onDayClick)

            // الإحصائيات
            CardContainer {
                Text("إحصائيات", style = AppType.sectionTitle, color = Theme.colors.textPrimary)
                StatRow("أكثر طعام طيّب", topFood(meals, Verdict.TAYYIB) ?: "—", Primary)
                StatRow("أكثر طعام خبيث", topFood(meals, Verdict.KHABITH) ?: "—", Khabith)
                StatRow("أيام صيام مكتملة", "${summaries.count { it.fastedToday }}", Gold)
                StatRow("إجمالي الوجبات", "${meals.size}", Theme.colors.textPrimary)
            }

            MedicalDisclaimerFooter()
        }
    }
}

@Composable
private fun StatRow(title: String, value: String, color: Color) {
    Row(Modifier.fillMaxWidth().padding(top = 12.dp), horizontalArrangement = Arrangement.SpaceBetween) {
        Text(title, style = AppType.bodyText, color = Theme.colors.textSecondary)
        Text(value, style = AppType.cardTitle, color = color)
    }
}

private fun topFood(meals: List<com.tayyibat.app.data.model.MealWithItems>, verdict: Verdict): String? {
    val names = meals.flatMap { it.items }.filter { it.verdict == verdict }.map { it.nameAr }
    val counts = names.groupingBy { it }.eachCount()
    return counts.entries
        .sortedWith(compareByDescending<Map.Entry<String, Int>> { it.value }.thenBy { it.key })
        .firstOrNull()?.key
}
