# قواعد ProGuard للإصدار. الإبقاء على نماذج التسلسل (serialization).
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.**
-keepclassmembers class com.tayyibat.app.data.** { *; }
