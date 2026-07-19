import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: load credentials from android/key.properties (gitignored).
// Absent file → release config is null → release builds will fall back to
// the debug keystore, which is fine for `flutter run --release` on a dev
// machine but rejected by the Play Store. Don't ship without it.
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) load(FileInputStream(f))
}

android {
    namespace = "ai.tayyibat.tayyibat"
    // compileSdk = 36: plugin transitive deps (app_links, image_picker_android,
    // flutter_local_notifications + every androidx-* they pull in) link against
    // SDK 36. compileSdk and targetSdk are independent contracts; keeping
    // targetSdk at 35 means we don't opt in to Android 16 runtime behavior
    // yet (will revisit when the Play Store deadline hits).
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications uses java.time APIs that need
        // backporting to the minSdk 21 floor. Without this the build
        // fails with "core library desugaring is not enabled."
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "ai.tayyibat.tayyibat"
        minSdk = flutter.minSdkVersion               // flutter_local_notifications + image_picker floor
        targetSdk = 35            // Play Store requirement since Aug 2025
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["storeFile"] as String?
            if (storeFilePath != null) {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = file(storeFilePath)
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            // Use the upload keystore when key.properties is present; fall
            // back to debug signing so `flutter run --release` on dev still
            // works without secrets.
            signingConfig = if (keystoreProperties.containsKey("storeFile")) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // We don't enable Proguard/minification yet — the dependency set
            // is small enough that the savings aren't worth the rule churn.
            // Re-evaluate when the app surface grows.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Backports java.time + other Java 8/11 APIs to minSdk 21 so
    // flutter_local_notifications compiles. Required by AGP when
    // isCoreLibraryDesugaringEnabled = true (see compileOptions above).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
