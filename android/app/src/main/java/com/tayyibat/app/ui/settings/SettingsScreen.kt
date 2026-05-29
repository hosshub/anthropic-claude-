package com.tayyibat.app.ui.settings

import android.content.Intent
import androidx.core.content.FileProvider
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowLeft
import androidx.compose.material.icons.automirrored.filled.Logout
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Key
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Upload
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.tayyibat.app.config.AppConfig
import com.tayyibat.app.data.model.UserGoal
import com.tayyibat.app.data.model.UserProfile
import com.tayyibat.app.ui.components.CardContainer
import com.tayyibat.app.ui.components.clickableNoRipple
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Khabith
import com.tayyibat.app.ui.theme.Primary
import com.tayyibat.app.ui.theme.Theme

@Composable
fun SettingsScreen(
    profile: UserProfile,
    modifier: Modifier = Modifier,
    onApiKey: () -> Unit,
    onNotifications: () -> Unit,
    onDisclaimer: () -> Unit,
    vm: SettingsViewModel = viewModel(),
) {
    val context = LocalContext.current
    val authState by vm.auth.state.collectAsStateWithLifecycle()
    var name by remember(profile.name) { mutableStateOf(profile.name) }
    var showDeleteConfirm by remember { mutableStateOf(false) }

    Column(
        modifier
            .fillMaxSize()
            .background(Theme.colors.background)
            .verticalScroll(rememberScrollState())
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Text("الإعدادات", style = AppType.screenTitle, color = Theme.colors.textPrimary)

        // الملف الشخصي
        CardContainer {
            Text("الملف الشخصي", style = AppType.cardTitle, color = Theme.colors.textPrimary)
            OutlinedTextField(
                value = name,
                onValueChange = { name = it; vm.updateName(it) },
                label = { Text("الاسم") },
                singleLine = true,
                modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
            )
            Text("الهدف", style = AppType.caption, color = Theme.colors.textSecondary, modifier = Modifier.padding(top = 8.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                UserGoal.entries.forEach { g ->
                    FilterChip(selected = profile.goal == g, onClick = { vm.updateGoal(g) }, label = { Text(g.labelAr) })
                }
            }
        }

        // النظام
        CardContainer {
            Text("النظام", style = AppType.cardTitle, color = Theme.colors.textPrimary)
            if (!AppConfig.usesProxy) {
                SettingRow(Icons.Filled.Key, "مفتاح Gemini API", onApiKey)
            }
            SettingRow(Icons.Filled.Notifications, "الإشعارات", onNotifications)
        }

        // البيانات
        CardContainer {
            Text("البيانات", style = AppType.cardTitle, color = Theme.colors.textPrimary)
            SettingRow(Icons.Filled.Upload, "تصدير البيانات (JSON)") {
                vm.exportData { file ->
                    if (file != null) {
                        val uri = FileProvider.getUriForFile(context, "${context.packageName}.fileprovider", file)
                        val intent = Intent(Intent.ACTION_SEND).apply {
                            type = "application/json"
                            putExtra(Intent.EXTRA_STREAM, uri)
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }
                        context.startActivity(Intent.createChooser(intent, "تصدير البيانات"))
                    }
                }
            }
            SettingRow(Icons.Filled.Delete, "حذف كل بيانات المتابعة", tint = Khabith) { showDeleteConfirm = true }
        }

        // الحساب
        if (AppConfig.authEnabled) {
            CardContainer {
                Text("الحساب", style = AppType.cardTitle, color = Theme.colors.textPrimary)
                authState.userEmail?.let { email ->
                    Row(Modifier.fillMaxWidth().padding(top = 8.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("الحساب", style = AppType.bodyText, color = Theme.colors.textPrimary)
                        Text(email, style = AppType.bodyText, color = Theme.colors.textSecondary)
                    }
                }
                SettingRow(Icons.AutoMirrored.Filled.Logout, "تسجيل الخروج", tint = Khabith) { vm.signOut() }
            }
        }

        // معلومات
        CardContainer {
            Text("معلومات", style = AppType.cardTitle, color = Theme.colors.textPrimary)
            SettingRow(Icons.Filled.Info, "تنبيه طبي", tint = Khabith, onClick = onDisclaimer)
            Row(Modifier.fillMaxWidth().padding(top = 8.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                Text("الإصدار", style = AppType.bodyText, color = Theme.colors.textPrimary)
                Text("1.0", style = AppType.bodyText, color = Theme.colors.textSecondary)
            }
        }
    }

    if (showDeleteConfirm) {
        AlertDialog(
            onDismissRequest = { showDeleteConfirm = false },
            title = { Text("حذف كل البيانات؟") },
            text = { Text("سيتم حذف جميع الوجبات والملخصات وأيام الصيام نهائياً. لا يمكن التراجع.") },
            confirmButton = {
                TextButton(onClick = { vm.deleteAllData(); showDeleteConfirm = false }) {
                    Text("حذف", color = Khabith)
                }
            },
            dismissButton = { TextButton(onClick = { showDeleteConfirm = false }) { Text("إلغاء") } },
        )
    }
}

@Composable
private fun SettingRow(icon: ImageVector, title: String, tint: androidx.compose.ui.graphics.Color = Primary, onClick: () -> Unit) {
    Row(
        Modifier.fillMaxWidth().clickableNoRipple(onClick).padding(top = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Icon(icon, contentDescription = null, tint = tint, modifier = Modifier.size(22.dp))
        Text(title, style = AppType.bodyText, color = Theme.colors.textPrimary, modifier = Modifier.weight(1f))
        Icon(Icons.AutoMirrored.Filled.KeyboardArrowLeft, contentDescription = null, tint = Theme.colors.textSecondary)
    }
}
