package com.tayyibat.app.ui.navigation

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Book
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.WbSunny
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.navigation.NavController
import com.tayyibat.app.data.model.UserProfile
import com.tayyibat.app.ui.guide.GuideScreen
import com.tayyibat.app.ui.history.HistoryScreen
import com.tayyibat.app.ui.settings.SettingsScreen
import com.tayyibat.app.ui.theme.Primary
import com.tayyibat.app.ui.theme.Theme
import com.tayyibat.app.ui.today.TodayScreen

private data class Tab(val label: String, val icon: ImageVector)

@Composable
fun MainScaffold(profile: UserProfile, rootNav: NavController) {
    var selected by remember { mutableIntStateOf(0) }
    val tabs = listOf(
        Tab("اليوم", Icons.Filled.WbSunny),
        Tab("السجل", Icons.Filled.CalendarMonth),
        Tab("الدليل", Icons.Filled.Book),
        Tab("الإعدادات", Icons.Filled.Settings),
    )

    Scaffold(
        containerColor = Theme.colors.background,
        bottomBar = {
            NavigationBar(containerColor = Theme.colors.surface) {
                tabs.forEachIndexed { index, tab ->
                    NavigationBarItem(
                        selected = selected == index,
                        onClick = { selected = index },
                        icon = { Icon(tab.icon, contentDescription = tab.label) },
                        label = { Text(tab.label) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = Primary,
                            selectedTextColor = Primary,
                            indicatorColor = Primary.copy(alpha = 0.12f),
                        ),
                    )
                }
            }
        },
    ) { inner ->
        val content = Modifier.padding(inner)
        when (selected) {
            0 -> TodayScreen(
                profile = profile,
                modifier = content,
                onCapture = { rootNav.navigate(Routes.CAPTURE) },
                onMealClick = { id -> rootNav.navigate(Routes.mealDetail(id)) },
                onSuggestions = { rootNav.navigate(Routes.SUGGESTIONS) },
            )
            1 -> HistoryScreen(
                modifier = content,
                onDayClick = { dayMillis -> rootNav.navigate(Routes.dayDetail(dayMillis)) },
            )
            2 -> GuideScreen(
                modifier = content,
                onBehavioral = { rootNav.navigate(Routes.GUIDE_BEHAVIORAL) },
                onFasting = { rootNav.navigate(Routes.GUIDE_FASTING) },
                onCategory = { id -> rootNav.navigate(Routes.category(id)) },
            )
            3 -> SettingsScreen(
                profile = profile,
                modifier = content,
                onApiKey = { rootNav.navigate(Routes.SETTINGS_API_KEY) },
                onNotifications = { rootNav.navigate(Routes.SETTINGS_NOTIFICATIONS) },
                onDisclaimer = { rootNav.navigate(Routes.SETTINGS_DISCLAIMER) },
            )
        }
    }
}
