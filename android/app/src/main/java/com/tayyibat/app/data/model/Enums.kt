package com.tayyibat.app.data.model

import androidx.compose.ui.graphics.Color
import com.tayyibat.app.ui.theme.Gold
import com.tayyibat.app.ui.theme.Khabith
import com.tayyibat.app.ui.theme.Primary

/** حكم النظام على عنصر الطعام. */
enum class Verdict(val raw: String) {
    TAYYIB("tayyib"),
    KHABITH("khabith"),
    CONDITIONAL("conditional");

    val labelAr: String
        get() = when (this) {
            TAYYIB -> "طيّب"
            KHABITH -> "خبيث"
            CONDITIONAL -> "مشروط"
        }

    val color: Color
        get() = when (this) {
            TAYYIB -> Primary
            KHABITH -> Khabith
            CONDITIONAL -> Gold
        }

    companion object {
        /** تحويل آمن من النص القادم من النموذج/الـ API. */
        fun from(raw: String): Verdict =
            entries.firstOrNull { it.raw == raw.lowercase() } ?: CONDITIONAL
    }
}

/** نوع يوم الصيام المقترح/المسجّل. */
enum class FastingType(val raw: String) {
    MONDAY("monday"),
    THURSDAY("thursday"),
    WHITE_DAY("whiteDay"),
    INTERMITTENT("intermittent"),
    VOLUNTARY("voluntary");

    val labelAr: String
        get() = when (this) {
            MONDAY -> "صيام الإثنين"
            THURSDAY -> "صيام الخميس"
            WHITE_DAY -> "الأيام البيض"
            INTERMITTENT -> "صيام متقطع"
            VOLUNTARY -> "صيام تطوّعي"
        }

    companion object {
        fun from(raw: String): FastingType =
            entries.firstOrNull { it.raw == raw } ?: VOLUNTARY
    }
}

enum class TipCategory(val raw: String) {
    MORNING("morning"),
    AFTERNOON("afternoon"),
    EVENING("evening"),
    GENERAL("general"),
    FASTING("fasting");

    val labelAr: String
        get() = when (this) {
            MORNING -> "صباحية"
            AFTERNOON -> "ظهرية"
            EVENING -> "مسائية"
            GENERAL -> "عامة"
            FASTING -> "صيام"
        }

    companion object {
        fun from(raw: String): TipCategory =
            entries.firstOrNull { it.raw == raw } ?: GENERAL
    }
}

enum class NotificationIntensity(val raw: String) {
    LOW("low"),
    MEDIUM("medium"),
    HIGH("high");

    val labelAr: String
        get() = when (this) {
            LOW -> "قليل"
            MEDIUM -> "متوسط"
            HIGH -> "مكثّف"
        }

    /** عدد النصائح اليومية المقابلة للشدّة. */
    val dailyTipCount: Int
        get() = when (this) {
            LOW -> 1
            MEDIUM -> 3
            HIGH -> 5
        }

    companion object {
        fun from(raw: String): NotificationIntensity =
            entries.firstOrNull { it.raw == raw } ?: MEDIUM
    }
}

enum class UserGoal(val raw: String) {
    ADHERENCE("adherence"),
    WEIGHT("weight");

    val labelAr: String
        get() = when (this) {
            ADHERENCE -> "متابعة الالتزام"
            WEIGHT -> "تتبّع الوزن"
        }

    companion object {
        fun from(raw: String): UserGoal =
            entries.firstOrNull { it.raw == raw } ?: ADHERENCE
    }
}
