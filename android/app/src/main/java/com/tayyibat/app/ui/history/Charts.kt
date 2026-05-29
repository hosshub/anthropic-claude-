package com.tayyibat.app.ui.history

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.tayyibat.app.ui.components.CardContainer
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Primary
import com.tayyibat.app.ui.theme.Theme
import com.tayyibat.app.ui.theme.scoreColor

data class DayScore(val dayMillis: Long, val score: Int)

/** رسم بياني لمتوسط الالتزام عبر فترة (أعمدة أو خط/مساحة). */
@Composable
fun AdherenceChart(title: String, data: List<DayScore>, useBars: Boolean) {
    val scored = data.filter { it.score > 0 }
    val average = if (scored.isEmpty()) 0 else scored.sumOf { it.score } / scored.size

    CardContainer {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
            Text(title, style = AppType.cardTitle, color = Theme.colors.textPrimary)
            Text("المتوسط $average%", style = AppType.caption.copy(fontWeight = FontWeight.SemiBold), color = Primary)
        }
        Canvas(Modifier.fillMaxWidth().height(160.dp).padding(top = 12.dp)) {
            if (data.isEmpty()) return@Canvas
            val w = size.width
            val h = size.height
            // المحور الأفقي يبدأ من اليمين (RTL): أحدث يوم على اليسار، أقدم على اليمين.
            if (useBars) {
                val slot = w / data.size
                val barWidth = slot * 0.6f
                data.forEachIndexed { index, point ->
                    val x = w - (index + 1) * slot + (slot - barWidth) / 2
                    val barHeight = h * (point.score / 100f)
                    drawRoundRect(
                        color = scoreColor(point.score),
                        topLeft = Offset(x, h - barHeight),
                        size = androidx.compose.ui.geometry.Size(barWidth, barHeight),
                        cornerRadius = androidx.compose.ui.geometry.CornerRadius(4f, 4f),
                    )
                }
            } else {
                val step = if (data.size > 1) w / (data.size - 1) else 0f
                fun pointAt(index: Int): Offset {
                    val x = w - index * step
                    val y = h - h * (data[index].score / 100f)
                    return Offset(x, y)
                }
                val linePath = Path()
                val areaPath = Path()
                data.indices.forEach { i ->
                    val p = pointAt(i)
                    if (i == 0) {
                        linePath.moveTo(p.x, p.y)
                        areaPath.moveTo(p.x, h)
                        areaPath.lineTo(p.x, p.y)
                    } else {
                        linePath.lineTo(p.x, p.y)
                        areaPath.lineTo(p.x, p.y)
                    }
                }
                if (data.isNotEmpty()) {
                    areaPath.lineTo(pointAt(data.lastIndex).x, h)
                    areaPath.close()
                }
                drawPath(areaPath, color = Primary.copy(alpha = 0.12f))
                drawPath(linePath, color = Primary, style = Stroke(width = 4f))
            }
        }
    }
}
