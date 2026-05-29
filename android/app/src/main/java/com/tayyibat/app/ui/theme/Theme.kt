package com.tayyibat.app.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.LayoutDirection

/** ألوان السطح المعتمدة على وضع الجهاز (فاتح/ليلي). */
data class ThemeColors(
    val background: Color,
    val surface: Color,
    val textPrimary: Color,
    val textSecondary: Color,
)

val LocalThemeColors = staticCompositionLocalOf {
    ThemeColors(BackgroundLight, SurfaceLight, TextPrimaryLight, TextSecondaryLight)
}

/** نقطة وصول مختصرة لقيم الثيم داخل التركيب (composition). */
object Theme {
    val colors: ThemeColors
        @Composable @ReadOnlyComposable get() = LocalThemeColors.current

    val cornerRadius: Dp = 18.dp
    val cardShadow: Color = Color.Black.copy(alpha = 0.06f)
}

/**
 * يطبّق ثيم التطبيق: ألوان متجاوبة مع الوضع الليلي، Material3،
 * واتجاه RTL كامل للعربية.
 */
@Composable
fun TayyibatTheme(content: @Composable () -> Unit) {
    val dark = isSystemInDarkTheme()
    val colors = if (dark) {
        ThemeColors(BackgroundDark, SurfaceDark, TextPrimaryDark, TextSecondaryDark)
    } else {
        ThemeColors(BackgroundLight, SurfaceLight, TextPrimaryLight, TextSecondaryLight)
    }

    val scheme = if (dark) {
        darkColorScheme(
            primary = Primary,
            secondary = Gold,
            error = Khabith,
            background = BackgroundDark,
            surface = SurfaceDark,
            onBackground = TextPrimaryDark,
            onSurface = TextPrimaryDark,
        )
    } else {
        lightColorScheme(
            primary = Primary,
            secondary = Gold,
            error = Khabith,
            background = BackgroundLight,
            surface = SurfaceLight,
            onBackground = TextPrimaryLight,
            onSurface = TextPrimaryLight,
        )
    }

    CompositionLocalProvider(
        LocalThemeColors provides colors,
        LocalLayoutDirection provides LayoutDirection.Rtl,
    ) {
        MaterialTheme(
            colorScheme = scheme,
            typography = TayyibatTypography,
            content = content,
        )
    }
}
