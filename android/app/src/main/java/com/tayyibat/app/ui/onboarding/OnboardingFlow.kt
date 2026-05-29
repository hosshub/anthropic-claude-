package com.tayyibat.app.ui.onboarding

import android.Manifest
import android.os.Build
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.weight
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.AccessTime
import androidx.compose.material.icons.filled.CameraAlt
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Restaurant
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.tayyibat.app.R
import com.tayyibat.app.data.model.UserGoal
import com.tayyibat.app.ui.components.PrimaryButton
import com.tayyibat.app.ui.components.clickableNoRipple
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Gold
import com.tayyibat.app.ui.theme.Primary
import com.tayyibat.app.ui.theme.Theme

private enum class Step { WELCOME, DISCLAIMER, PHILOSOPHY, PROFILE, NOTIFICATIONS }

@Composable
fun OnboardingFlow(
    onComplete: (name: String, age: Int?, goal: UserGoal, notificationsEnabled: Boolean, reminderHours: List<Int>) -> Unit,
) {
    var step by rememberSaveable { mutableStateOf(Step.WELCOME) }
    var name by rememberSaveable { mutableStateOf("") }
    var ageText by rememberSaveable { mutableStateOf("") }
    var goal by rememberSaveable { mutableStateOf(UserGoal.ADHERENCE) }

    fun advance() {
        step = Step.entries[(step.ordinal + 1).coerceAtMost(Step.entries.lastIndex)]
    }

    Box(Modifier.fillMaxSize().background(Theme.colors.background)) {
        AnimatedContent(targetState = step, label = "onboarding") { current ->
            when (current) {
                Step.WELCOME -> WelcomeStep(onContinue = ::advance)
                Step.DISCLAIMER -> DisclaimerContent(showAcceptButton = true, onAccept = ::advance)
                Step.PHILOSOPHY -> PhilosophyStep(onContinue = ::advance)
                Step.PROFILE -> ProfileStep(
                    name = name, ageText = ageText, goal = goal,
                    onChange = { n, a, g -> name = n; ageText = a; goal = g },
                    onContinue = ::advance,
                )
                Step.NOTIFICATIONS -> NotificationStep(
                    onFinish = { granted, hours ->
                        onComplete(name, ageText.filter { it.isDigit() }.toIntOrNull(), goal, granted, hours)
                    },
                )
            }
        }
    }
}

@Composable
private fun WelcomeStep(onContinue: () -> Unit) {
    Column(
        Modifier.fillMaxSize().padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Image(
            painter = painterResource(R.drawable.brand_logo),
            contentDescription = null,
            modifier = Modifier.size(150.dp).clip(RoundedCornerShape(34.dp)),
        )
        Spacer(Modifier.size(24.dp))
        Text("الطيبات", style = AppType.displayTitle, color = Theme.colors.textPrimary)
        Spacer(Modifier.size(8.dp))
        Text(
            "رفيقك لتتبع الالتزام بنظام الطيبات الغذائي — صوّر وجبتك واعرف مدى توافقها.",
            style = AppType.bodyText, color = Theme.colors.textSecondary, textAlign = TextAlign.Center,
        )
        Spacer(Modifier.size(40.dp))
        PrimaryButton("ابدأ", icon = Icons.AutoMirrored.Filled.ArrowForward, onClick = onContinue)
    }
}

@Composable
private fun PhilosophyStep(onContinue: () -> Unit) {
    Column(Modifier.fillMaxSize()) {
        Column(
            Modifier.weight(1f).verticalScroll(rememberScrollState()).padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp),
        ) {
            Text("عن نظام الطيبات", style = AppType.screenTitle, color = Theme.colors.textPrimary)
            Text(
                "نظام الطيبات تصنيف للأطعمة إلى \"طيّبات\" مسموحة و\"خبائث\" متجنَّبة، مع جملة من القواعد السلوكية حول توقيت الأكل والصيام.",
                style = AppType.bodyText, color = Theme.colors.textPrimary,
            )
            Feature(Icons.Filled.Restaurant, "تصنيف الأطعمة", "كل طعام يُصنَّف طيّباً أو خبيثاً أو مشروطاً وفق قوائم النظام.")
            Feature(Icons.Filled.AccessTime, "الإصغاء للجوع", "الأكل عند الجوع الحقيقي والتوقف قبل الشبع الكامل، دون مواعيد ثابتة.")
            Feature(Icons.Filled.DarkMode, "الصيام", "صيام الإثنين والخميس والأيام البيض إضافةً للصيام المتقطع.")
            Feature(Icons.Filled.CameraAlt, "المتابعة بالصورة", "تصوّر وجبتك فيحلّلها التطبيق ويعرض مدى توافقها مع النظام.")
            Text(
                "هذا التطبيق لا يتبنّى موقفاً طبياً من النظام؛ هو أداة محايدة لمن اختار اتباعه.",
                style = AppType.caption, color = Theme.colors.textSecondary,
            )
        }
        PrimaryButton(
            "متابعة", icon = Icons.AutoMirrored.Filled.ArrowForward,
            modifier = Modifier.padding(20.dp), onClick = onContinue,
        )
    }
}

@Composable
private fun Feature(icon: ImageVector, title: String, body: String) {
    Row(horizontalArrangement = Arrangement.spacedBy(14.dp)) {
        Icon(icon, contentDescription = null, tint = Primary, modifier = Modifier.size(34.dp))
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text(title, style = AppType.cardTitle, color = Theme.colors.textPrimary)
            Text(body, style = AppType.bodyText, color = Theme.colors.textSecondary)
        }
    }
}

@Composable
private fun ProfileStep(
    name: String,
    ageText: String,
    goal: UserGoal,
    onChange: (String, String, UserGoal) -> Unit,
    onContinue: () -> Unit,
) {
    Column(Modifier.fillMaxSize()) {
        Column(
            Modifier.weight(1f).verticalScroll(rememberScrollState()).padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(24.dp),
        ) {
            Text("ملفك الشخصي", style = AppType.screenTitle, color = Theme.colors.textPrimary)

            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("الاسم", style = AppType.cardTitle, color = Theme.colors.textPrimary)
                OutlinedTextField(
                    value = name,
                    onValueChange = { onChange(it, ageText, goal) },
                    placeholder = { Text("اكتب اسمك") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                )
            }

            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("العمر (اختياري)", style = AppType.cardTitle, color = Theme.colors.textPrimary)
                OutlinedTextField(
                    value = ageText,
                    onValueChange = { v -> onChange(name, normalizeDigits(v), goal) },
                    placeholder = { Text("العمر") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                )
            }

            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("هدفك", style = AppType.cardTitle, color = Theme.colors.textPrimary)
                SegmentedGoal(goal) { onChange(name, ageText, it) }
            }
        }
        PrimaryButton(
            "متابعة", icon = Icons.AutoMirrored.Filled.ArrowForward,
            enabled = name.trim().isNotEmpty(),
            modifier = Modifier.padding(20.dp), onClick = onContinue,
        )
    }
}

@Composable
private fun SegmentedGoal(selected: UserGoal, onSelect: (UserGoal) -> Unit) {
    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        UserGoal.entries.forEach { g ->
            FilterChip(
                selected = selected == g,
                onClick = { onSelect(g) },
                label = { Text(g.labelAr) },
            )
        }
    }
}

@Composable
private fun NotificationStep(onFinish: (granted: Boolean, hours: List<Int>) -> Unit) {
    val options = listOf("الصباح ١١ص" to 11, "الظهر ٢م" to 14, "العصر ٤م" to 16, "المساء ٨م" to 20)
    var selectedHours by remember { mutableStateOf(setOf(11, 16, 20)) }

    val permissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission(),
    ) { granted ->
        onFinish(granted, selectedHours.sorted())
    }

    fun requestEnable() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            permissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
        } else {
            onFinish(true, selectedHours.sorted())
        }
    }

    Column(Modifier.fillMaxSize()) {
        Column(
            Modifier.weight(1f).verticalScroll(rememberScrollState()).padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp),
        ) {
            Icon(
                Icons.Filled.Notifications, contentDescription = null, tint = Gold,
                modifier = Modifier.fillMaxWidth().size(56.dp),
            )
            Text("التذكيرات والنصائح", style = AppType.screenTitle, color = Theme.colors.textPrimary)
            Text(
                "نرسل تذكيرات مرنة ونصائح يومية لمساعدتك على الالتزام — كلها اختيارية ويمكنك تعديلها لاحقاً من الإعدادات.",
                style = AppType.bodyText, color = Theme.colors.textSecondary,
            )
            Text("أوقات التذكير المفضّلة", style = AppType.cardTitle, color = Theme.colors.textPrimary)
            options.forEach { (label, hour) ->
                Row(
                    Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween,
                ) {
                    Text(label, style = AppType.bodyText, color = Theme.colors.textPrimary)
                    Switch(
                        checked = selectedHours.contains(hour),
                        onCheckedChange = { on ->
                            selectedHours = if (on) selectedHours + hour else selectedHours - hour
                        },
                    )
                }
            }
        }
        Column(Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(10.dp), horizontalAlignment = Alignment.CenterHorizontally) {
            PrimaryButton("تفعيل الإشعارات", icon = Icons.Filled.Notifications) { requestEnable() }
            Text(
                "ليس الآن",
                style = AppType.bodyText, color = Theme.colors.textSecondary,
                modifier = Modifier
                    .fillMaxWidth()
                    .clickableNoRipple { onFinish(false, selectedHours.sorted()) }
                    .padding(8.dp),
                textAlign = TextAlign.Center,
            )
        }
    }
}

/** يحوّل أي أرقام (هندية/فارسية/لاتينية) إلى لاتينية ويُبقي الأرقام فقط (٣ خانات). */
fun normalizeDigits(input: String): String =
    input.mapNotNull { ch ->
        Character.digit(ch, 10).takeIf { it in 0..9 }?.toString()
    }.joinToString("").take(3)
