import java.util.Properties // ADD THIS LINE AT THE VERY TOP

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

    signingConfigs {
        create("release") {
            // Load properties from key.properties
            val properties = Properties()
            val propertiesFile = project.rootProject.file("key.properties")
            if (propertiesFile.exists()) {
                propertiesFile.inputStream().use { properties.load(it) }
                storeFile = file(properties.getProperty("storeFile"))
                storePassword = properties.getProperty("storePassword")
                keyAlias = properties.getProperty("keyAlias")
                keyPassword = properties.getProperty("keyPassword")
            } else {
                // Handle case where key.properties is missing (e.g., for CI/CD)
                // You might throw an error or use environment variables
                println("Warning: key.properties not found for release signing. Make sure it's configured for release builds.")
                // Optionally, you can throw an exception here to halt the build if key.properties is mandatory
                // throw GradleException("key.properties not found for release signing.")
            }
        }
    }

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
            // Ensure you are using your custom 'release' signingConfig here.
            // Remove or comment out the 'debug' signingConfig if it's not intended for release.
            // signingConfig = signingConfigs.getByName("debug") // REMOVE OR COMMENT OUT THIS LINE
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.." // Points to your Flutter project root
}