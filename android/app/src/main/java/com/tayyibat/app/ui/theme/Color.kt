package com.tayyibat.app.ui.theme

import androidx.compose.ui.graphics.Color

// لوحة الألوان الثابتة (مطابقة لتطبيق iOS).

// أخضر زمردي عميق — الحالات الإيجابية والطيبات.
val Primary = Color(0xFF0F5132)
// ذهبي رملي دافئ — لمسات ثانوية.
val Gold = Color(0xFFC9A35B)
// أحمر طوبي مكتوم — الخبائث والتحذير.
val Khabith = Color(0xFF9B2C2C)

// ألوان السطح/الخلفية للوضعين الفاتح والليلي.
val BackgroundLight = Color(0xFFFAF7F2)
val BackgroundDark = Color(0xFF14110D)
val SurfaceLight = Color(0xFFFFFFFF)
val SurfaceDark = Color(0xFF1F1B15)
val TextPrimaryLight = Color(0xFF1C1A16)
val TextPrimaryDark = Color(0xFFF5F1E8)
val TextSecondaryLight = Color(0xFF6B6457)
val TextSecondaryDark = Color(0xFFB8B0A0)

private val ScoreGood = Color(0xFF4C9A6A)

/** تدرّج الألوان حسب نسبة الالتزام. */
fun scoreColor(score: Int): Color = when (score) {
    in 90..100 -> Primary
    in 70..89 -> ScoreGood
    in 50..69 -> Gold
    else -> Khabith
}

fun scoreLabel(score: Int): String = when (score) {
    in 90..100 -> "ممتاز، وجبة طيبة"
    in 70..89 -> "جيد مع ملاحظات"
    in 50..69 -> "متوسط — راجع الملاحظات"
    else -> "بعيدة عن نظام الطيبات"
}
