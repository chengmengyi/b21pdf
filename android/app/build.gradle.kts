import java.util.Properties

val signingProperties = Properties().apply {
    val signingFile = rootProject.file("key.properties")
    if (signingFile.exists()) {
        signingFile.inputStream().use(::load)
    }
}

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.b21pdf"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.test.boom"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = signingProperties.getProperty("keyAlias")
            keyPassword = signingProperties.getProperty("keyPassword")
            storeFile = signingProperties.getProperty("storeFile")?.let(::file)
            storePassword = signingProperties.getProperty("storePassword")
            enableV1Signing = true
            enableV2Signing = true
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }

        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
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
    implementation(platform("com.google.firebase:firebase-bom:32.1.1"))
    // AdMob mediation adapters are declared in the app module on purpose.
    // The Flutter plugin already brings Google Mobile Ads SDK 24.9.0 transitively.
    implementation("com.google.ads.mediation:applovin:13.5.1.0")
    implementation("com.google.ads.mediation:facebook:6.21.0.1")
    implementation("com.google.ads.mediation:mintegral:17.0.91.0")
    implementation("com.google.ads.mediation:pangle:7.9.1.1.0")
    implementation("com.google.ads.mediation:vungle:7.7.1.0")
    implementation("com.unity3d.ads:unity-ads:4.16.5")
    implementation("com.google.ads.mediation:unity:4.17.0.0")
    implementation("com.google.ads.mediation:ironsource:9.3.0.1")
}
