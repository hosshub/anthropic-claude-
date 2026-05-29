package com.tayyibat.app.ui.result

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.FilterChip
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.tayyibat.app.data.model.EditableItem
import com.tayyibat.app.data.model.Verdict
import com.tayyibat.app.ui.theme.AppType
import com.tayyibat.app.ui.theme.Theme

@Composable
fun EditItemDialog(
    item: EditableItem,
    onDismiss: () -> Unit,
    onSave: (EditableItem) -> Unit,
) {
    var name by remember { mutableStateOf(item.nameAr) }
    var verdict by remember { mutableStateOf(item.verdict) }
    var portion by remember { mutableStateOf(item.estimatedPortion) }
    var category by remember { mutableStateOf(item.category) }

    val portions = listOf("حصة صغيرة", "متوسطة", "حصة كبيرة")

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("تعديل العنصر") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                OutlinedTextField(value = name, onValueChange = { name = it }, label = { Text("الاسم") }, modifier = Modifier.fillMaxWidth(), singleLine = true)

                Text("الحكم", style = AppType.caption, color = Theme.colors.textSecondary)
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    Verdict.entries.forEach { v ->
                        FilterChip(selected = verdict == v, onClick = { verdict = v }, label = { Text(v.labelAr) })
                    }
                }

                Text("الحصة", style = AppType.caption, color = Theme.colors.textSecondary)
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    portions.forEach { p ->
                        FilterChip(selected = portion == p, onClick = { portion = p }, label = { Text(p) })
                    }
                }

                OutlinedTextField(value = category, onValueChange = { category = it }, label = { Text("الفئة") }, modifier = Modifier.fillMaxWidth(), singleLine = true)
            }
        },
        confirmButton = {
            TextButton(onClick = {
                onSave(item.copy(nameAr = name, verdict = verdict, estimatedPortion = portion, category = category, wasEdited = true))
            }) { Text("حفظ") }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("إلغاء") }
        },
    )
}
