package com.tayyibat.app.ui.components

import android.graphics.BitmapFactory
import androidx.compose.foundation.clickable
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap

/** نقرة بدون أثر مرئي (ripple) — لمحاكاة أزرار iOS. */
fun Modifier.clickableNoRipple(onClick: () -> Unit): Modifier =
    this.clickable(indication = null, interactionSource = null, onClick = onClick)

/** يفك ترميز بايتات الصورة إلى ImageBitmap مرة واحدة (مع تخزين مؤقت بالتركيب). */
@Composable
fun rememberImageBitmap(bytes: ByteArray?): ImageBitmap? = remember(bytes) {
    if (bytes == null) null
    else runCatching {
        BitmapFactory.decodeByteArray(bytes, 0, bytes.size)?.asImageBitmap()
    }.getOrNull()
}
