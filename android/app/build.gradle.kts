import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// The Maps SDK for Android key. It ships inside the APK, so it is restricted
// in the Google console to this package and its signing certificates and to
// that one API — a copy lifted out of the binary can do nothing else with it.
// Each developer keeps theirs in local.properties (ignored); CI supplies an
// environment variable. Server credentials are never read or bundled.
val mapsLocalProperties = Properties().apply {
    val file = rootProject.file("local.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val googleMapsAndroidKey = mapsLocalProperties.getProperty("googleMapsAndroidKey")
    ?: System.getenv("GOOGLE_MAPS_ANDROID_KEY").orEmpty()

android {
    namespace = "uk.co.saintslink.saints_link"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "uk.co.saintslink.app"
        manifestPlaceholders["googleMapsAndroidKey"] = googleMapsAndroidKey
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // flutter_stripe needs 21+; the payment sheet itself is built against 23.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
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
    // Theme parent for the Stripe payment sheet activities.
    implementation("com.google.android.material:material:1.12.0")
}
