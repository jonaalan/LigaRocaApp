import java.util.Properties
import java.io.FileInputStream
import kotlin.io.path.exists

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// --- CONFIGURACIÓN DE LA FIRMA PARA LA TIENDA ---
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // Tu identificador único
    namespace = "chito.liga_roca"

    // REGLA DE ORO: Actualizado a 36 como piden share_plus y url_launcher
    compileSdk = 36

    // Mantenemos la versión del NDK que solucionó el error anterior
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "chito.liga_roca"

        // minSdk 24 es ideal para cubrir el 95% de los teléfonos actuales
        minSdk = 24

        // REGLA DE ORO: targetSdk también en 36 para cumplir con Google Play 2026
        targetSdk = 36

        // ¡OJO! Para subir a la tienda por primera vez usas estos.
        // La próxima vez que actualices la app, subí el versionCode a 2.
        versionCode = 1
        versionName = "1.0.0"

        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = if (keystoreProperties["storeFile"] != null) file(keystoreProperties["storeFile"] as String) else null
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        getByName("release") {
            // Firmamos la app para que la tienda la acepte
            signingConfig = signingConfigs.getByName("release")

            // Estos se quedan en false para evitar problemas en la primera subida
            isMinifyEnabled = false
            isShrinkResources = false

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// Resolución de conflictos de librerías para estabilidad total
configurations.all {
    resolutionStrategy {
        force("androidx.browser:browser:1.8.0")
        force("androidx.core:core:1.13.1")
        force("androidx.core:core-ktx:1.13.1")
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}

flutter {
    source = "../.."
}