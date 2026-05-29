package com.tayyibat.app.ui.guide

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowLeft
import androidx.compose.material.icons.automirrored.filled.ListAlt
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.Search
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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.tayyibat.app.data.model.Verdict
import com.tayyibat.app.service.RulesService
import com.tayyibat.app.ui.components.CardContainer
import com.tayyibat.app.ui.components.MedicalDisclaimerFooter
import com.tayyibat.app.ui.components.VerdictBadge
import com.tayyibat.app.ui.components.clickableNoRipple
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Khabith
import com.tayyibat.app.ui.theme.Primary
import com.tayyibat.app.ui.theme.Theme

@Composable
fun GuideScreen(
    modifier: Modifier = Modifier,
    onBehavioral: () -> Unit,
    onFasting: () -> Unit,
    onCategory: (String) -> Unit,
) {
    val rules = RulesService.rules
    var query by remember { mutableStateOf("") }
    val results = remember(query) { RulesService.lookup(query) }

    Column(
        modifier
            .fillMaxSize()
            .background(Theme.colors.background)
            .verticalScroll(rememberScrollState())
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(18.dp),
    ) {
        Text("دليل النظام", style = AppType.screenTitle, color = Theme.colors.textPrimary)

        OutlinedTextField(
            value = query,
            onValueChange = { query = it },
            placeholder = { Text("هل (اسم الطعام) مسموح؟") },
            leadingIcon = { Icon(Icons.Filled.Search, contentDescription = null) },
            trailingIcon = {
                if (query.isNotEmpty()) {
                    Icon(Icons.Filled.Clear, contentDescription = null, modifier = Modifier.clickableNoRipple { query = "" })
                }
            },
            singleLine = true,
            modifier = Modifier.fillMaxWidth(),
        )

        if (query.isNotEmpty()) {
            if (results.isEmpty()) {
                Text("لم نجد \"$query\" في قوائم النظام. جرّب اسماً آخر.", style = AppType.bodyText, color = Theme.colors.textSecondary)
            } else {
                results.forEach { r ->
                    CardContainer {
                        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                            Column {
                                Text(r.term, style = AppType.cardTitle, color = Theme.colors.textPrimary)
                                Text(r.category.nameAr, style = AppType.caption, color = Theme.colors.textSecondary)
                            }
                            VerdictBadge(if (r.allowed) Verdict.TAYYIB else Verdict.KHABITH)
                        }
                    }
                }
            }
        } else {
            LinkRow(Icons.AutoMirrored.Filled.ListAlt, "القواعد السلوكية الثمانية", onBehavioral)
            LinkRow(Icons.Filled.DarkMode, "الصيام المستحب", onFasting)

            Text("فئات الطعام", style = AppType.sectionTitle, color = Theme.colors.textPrimary)
            rules.categories.forEach { category ->
                CardContainer(Modifier.clickableNoRipple { onCategory(category.id) }) {
                    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                        Icon(categoryIcon(category.id), contentDescription = null, tint = Primary, modifier = Modifier.size(28.dp))
                        Column(Modifier.weight(1f)) {
                            Text(category.nameAr, style = AppType.cardTitle, color = Theme.colors.textPrimary)
                            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                                if (category.allowed.isNotEmpty()) Text("${category.allowed.size} مسموح", style = AppType.caption, color = Primary)
                                if (category.forbidden.isNotEmpty()) Text("${category.forbidden.size} ممنوع", style = AppType.caption, color = Khabith)
                            }
                        }
                        Icon(Icons.AutoMirrored.Filled.KeyboardArrowLeft, contentDescription = null, tint = Theme.colors.textSecondary)
                    }
                }
            }
        }

        MedicalDisclaimerFooter()
    }
}

@Composable
private fun LinkRow(icon: ImageVector, title: String, onClick: () -> Unit) {
    CardContainer(Modifier.clickableNoRipple(onClick)) {
        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            Icon(icon, contentDescription = null, tint = Primary, modifier = Modifier.size(28.dp))
            Text(title, style = AppType.cardTitle, color = Theme.colors.textPrimary, modifier = Modifier.weight(1f))
            Icon(Icons.AutoMirrored.Filled.KeyboardArrowLeft, contentDescription = null, tint = Theme.colors.textSecondary)
        }
    }
}
