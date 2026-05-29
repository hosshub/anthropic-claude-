package com.tayyibat.app.ui.history

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.tayyibat.app.ui.components.CardContainer
import com.tayyibat.app.ui.components.clickableNoRipple
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Primary
import com.tayyibat.app.ui.theme.Theme
import com.tayyibat.app.ui.theme.scoreColor
import com.tayyibat.app.util.DateUtils
import java.time.LocalDate

/** تقويم شهري؛ كل يوم بنقطة لونية حسب متوسط الالتزام. */
@Composable
fun CalendarMonth(
    month: LocalDate,
    scoresByDay: Map<Long, Int>,
    onSelect: (Long) -> Unit,
) {
    val weekdaySymbols = listOf("أحد", "إثن", "ثلا", "أرب", "خمي", "جمع", "سبت")
    val today = LocalDate.now()

    val firstDay = month.withDayOfMonth(1)
    val daysInMonth = month.lengthOfMonth()
    // DayOfWeek: الإثنين=1 .. الأحد=7. الترويسة تبدأ بالأحد، لذا الأحد=0 فراغات.
    val leading = firstDay.dayOfWeek.value % 7
    val cells = buildList<LocalDate?> {
        repeat(leading) { add(null) }
        for (d in 0 until daysInMonth) add(firstDay.plusDays(d.toLong()))
    }

    CardContainer {
        Text(
            DateUtils.monthTitle(month), style = AppType.cardTitle, color = Theme.colors.textPrimary,
            modifier = Modifier.fillMaxWidth(), textAlign = TextAlign.Center,
        )
        Row(Modifier.fillMaxWidth().padding(top = 12.dp), horizontalArrangement = Arrangement.SpaceEvenly) {
            weekdaySymbols.forEach { Text(it, style = AppType.caption, color = Theme.colors.textSecondary) }
        }
        LazyVerticalGrid(
            columns = GridCells.Fixed(7),
            modifier = Modifier.fillMaxWidth().heightIn(max = 320.dp).padding(top = 8.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            items(cells) { date ->
                if (date == null) {
                    Box(Modifier.height(38.dp))
                } else {
                    val dayStart = DateUtils.startOfDayMillis(date)
                    val score = scoresByDay[dayStart]
                    val isToday = date == today
                    Column(
                        Modifier
                            .height(38.dp)
                            .clip(RoundedCornerShape(8.dp))
                            .background(if (isToday) Primary.copy(alpha = 0.08f) else Color.Transparent)
                            .then(if (score != null) Modifier.clickableNoRipple { onSelect(dayStart) } else Modifier),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center,
                    ) {
                        Text(
                            "${date.dayOfMonth}",
                            style = AppType.caption.copy(fontWeight = if (isToday) FontWeight.Bold else FontWeight.Normal),
                            color = if (isToday) Primary else Theme.colors.textPrimary,
                        )
                        Box(
                            Modifier.size(7.dp).clip(CircleShape)
                                .background(if (score != null) scoreColor(score) else Color.Transparent),
                        )
                    }
                }
            }
        }
    }
}
