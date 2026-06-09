# Android shell — first-time setup

Per repo convention (see `flutter_app/README.md`), the native `android/`
directory is **not** committed. Every contributor generates it once. This
doc documents the patches you must apply after that generation so Android
actually works (Google sign-in returns, notifications get the right icon,
Play Store accepts the build, etc.).

## 1. Generate the native scaffold

```bash
cd ~/Code\ Projects/anthropic-claude-/flutter_app
flutter create --platforms=android --org ai.tayyibat .
git add android/
git commit -m "android: scaffold (flutter create)"
```

This brings in `android/app/build.gradle`, `android/app/src/main/AndroidManifest.xml`,
`android/app/src/main/kotlin/.../MainActivity.kt`, gradle wrapper jars, and
the default `themes.xml` / `launch_background.xml`.

## 2. Patch `android/app/src/main/AndroidManifest.xml`

Replace the auto-generated file with this (substitute `XXXXXXXX` with the
Sentry org & project IDs only if you intend to deploy Sentry NDK symbols;
otherwise omit the meta-data block):

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Required for image upload to the analyze proxy + body-followup OAuth. -->
    <uses-permission android:name="android.permission.INTERNET"/>

    <!-- Camera capture. -->
    <uses-permission android:name="android.permission.CAMERA"/>

    <!-- Photo picker (image_picker) on Android 13+. -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>

    <!-- Pre-13 fallback. The maxSdkVersion guard keeps Play Store happy. -->
    <uses-permission
        android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32"/>

    <!-- Local notifications on Android 13+. -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

    <!-- We deliberately use AndroidScheduleMode.inexactAllowWhileIdle so we
         do NOT need SCHEDULE_EXACT_ALARM. -->

    <application
        android:label="Tayyibat"
        android:name="${applicationName}"
        android:icon="@mipmap/launcher_icon"
        android:supportsRtl="true">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme"/>

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>

            <!-- OAuth return: Supabase + Google sign in via the in-app
                 Chrome Custom Tab, which redirects to tayyibat://login-callback.
                 Without this intent filter the user is stranded in the browser
                 after authenticating. -->
            <intent-filter android:autoVerify="false">
                <action android:name="android.intent.action.VIEW"/>
                <category android:name="android.intent.category.DEFAULT"/>
                <category android:name="android.intent.category.BROWSABLE"/>
                <data android:scheme="tayyibat"
                      android:host="login-callback"/>
            </intent-filter>
        </activity>

        <!-- Notification icon: monochrome silhouette on transparent bg.
             See section 4 for the asset. Without this Android shows a
             generic white square on the status bar. -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@drawable/ic_notification"/>
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@color/notification_color"/>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2"/>
    </application>

    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
```

## 3. Update `android/app/build.gradle`

Inside `android { defaultConfig { ... } }`:

```gradle
applicationId "ai.tayyibat.tayyibat"
minSdkVersion 21
compileSdk 35
targetSdkVersion 35
multiDexEnabled true
```

And add a release signing config (after you generate the keystore once):

```gradle
signingConfigs {
    release {
        if (rootProject.file("key.properties").exists()) {
            def keystoreProperties = new Properties()
            keystoreProperties.load(new FileInputStream(rootProject.file("key.properties")))
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

Generate the keystore on your Mac once (key.properties is already in
.gitignore):

```bash
cd ~/Code\ Projects/anthropic-claude-/flutter_app/android
keytool -genkey -v -keystore app/upload-keystore.jks -keyalg RSA \
        -keysize 2048 -validity 10000 -alias upload
```

Then `flutter_app/android/key.properties` (gitignored):

```
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

## 4. Notification icon + color

Create `android/app/src/main/res/drawable/ic_notification.png` — a
**white monochrome silhouette** of the leaf on a transparent background,
exported at 1×/2×/3× into the matching `drawable-mdpi/.../xxxhdpi/`
folders. Android requires monochrome for the status-bar small icon
(colored icons render as a white square).

For the accent color (Android 5+ uses this to tint the notification
icon and dot), create `android/app/src/main/res/values/colors.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="notification_color">#C9A35B</color> <!-- gold -->
</resources>
```

## 5. Notification service: pass the icon explicitly

Already done in `lib/services/notification_service.dart` after this PR:
`AndroidNotificationDetails(..., icon: '@drawable/ic_notification',
color: Color(0xFFC9A35B))` is wired into both the production channels
and the test channel. The Dart code is correct; this section is just a
reminder that the **drawable asset** is what makes it actually render.

## 6. Run launcher_icons

```bash
flutter pub run flutter_launcher_icons
```

This regenerates the adaptive launcher icon under `mipmap-anydpi-v26/`
using the foreground asset already in `assets/icon/icon_foreground.png`
and the emerald background in pubspec.yaml. Commit the regenerated
`android/app/src/main/res/mipmap-*` directories.

## 7. Verify the build

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

AAB lives at `build/app/outputs/bundle/release/app-release.aab`. Upload
that to Play Console.

## 8. First-launch smoke test (real device)

- Install the APK on a physical Android device.
- Tap "Continue with Google" → confirm the Chrome Custom Tab opens,
  authentication succeeds, **and the user returns to the app** (this is
  the deep-link intent filter from step 2 — the most common Android
  regression).
- Settings → Notifications → enable a reminder → wait for the next
  defaultTime → confirm the status-bar icon is the gold-tinted leaf,
  not a white square (step 4 + 5).
- Capture a meal → walk into the result screen → tap the close X → land
  back on Today (cross-platform parity with iOS).
- Switch to English in Settings → confirm error toasts render in
  English (the AppMessage refactor from this PR).

## Play Store target-SDK deadline

Google requires `targetSdk 35` for new submissions since Aug 31 2025
and for app updates since the November 2025 cycle. The `compileSdk 35`
+ `targetSdk 35` in step 3 keeps us ahead of that.
