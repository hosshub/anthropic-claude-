package com.tayyibat.app.data.db

import androidx.room.TypeConverter

/** محوّلات Room للأنواع المركّبة (قوائم النصوص والأعداد). */
class Converters {
    // فاصل وحدة (Unit Separator) لا يظهر عادةً في النصوص العربية.
    private val sep = "\u001F"

    @TypeConverter
    fun fromStringList(value: List<String>?): String =
        value?.joinToString(sep) ?: ""

    @TypeConverter
    fun toStringList(value: String): List<String> =
        if (value.isEmpty()) emptyList() else value.split(sep)

    @TypeConverter
    fun fromIntList(value: List<Int>?): String =
        value?.joinToString(",") ?: ""

    @TypeConverter
    fun toIntList(value: String): List<Int> =
        if (value.isEmpty()) emptyList() else value.split(",").mapNotNull { it.toIntOrNull() }
}
