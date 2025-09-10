import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flow_ai"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "ai.flow.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        val props = Properties()
        val propsFile = rootProject.file("local.properties")
        if (propsFile.exists()) {
            propsFile.inputStream().use { props.load(it) }
        }
        val supabaseUrl: String = props.getProperty("SUPABASE_URL") ?: "https://mesxkddjgnmmlwsxzxgo.supabase.co"
        val supabaseAnon: String = props.getProperty("SUPABASE_ANON_KEY") ?: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1lc3hrZGRqZ25tbWx3c3h6eGdvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3NTgzODQsImV4cCI6MjA3MDMzNDM4NH0.sitPOrrlf6KiIuSDjwz4wezrkm2nR65_Mts4op5Os-c"
        buildConfigField("String", "SUPABASE_URL", "\"$supabaseUrl\"")
        buildConfigField("String", "SUPABASE_ANON_KEY", "\"$supabaseAnon\"")
    }
    
    signingConfigs {
        create("release") {
            val kProps = Properties()
            val kPropsFile = rootProject.file("key.properties")
            if (kPropsFile.exists()) {
                kPropsFile.inputStream().use { kProps.load(it) }
            }
            val keyAliasVal = System.getenv("RELEASE_KEY_ALIAS") ?: kProps.getProperty("keyAlias")
            val keyPasswordVal = System.getenv("RELEASE_KEY_PASSWORD") ?: kProps.getProperty("keyPassword")
            val storePasswordVal = System.getenv("RELEASE_STORE_PASSWORD") ?: kProps.getProperty("storePassword")
            val storeFilePath = System.getenv("RELEASE_STORE_FILE") ?: kProps.getProperty("storeFile")

            if (!storeFilePath.isNullOrBlank()) {
                storeFile = file(storeFilePath)
            }
            if (!keyAliasVal.isNullOrBlank()) {
                keyAlias = keyAliasVal
            }
            if (!keyPasswordVal.isNullOrBlank()) {
                keyPassword = keyPasswordVal
            }
            if (!storePasswordVal.isNullOrBlank()) {
                storePassword = storePasswordVal
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isShrinkResources = true
            isMinifyEnabled = true
        }
        debug {
            resValue("string", "app_name", "FlowAI")
        }
    }

    buildFeatures {
        buildConfig = true
    }
}

dependencies {
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
}
flutter {
    source = "../.."
}

tasks.register<Copy>("copyApksToFlutterOutput") {
    val flutterOutputDir = file("../../build/app/outputs/flutter-apk")
    val apkDir = file("build/outputs/flutter-apk")

    from(apkDir)
    include("*.apk") // include all APKs (split or universal)
    into(flutterOutputDir)

    doFirst {
        if (!apkDir.exists() || apkDir.listFiles()?.isEmpty() != false) {
            throw GradleException("No APKs found in $apkDir. Build the APKs first.")
        }
        flutterOutputDir.mkdirs()
    }
}

// Ensure it runs after assemble tasks
tasks.whenTaskAdded {
    if (name == "assembleDebug" || name == "assembleRelease") {
        finalizedBy("copyApksToFlutterOutput")
    }
}
