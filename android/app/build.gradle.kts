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

// Release credentials are supplied by CI or each release manager and never
// committed. A release without both these credentials and a Maps key must not
// quietly become a debug-signed build with non-functional maps.
val signingPropertiesFile = rootProject.file("key.properties")
val signingProperties = Properties().apply {
    if (signingPropertiesFile.exists()) {
        signingPropertiesFile.inputStream().use { load(it) }
    }
}
val isReleaseBuild = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true) || it.contains("bundle", ignoreCase = true)
}

if (isReleaseBuild && !signingPropertiesFile.exists()) {
    throw GradleException("Release signing is not configured. Add android/key.properties.")
}
if (isReleaseBuild && googleMapsAndroidKey.isBlank()) {
    throw GradleException("GOOGLE_MAPS_ANDROID_KEY must be set for a release build.")
}

android {
    namespace = "uk.co.saintslink.saints_link"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
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

    signingConfigs {
        if (signingPropertiesFile.exists()) {
            create("release") {
                keyAlias = signingProperties.getProperty("keyAlias")
                keyPassword = signingProperties.getProperty("keyPassword")
                storeFile = file(signingProperties.getProperty("storeFile"))
                storePassword = signingProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
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
