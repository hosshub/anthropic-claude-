package com.tayyibat.app.ui.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.tayyibat.app.data.model.UserProfile
import com.tayyibat.app.ui.capture.CaptureScreen
import com.tayyibat.app.ui.guide.BehavioralRulesScreen
import com.tayyibat.app.ui.guide.CategoryDetailScreen
import com.tayyibat.app.ui.guide.FastingGuideScreen
import com.tayyibat.app.ui.history.DayDetailScreen
import com.tayyibat.app.ui.history.MealDetailScreen
import com.tayyibat.app.ui.settings.ApiKeyScreen
import com.tayyibat.app.ui.settings.DisclaimerScreen
import com.tayyibat.app.ui.settings.NotificationSettingsScreen
import com.tayyibat.app.ui.suggestions.SuggestionsScreen

object Routes {
    const val MAIN = "main"
    const val CAPTURE = "capture"
    const val SUGGESTIONS = "suggestions"
    const val MEAL_DETAIL = "mealDetail/{mealId}"
    const val DAY_DETAIL = "dayDetail/{dayMillis}"
    const val GUIDE_BEHAVIORAL = "guide/behavioral"
    const val GUIDE_FASTING = "guide/fasting"
    const val GUIDE_CATEGORY = "guide/category/{categoryId}"
    const val SETTINGS_API_KEY = "settings/apiKey"
    const val SETTINGS_NOTIFICATIONS = "settings/notifications"
    const val SETTINGS_DISCLAIMER = "settings/disclaimer"

    fun mealDetail(id: String) = "mealDetail/$id"
    fun dayDetail(dayMillis: Long) = "dayDetail/$dayMillis"
    fun category(id: String) = "guide/category/$id"
}

@Composable
fun AppNavHost(profile: UserProfile) {
    val nav = rememberNavController()
    NavHost(navController = nav, startDestination = Routes.MAIN) {
        composable(Routes.MAIN) {
            MainScaffold(profile = profile, rootNav = nav)
        }
        composable(Routes.CAPTURE) {
            CaptureScreen(onDone = { nav.popBackStack() })
        }
        composable(Routes.SUGGESTIONS) {
            SuggestionsScreen(onBack = { nav.popBackStack() })
        }
        composable(
            Routes.MEAL_DETAIL,
            arguments = listOf(navArgument("mealId") { type = NavType.StringType }),
        ) { entry ->
            MealDetailScreen(
                mealId = entry.arguments?.getString("mealId").orEmpty(),
                onBack = { nav.popBackStack() },
            )
        }
        composable(
            Routes.DAY_DETAIL,
            arguments = listOf(navArgument("dayMillis") { type = NavType.LongType }),
        ) { entry ->
            DayDetailScreen(
                dayMillis = entry.arguments?.getLong("dayMillis") ?: 0L,
                onBack = { nav.popBackStack() },
                onMealClick = { id -> nav.navigate(Routes.mealDetail(id)) },
            )
        }
        composable(Routes.GUIDE_BEHAVIORAL) {
            BehavioralRulesScreen(onBack = { nav.popBackStack() })
        }
        composable(Routes.GUIDE_FASTING) {
            FastingGuideScreen(onBack = { nav.popBackStack() })
        }
        composable(
            Routes.GUIDE_CATEGORY,
            arguments = listOf(navArgument("categoryId") { type = NavType.StringType }),
        ) { entry ->
            CategoryDetailScreen(
                categoryId = entry.arguments?.getString("categoryId").orEmpty(),
                onBack = { nav.popBackStack() },
            )
        }
        composable(Routes.SETTINGS_API_KEY) {
            ApiKeyScreen(onBack = { nav.popBackStack() })
        }
        composable(Routes.SETTINGS_NOTIFICATIONS) {
            NotificationSettingsScreen(onBack = { nav.popBackStack() })
        }
        composable(Routes.SETTINGS_DISCLAIMER) {
            DisclaimerScreen(onBack = { nav.popBackStack() })
        }
    }
}
