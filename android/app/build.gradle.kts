plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Apply the Google Services plugin here. This must be after the 'com.android.application' plugin.
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.fwitgi_app" // Keep your application's namespace
    compileSdk = flutter.compileSdkVersion // Uses Flutter's compile SDK version
    ndkVersion = "27.0.12077973" // Keep your NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.fwitgi_app" // Your unique application ID
        minSdk = 23 // Set to 23 (Android 6.0 Marshmallow) as required by Firebase
        targetSdk = flutter.targetSdkVersion // Uses Flutter's target SDK version
        versionCode = flutter.versionCode // Uses Flutter's version code
        versionName = flutter.versionName // Uses Flutter's version name
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.." // Points to your Flutter project root
}