package com.tayyibat.app.ui.settings

import android.Manifest
import android.os.Build
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.tayyibat.app.data.model.NotificationIntensity
import com.tayyibat.app.ui.components.CardContainer
import com.tayyibat.app.ui.components.DetailScaffold
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Theme

@Composable
fun NotificationSettingsScreen(
    onBack: () -> Unit,
    vm: SettingsViewModel = viewModel(),
) {
    val profile by vm.profile.collectAsStateWithLifecycle()
    val p = profile

    val permissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission(),
    ) { granted -> vm.updateAndReschedule { it.copy(notificationsEnabled = granted) } }

    DetailScaffold("الإشعارات", onBack) { modifier ->
        if (p == null) return@DetailScaffold
        Column(
            modifier.verticalScroll(rememberScrollState()).padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            CardContainer {
                ToggleRow("تفعيل الإشعارات", p.notificationsEnabled) { on ->
                    if (on && Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        permissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
                    } else {
                        vm.updateAndReschedule { it.copy(notificationsEnabled = on) }
                    }
                }
                Text("جميع الإشعارات اختيارية وتُجدول محلياً على جهازك.", style = AppType.caption, color = Theme.colors.textSecondary, modifier = Modifier.padding(top = 8.dp))
            }

            if (p.notificationsEnabled) {
                CardContainer {
                    Text("الأنواع", style = AppType.cardTitle, color = Theme.colors.textPrimary)
                    ToggleRow("تذكيرات الوجبات المرنة", p.mealRemindersEnabled) { v -> vm.updateAndReschedule { it.copy(mealRemindersEnabled = v) } }
                    ToggleRow("نصائح يومية", p.tipsEnabled) { v -> vm.updateAndReschedule { it.copy(tipsEnabled = v) } }
                    ToggleRow("تذكيرات الصيام", p.fastingRemindersEnabled) { v -> vm.updateAndReschedule { it.copy(fastingRemindersEnabled = v) } }
                    ToggleRow("تذكير مراجعة اليوم", p.logRemindersEnabled) { v -> vm.updateAndReschedule { it.copy(logRemindersEnabled = v) } }
                }

                if (p.tipsEnabled) {
                    CardContainer {
                        Text("شدّة النصائح", style = AppType.cardTitle, color = Theme.colors.textPrimary)
                        Row(Modifier.padding(top = 8.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            NotificationIntensity.entries.forEach { intensity ->
                                FilterChip(
                                    selected = p.dailyTipsIntensity == intensity,
                                    onClick = { vm.setIntensity(intensity) },
                                    label = { Text("${intensity.labelAr} (${intensity.dailyTipCount}/يوم)") },
                                )
                            }
                        }
                    }
                }

                if (p.mealRemindersEnabled) {
                    CardContainer {
                        Text("أوقات تذكير الوجبات", style = AppType.cardTitle, color = Theme.colors.textPrimary)
                        val options = listOf("الصباح ١١ص" to 11, "الظهر ٢م" to 14, "العصر ٤م" to 16, "المساء ٨م" to 20)
                        options.forEach { (label, hour) ->
                            ToggleRow(label, p.reminderHours.contains(hour)) { on ->
                                vm.updateAndReschedule {
                                    val hours = it.reminderHours.toMutableSet()
                                    if (on) hours.add(hour) else hours.remove(hour)
                                    it.copy(reminderHours = hours.sorted())
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun ToggleRow(title: String, checked: Boolean, onChange: (Boolean) -> Unit) {
    Row(
        Modifier.fillMaxWidth().padding(top = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(title, style = AppType.bodyText, color = Theme.colors.textPrimary)
        Switch(checked = checked, onCheckedChange = onChange)
    }
}
