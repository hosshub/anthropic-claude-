package com.tayyibat.app.data.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.tayyibat.app.data.model.DailySummary
import com.tayyibat.app.data.model.FastingDay
import com.tayyibat.app.data.model.FoodItem
import com.tayyibat.app.data.model.Meal
import com.tayyibat.app.data.model.NotificationTip
import com.tayyibat.app.data.model.UserProfile

@Database(
    entities = [
        Meal::class,
        FoodItem::class,
        FastingDay::class,
        DailySummary::class,
        NotificationTip::class,
        UserProfile::class,
    ],
    version = 1,
    exportSchema = false,
)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun mealDao(): MealDao
    abstract fun summaryDao(): SummaryDao
    abstract fun fastingDao(): FastingDao
    abstract fun tipDao(): TipDao
    abstract fun profileDao(): ProfileDao

    companion object {
        @Volatile private var instance: AppDatabase? = null

        fun get(context: Context): AppDatabase =
            instance ?: synchronized(this) {
                instance ?: Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "tayyibat.db",
                ).build().also { instance = it }
            }
    }
}
