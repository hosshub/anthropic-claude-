package com.tayyibat.app.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.Cancel
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Lightbulb
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tayyibat.app.data.model.Verdict
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Gold
import com.tayyibat.app.ui.theme.Primary
import com.tayyibat.app.ui.theme.Theme
import com.tayyibat.app.ui.theme.scoreColor

fun verdictIcon(verdict: Verdict): ImageVector = when (verdict) {
    Verdict.TAYYIB -> Icons.Filled.CheckCircle
    Verdict.KHABITH -> Icons.Filled.Cancel
    Verdict.CONDITIONAL -> Icons.Filled.Warning
}

/** زر أساسي بارز بنمط التطبيق. */
@Composable
fun PrimaryButton(
    title: String,
    modifier: Modifier = Modifier,
    icon: ImageVector? = null,
    fill: Color = Primary,
    enabled: Boolean = true,
    onClick: () -> Unit,
) {
    val bg = if (enabled) fill else Color.Gray.copy(alpha = 0.4f)
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(Theme.cornerRadius))
            .background(bg)
            .then(if (enabled) Modifier.clickableNoRipple(onClick) else Modifier)
            .padding(vertical = 16.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (icon != null) {
            Icon(icon, contentDescription = null, tint = Color.White)
            androidx.compose.foundation.layout.Spacer(Modifier.size(8.dp))
        }
        Text(title, style = AppType.cardTitle, color = Color.White)
    }
}

/** زر ثانوي بحدود. */
@Composable
fun SecondaryButton(
    title: String,
    modifier: Modifier = Modifier,
    icon: ImageVector? = null,
    onClick: () -> Unit,
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(Theme.cornerRadius))
            .border(1.5.dp, Primary, RoundedCornerShape(Theme.cornerRadius))
            .clickableNoRipple(onClick)
            .padding(vertical = 15.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (icon != null) {
            Icon(icon, contentDescription = null, tint = Primary)
            androidx.compose.foundation.layout.Spacer(Modifier.size(8.dp))
        }
        Text(title, style = AppType.cardTitle, color = Primary)
    }
}

/** حاوية بطاقة عامة. */
@Composable
fun CardContainer(
    modifier: Modifier = Modifier,
    content: @Composable androidx.compose.foundation.layout.ColumnScope.() -> Unit,
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .shadow(8.dp, RoundedCornerShape(Theme.cornerRadius), spotColor = Theme.cardShadow)
            .clip(RoundedCornerShape(Theme.cornerRadius))
            .background(Theme.colors.surface)
            .padding(16.dp),
        content = content,
    )
}

/** شارة صغيرة تُظهر حكم العنصر (طيب/خبيث/مشروط). */
@Composable
fun VerdictBadge(verdict: Verdict) {
    Row(
        modifier = Modifier
            .clip(CircleShape)
            .background(verdict.color.copy(alpha = 0.12f))
            .padding(horizontal = 10.dp, vertical = 5.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(4.dp),
    ) {
        Icon(verdictIcon(verdict), contentDescription = null, tint = verdict.color, modifier = Modifier.size(16.dp))
        Text(verdict.labelAr, style = AppType.caption.copy(fontWeight = FontWeight.SemiBold), color = verdict.color)
    }
}

/** بطاقة "نصيحة اليوم". */
@Composable
fun TipCard(text: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(Theme.cornerRadius))
            .background(Gold.copy(alpha = 0.10f))
            .padding(16.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Icon(Icons.Filled.Lightbulb, contentDescription = null, tint = Gold)
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text("نصيحة اليوم", style = AppType.caption.copy(fontWeight = FontWeight.SemiBold), color = Theme.colors.textSecondary)
            Text(text, style = AppType.bodyText, color = Theme.colors.textPrimary)
        }
    }
}

/** فوتر التنبيه الطبي المختصر. */
@Composable
fun MedicalDisclaimerFooter() {
    Text(
        "تنبيه: هذا التطبيق لا يقدّم استشارة طبية. النتائج لأغراض التتبّع فقط.",
        style = AppType.caption,
        color = Theme.colors.textSecondary,
        modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
        textAlign = androidx.compose.ui.text.style.TextAlign.Center,
    )
}

/** حلقة دائرية تعرض نسبة الالتزام مع رقم في المنتصف. */
@Composable
fun ScoreRing(
    score: Int,
    modifier: Modifier = Modifier,
    size: androidx.compose.ui.unit.Dp = 180.dp,
    strokeWidth: androidx.compose.ui.unit.Dp = 16.dp,
    showLabel: Boolean = true,
) {
    val fraction = (score.coerceIn(0, 100)) / 100f
    val animated by animateFloatAsState(
        targetValue = fraction,
        animationSpec = spring(dampingRatio = 0.8f, stiffness = 120f),
        label = "scoreRing",
    )
    val color = scoreColor(score)
    Box(modifier = modifier.size(size), contentAlignment = Alignment.Center) {
        Canvas(modifier = Modifier.size(size)) {
            val sw = strokeWidth.toPx()
            val inset = sw / 2
            val arcSize = androidx.compose.ui.geometry.Size(this.size.width - sw, this.size.height - sw)
            val topLeft = androidx.compose.ui.geometry.Offset(inset, inset)
            drawArc(
                color = color.copy(alpha = 0.15f),
                startAngle = 0f, sweepAngle = 360f, useCenter = false,
                topLeft = topLeft, size = arcSize,
                style = Stroke(width = sw),
            )
            drawArc(
                color = color,
                startAngle = -90f, sweepAngle = 360f * animated, useCenter = false,
                topLeft = topLeft, size = arcSize,
                style = Stroke(width = sw, cap = StrokeCap.Round),
            )
        }
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text("$score%", style = AppType.scoreNumber.copy(fontSize = (size.value / 3.2f).sp), color = color)
            if (showLabel) {
                Text("طيب اليوم", style = AppType.caption, color = Theme.colors.textSecondary)
            }
        }
    }
}
