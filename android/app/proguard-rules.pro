# قواعد R8/ProGuard لبناء الإصدار.

-keepattributes *Annotation*, InnerClasses, Signature, EnclosingMethod

# ----- kotlinx.serialization -----
# الإبقاء على المُسلسِلات المولَّدة وحقول النماذج القابلة للتسلسل.
-keepclassmembers class **$$serializer { *; }
-keepclasseswithmembers, allowshrinking class * {
    kotlinx.serialization.KSerializer serializer(...);
}
-keep, includedescriptorclasses class com.tayyibat.app.**$$serializer { *; }
-keepclassmembers @kotlinx.serialization.Serializable class com.tayyibat.app.** {
    *** Companion;
    *** INSTANCE;
    kotlinx.serialization.KSerializer serializer(...);
}
-dontnote kotlinx.serialization.**

# ----- نماذج البيانات (DTOs/الكيانات) -----
# الإبقاء على كل حقول حزمة البيانات حتى لا يُعاد تسميتها وتنكسر مطابقة JSON/Room.
-keep class com.tayyibat.app.data.model.** { *; }
-keepclassmembers class com.tayyibat.app.data.** { *; }

# ----- Room -----
-keep class * extends androidx.room.RoomDatabase { *; }
-keep @androidx.room.Entity class * { *; }
-keep @androidx.room.Dao interface * { *; }
-dontwarn androidx.room.paging.**

# ----- التخزين الآمن: Tink (عبر EncryptedSharedPreferences) -----
# يشير Tink إلى تعليقات توضيحية للترجمة فقط غير موجودة وقت التشغيل؛ نتجاهل تحذيراتها.
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-dontwarn javax.annotation.concurrent.**
-keep class com.google.crypto.tink.** { *; }

# ----- متفرقات -----
# Compose و AndroidX يأتيان بقواعد consumer خاصة بهما؛ لا حاجة لإضافات.
-dontwarn org.jetbrains.annotations.**
