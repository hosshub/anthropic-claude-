package com.tayyibat.app.data.model

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey
import androidx.room.Relation
import androidx.room.Embedded

/**
 * نماذج التخزين (Room) — مكافئة لنماذج SwiftData في تطبيق iOS.
 * التواريخ تُخزَّن كـ epochMillis. الصور تُخزَّن كـ BLOB.
 */

@Entity(tableName = "meals")
data class Meal(
    @PrimaryKey val id: String,
    val capturedAt: Long,
    val imageData: ByteArray,
    val overallScore: Int,
    val scoreLabelAr: String = "",
    val scoreExplanationAr: String = "",
    /** قائمة الاقتراحات مفصولة بسطر جديد (محوّلة عبر Converters). */
    val improvementSuggestions: List<String> = emptyList(),
    val userNotes: String? = null,
    val wasEdited: Boolean = false,
) {
    override fun equals(other: Any?): Boolean = this === other || (other is Meal && other.id == id)
    override fun hashCode(): Int = id.hashCode()
}

@Entity(
    tableName = "food_items",
    indices = [Index("mealId")],
)
data class FoodItem(
    @PrimaryKey(autoGenerate = true) val itemId: Long = 0,
    val mealId: String,
    val nameAr: String,
    val verdictRaw: String,
    val category: String,
    val reasoning: String,
    val confidence: Double,
    val estimatedPortion: String = "متوسطة",
    val ruleViolated: String? = null,
) {
    val verdict: Verdict get() = Verdict.from(verdictRaw)
}

/** وجبة مع عناصرها (للقراءة من قاعدة البيانات). */
data class MealWithItems(
    @Embedded val meal: Meal,
    @Relation(parentColumn = "id", entityColumn = "mealId")
    val items: List<FoodItem>,
)

@Entity(tableName = "fasting_days")
data class FastingDay(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val date: Long,
    val typeRaw: String,
    val completed: Boolean = false,
) {
    val type: FastingType get() = FastingType.from(typeRaw)
}

@Entity(tableName = "daily_summaries")
data class DailySummary(
    @PrimaryKey val date: Long,
    val averageScore: Int = 0,
    val mealsCount: Int = 0,
    val fastedToday: Boolean = false,
)

@Entity(tableName = "notification_tips")
data class NotificationTip(
    @PrimaryKey val id: String,
    val categoryRaw: String,
    val textAr: String,
    val lastShownAt: Long? = null,
) {
    val category: TipCategory get() = TipCategory.from(categoryRaw)
}

@Entity(tableName = "user_profile")
data class UserProfile(
    @PrimaryKey val id: Int = 1,
    val name: String = "",
    val age: Int? = null,
    val goalRaw: String = UserGoal.ADHERENCE.raw,
    val disclaimerAcceptedAt: Long? = null,
    val notificationsEnabled: Boolean = false,
    val mealRemindersEnabled: Boolean = true,
    val tipsEnabled: Boolean = true,
    val fastingRemindersEnabled: Boolean = true,
    val logRemindersEnabled: Boolean = true,
    val dailyTipsIntensityRaw: String = NotificationIntensity.MEDIUM.raw,
    /** ساعة بداية ونهاية فترة "لا تزعج" (0-23). الافتراضي 23 → 7. */
    val quietHoursStart: Int = 23,
    val quietHoursEnd: Int = 7,
    /** النوافذ الزمنية المختارة للتذكيرات المرنة (ساعات اليوم 0-23). */
    val reminderHours: List<Int> = listOf(11, 16, 20),
) {
    val goal: UserGoal get() = UserGoal.from(goalRaw)
    val dailyTipsIntensity: NotificationIntensity get() = NotificationIntensity.from(dailyTipsIntensityRaw)
}
