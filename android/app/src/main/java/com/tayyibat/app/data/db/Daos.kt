package com.tayyibat.app.data.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction
import androidx.room.Update
import com.tayyibat.app.data.model.DailySummary
import com.tayyibat.app.data.model.FastingDay
import com.tayyibat.app.data.model.FoodItem
import com.tayyibat.app.data.model.Meal
import com.tayyibat.app.data.model.MealWithItems
import com.tayyibat.app.data.model.NotificationTip
import com.tayyibat.app.data.model.UserProfile
import kotlinx.coroutines.flow.Flow

@Dao
interface MealDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMeal(meal: Meal)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertItems(items: List<FoodItem>)

    @Transaction
    suspend fun insertMealWithItems(meal: Meal, items: List<FoodItem>) {
        insertMeal(meal)
        insertItems(items.map { it.copy(mealId = meal.id) })
    }

    @Transaction
    @Query("SELECT * FROM meals ORDER BY capturedAt DESC")
    fun observeAllMeals(): Flow<List<MealWithItems>>

    @Transaction
    @Query("SELECT * FROM meals ORDER BY capturedAt DESC")
    suspend fun allMeals(): List<MealWithItems>

    @Transaction
    @Query("SELECT * FROM meals WHERE capturedAt >= :start AND capturedAt < :end ORDER BY capturedAt DESC")
    fun observeMealsBetween(start: Long, end: Long): Flow<List<MealWithItems>>

    @Transaction
    @Query("SELECT * FROM meals WHERE capturedAt >= :start AND capturedAt < :end ORDER BY capturedAt DESC")
    suspend fun mealsBetween(start: Long, end: Long): List<MealWithItems>

    @Transaction
    @Query("SELECT * FROM meals WHERE id = :id")
    suspend fun mealById(id: String): MealWithItems?

    @Query("DELETE FROM meals")
    suspend fun deleteAllMeals()

    @Query("DELETE FROM food_items")
    suspend fun deleteAllItems()
}

@Dao
interface SummaryDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(summary: DailySummary)

    @Query("SELECT * FROM daily_summaries WHERE date = :date LIMIT 1")
    suspend fun summaryForDay(date: Long): DailySummary?

    @Query("SELECT * FROM daily_summaries")
    fun observeAll(): Flow<List<DailySummary>>

    @Query("SELECT * FROM daily_summaries")
    suspend fun all(): List<DailySummary>

    @Query("DELETE FROM daily_summaries")
    suspend fun deleteAll()
}

@Dao
interface FastingDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(day: FastingDay)

    @Query("SELECT * FROM fasting_days")
    suspend fun all(): List<FastingDay>

    @Query("DELETE FROM fasting_days")
    suspend fun deleteAll()
}

@Dao
interface TipDao {
    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insertAll(tips: List<NotificationTip>)

    @Update
    suspend fun update(tip: NotificationTip)

    @Query("SELECT COUNT(*) FROM notification_tips")
    suspend fun count(): Int

    @Query("SELECT * FROM notification_tips")
    suspend fun all(): List<NotificationTip>
}

@Dao
interface ProfileDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(profile: UserProfile)

    @Query("SELECT * FROM user_profile WHERE id = 1 LIMIT 1")
    suspend fun get(): UserProfile?

    @Query("SELECT * FROM user_profile WHERE id = 1 LIMIT 1")
    fun observe(): Flow<UserProfile?>
}
