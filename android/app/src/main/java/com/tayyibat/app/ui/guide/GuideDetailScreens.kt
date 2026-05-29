package com.tayyibat.app.ui.guide

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.Info
import androidx.compose.material3.Divider
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.tayyibat.app.data.model.Verdict
import com.tayyibat.app.service.FastingCalculator
import com.tayyibat.app.service.RulesService
import com.tayyibat.app.ui.components.CardContainer
import com.tayyibat.app.ui.components.DetailScaffold
import com.tayyibat.app.ui.components.MedicalDisclaimerFooter
import com.tayyibat.app.ui.components.verdictIcon
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Gold
import com.tayyibat.app.ui.theme.Primary
import com.tayyibat.app.ui.theme.Theme
import com.tayyibat.app.util.DateUtils

@Composable
fun BehavioralRulesScreen(onBack: () -> Unit) {
    val rules = RulesService.rules.behavioralRules
    DetailScaffold("القواعد السلوكية", onBack) { modifier ->
        Column(
            modifier.verticalScroll(rememberScrollState()).padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            rules.forEachIndexed { index, rule ->
                CardContainer {
                    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(14.dp)) {
                        Box(
                            Modifier.size(32.dp).clip(CircleShape).background(Primary),
                            contentAlignment = Alignment.Center,
                        ) {
                            Text("${index + 1}", style = AppType.cardTitle.copy(fontWeight = FontWeight.Bold), color = Color.White)
                        }
                        Text(rule, style = AppType.bodyText, color = Theme.colors.textPrimary)
                    }
                }
            }
            MedicalDisclaimerFooter()
        }
    }
}

@Composable
fun FastingGuideScreen(onBack: () -> Unit) {
    val fasting = RulesService.rules.fasting
    val upcoming = FastingCalculator.upcomingFastingDays(days = 14)

    DetailScaffold("الصيام", onBack) { modifier ->
        Column(
            modifier.verticalScroll(rememberScrollState()).padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(18.dp),
        ) {
            CardContainer {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    Icon(Icons.Filled.CalendarMonth, contentDescription = null, tint = Primary, modifier = Modifier.size(18.dp))
                    Text("الصيام الأسبوعي", style = AppType.cardTitle, color = Primary)
                }
                Text(fasting.weekly.joinToString(" و"), style = AppType.bodyText, color = Theme.colors.textPrimary, modifier = Modifier.padding(top = 6.dp))
            }
            CardContainer {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    Icon(Icons.Filled.DarkMode, contentDescription = null, tint = Gold, modifier = Modifier.size(18.dp))
                    Text("الأيام البيض", style = AppType.cardTitle, color = Gold)
                }
                Text(
                    "أيام ${fasting.whiteDaysHijri.joinToString("، ")} من كل شهر هجري",
                    style = AppType.bodyText, color = Theme.colors.textPrimary, modifier = Modifier.padding(top = 6.dp),
                )
            }
            CardContainer {
                Text(fasting.notes, style = AppType.bodyText, color = Theme.colors.textSecondary)
            }
            CardContainer {
                Text("أيام الصيام القادمة", style = AppType.cardTitle, color = Theme.colors.textPrimary)
                if (upcoming.isEmpty()) {
                    Text("لا أيام صيام مستحبة خلال الأسبوعين القادمين", style = AppType.bodyText, color = Theme.colors.textSecondary, modifier = Modifier.padding(top = 6.dp))
                } else {
                    upcoming.forEach { entry ->
                        Row(Modifier.fillMaxWidth().padding(top = 8.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                            Text(DateUtils.abbreviatedDate(entry.date), style = AppType.bodyText, color = Theme.colors.textPrimary)
                            Text(entry.types.joinToString(" و") { it.labelAr }, style = AppType.caption, color = Gold)
                        }
                        Divider(color = Theme.colors.textSecondary.copy(alpha = 0.15f))
                    }
                }
            }
            MedicalDisclaimerFooter()
        }
    }
}

@Composable
fun CategoryDetailScreen(categoryId: String, onBack: () -> Unit) {
    val category = RulesService.rules.categories.firstOrNull { it.id == categoryId }
    DetailScaffold(category?.nameAr ?: "فئة", onBack) { modifier ->
        if (category == null) return@DetailScaffold
        Column(
            modifier.verticalScroll(rememberScrollState()).padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp),
        ) {
            category.note?.let { note ->
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    Icon(Icons.Filled.Info, contentDescription = null, tint = Gold, modifier = Modifier.size(18.dp))
                    Text(note, style = AppType.bodyText, color = Gold)
                }
            }
            if (category.allowed.isNotEmpty()) ItemList("مسموح (طيّبات)", category.allowed, Verdict.TAYYIB)
            if (category.forbidden.isNotEmpty()) ItemList("ممنوع (خبائث)", category.forbidden, Verdict.KHABITH)
            MedicalDisclaimerFooter()
        }
    }
}

@Composable
private fun ItemList(title: String, items: List<String>, verdict: Verdict) {
    CardContainer {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
            Text(title, style = AppType.sectionTitle, color = verdict.color)
            Icon(verdictIcon(verdict), contentDescription = null, tint = verdict.color)
        }
        items.forEach { item ->
            Row(Modifier.fillMaxWidth().padding(top = 8.dp), horizontalArrangement = Arrangement.spacedBy(10.dp), verticalAlignment = Alignment.CenterVertically) {
                Icon(verdictIcon(verdict), contentDescription = null, tint = verdict.color, modifier = Modifier.size(16.dp))
                Text(item, style = AppType.bodyText, color = Theme.colors.textPrimary)
            }
            Divider(color = Theme.colors.textSecondary.copy(alpha = 0.12f), modifier = Modifier.padding(top = 8.dp))
        }
    }
}
