package com.tayyibat.app.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

/** أنماط الخطوط — النظام يستخدم تلقائياً خط النظام للعربية. */
object AppType {
    val displayTitle = TextStyle(fontSize = 32.sp, fontWeight = FontWeight.Bold)
    val screenTitle = TextStyle(fontSize = 24.sp, fontWeight = FontWeight.Bold)
    val sectionTitle = TextStyle(fontSize = 19.sp, fontWeight = FontWeight.SemiBold)
    val cardTitle = TextStyle(fontSize = 17.sp, fontWeight = FontWeight.SemiBold)
    val bodyText = TextStyle(fontSize = 16.sp, fontWeight = FontWeight.Normal, lineHeight = 24.sp)
    val caption = TextStyle(fontSize = 13.sp, fontWeight = FontWeight.Normal)
    val scoreNumber = TextStyle(fontSize = 56.sp, fontWeight = FontWeight.Black)
}

val TayyibatTypography = Typography(
    titleLarge = AppType.screenTitle,
    titleMedium = AppType.sectionTitle,
    bodyLarge = AppType.bodyText,
    bodyMedium = AppType.bodyText,
    labelSmall = AppType.caption,
)
