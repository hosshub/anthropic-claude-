package com.tayyibat.app.ui.auth

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Language
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.SegmentedButtonDefaults
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.tayyibat.app.R
import com.tayyibat.app.service.AuthService
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Khabith
import com.tayyibat.app.ui.theme.Primary
import com.tayyibat.app.ui.theme.Theme
import kotlinx.coroutines.launch

@Composable
fun AuthScreen(auth: AuthService) {
    val state by auth.state.collectAsStateWithLifecycle()
    val scope = rememberCoroutineScope()
    val context = LocalContext.current

    var signUpMode by remember { mutableStateOf(false) }
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }

    val canSubmit = !state.isWorking && email.contains("@") && password.length >= 6

    LaunchedEffect(signUpMode) { auth.clearMessages() }

    Column(
        Modifier
            .fillMaxSize()
            .background(Theme.colors.background)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 28.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Spacer(Modifier.size(24.dp))
        Image(
            painter = painterResource(R.drawable.brand_logo),
            contentDescription = null,
            modifier = Modifier.size(96.dp).clip(RoundedCornerShape(24.dp)),
        )
        Text("الطيبات", style = AppType.displayTitle, color = Theme.colors.textPrimary)
        Text(
            if (signUpMode) "أنشئ حساباً للبدء" else "سجّل الدخول للمتابعة",
            style = AppType.bodyText, color = Theme.colors.textSecondary,
        )

        SingleChoiceSegmentedButtonRow(Modifier.fillMaxWidth().widthIn(max = 460.dp)) {
            SegmentedButton(
                selected = !signUpMode,
                onClick = { signUpMode = false },
                shape = SegmentedButtonDefaults.itemShape(0, 2),
            ) { Text("تسجيل الدخول") }
            SegmentedButton(
                selected = signUpMode,
                onClick = { signUpMode = true },
                shape = SegmentedButtonDefaults.itemShape(1, 2),
            ) { Text("حساب جديد") }
        }

        OutlinedTextField(
            value = email, onValueChange = { email = it },
            placeholder = { Text("البريد الإلكتروني") },
            singleLine = true, modifier = Modifier.fillMaxWidth().widthIn(max = 460.dp),
        )
        OutlinedTextField(
            value = password, onValueChange = { password = it },
            placeholder = { Text("كلمة المرور (٦ أحرف فأكثر)") },
            singleLine = true,
            visualTransformation = PasswordVisualTransformation(),
            modifier = Modifier.fillMaxWidth().widthIn(max = 460.dp),
        )

        Button(
            onClick = {
                scope.launch {
                    if (signUpMode) auth.signUp(email, password) else auth.signIn(email, password)
                }
            },
            enabled = canSubmit,
            colors = ButtonDefaults.buttonColors(containerColor = Primary),
            modifier = Modifier.fillMaxWidth().height(48.dp).widthIn(max = 460.dp),
        ) {
            Text(if (signUpMode) "إنشاء الحساب" else "تسجيل الدخول")
        }

        OutlinedButton(
            onClick = { context.startActivity(auth.buildGoogleAuthIntent()) },
            enabled = !state.isWorking,
            modifier = Modifier.fillMaxWidth().height(48.dp).widthIn(max = 460.dp),
        ) {
            Icon(Icons.Filled.Language, contentDescription = null)
            Spacer(Modifier.size(10.dp))
            Text("المتابعة عبر Google")
        }

        if (state.isWorking) CircularProgressIndicator()
        state.infoMessage?.let {
            Text(it, style = AppType.caption, color = Primary, textAlign = TextAlign.Center)
        }
        state.lastError?.let {
            Text(it, style = AppType.caption, color = Khabith, textAlign = TextAlign.Center)
        }

        Text(
            "بالمتابعة فإنك توافق على سياسة الخصوصية الخاصة بالتطبيق.",
            style = AppType.caption, color = Theme.colors.textSecondary, textAlign = TextAlign.Center,
        )
        Spacer(Modifier.size(24.dp))
    }
}
