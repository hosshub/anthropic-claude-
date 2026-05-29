package com.tayyibat.app.ui.settings

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.ErrorOutline
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import com.tayyibat.app.data.SecureStore
import com.tayyibat.app.ui.components.CardContainer
import com.tayyibat.app.ui.components.DetailScaffold
import com.tayyibat.app.ui.components.PrimaryButton
import com.tayyibat.app.ui.components.SecondaryButton
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Khabith
import com.tayyibat.app.ui.theme.Primary
import com.tayyibat.app.ui.theme.Theme

@Composable
fun ApiKeyScreen(onBack: () -> Unit) {
    val context = LocalContext.current
    var keyInput by remember { mutableStateOf("") }
    var hasKey by remember { mutableStateOf(SecureStore.hasApiKey(context)) }

    DetailScaffold("مفتاح Gemini API", onBack) { modifier ->
        Column(
            modifier.verticalScroll(rememberScrollState()).padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            CardContainer {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    if (hasKey) {
                        Icon(Icons.Filled.CheckCircle, contentDescription = null, tint = Primary)
                        Text("مفتاح API محفوظ", style = AppType.bodyText, color = Primary)
                    } else {
                        Icon(Icons.Filled.ErrorOutline, contentDescription = null, tint = Khabith)
                        Text("لا يوجد مفتاح محفوظ", style = AppType.bodyText, color = Khabith)
                    }
                }
            }

            CardContainer {
                Text("إدخال المفتاح", style = AppType.cardTitle, color = Theme.colors.textPrimary)
                OutlinedTextField(
                    value = keyInput,
                    onValueChange = { keyInput = it },
                    placeholder = { Text("AIza...") },
                    visualTransformation = PasswordVisualTransformation(),
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
                )
                PrimaryButton(
                    "حفظ المفتاح",
                    modifier = Modifier.padding(top = 12.dp),
                    enabled = keyInput.trim().isNotEmpty(),
                ) {
                    SecureStore.saveApiKey(context, keyInput.trim())
                    keyInput = ""
                    hasKey = true
                }
            }

            if (hasKey) {
                SecondaryButton("حذف المفتاح") {
                    SecureStore.deleteApiKey(context)
                    hasKey = false
                }
            }

            Text(
                "يُخزَّن المفتاح بأمان ومشفّراً على جهازك فقط، ولا يُرسل لأي خادم غير Google (Gemini) أثناء تحليل الصور. احصل على مفتاحك من https://aistudio.google.com/apikey",
                style = AppType.caption, color = Theme.colors.textSecondary,
            )
        }
    }
}
