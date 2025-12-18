plugins {
  id("com.android.application") version "8.2.2"
  id("org.jetbrains.kotlin.android") version "1.9.22"
}

android {
  namespace = "com.bagbot.manager"
  compileSdk = 34

  defaultConfig {
    applicationId = "com.bagbot.manager"
    minSdk = 24
    targetSdk = 34
    // CI passes these via -PVERSION_CODE / -PVERSION_NAME
    val vc = (project.findProperty("VERSION_CODE") as String?)?.toIntOrNull() ?: 1
    val vn = (project.findProperty("VERSION_NAME") as String?) ?: "dev"
    versionCode = vc
    versionName = vn
  }

  signingConfigs {
    create("release") {
      val ksPath = System.getenv("ANDROID_KEYSTORE_PATH")
      val ksPassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
      val keyAlias = System.getenv("ANDROID_KEY_ALIAS")
      val keyPassword = System.getenv("ANDROID_KEY_PASSWORD")

      if (!ksPath.isNullOrBlank()) storeFile = file(ksPath)
      if (!ksPassword.isNullOrBlank()) storePassword = ksPassword
      if (!keyAlias.isNullOrBlank()) this.keyAlias = keyAlias
      if (!keyPassword.isNullOrBlank()) this.keyPassword = keyPassword
    }
  }

  buildTypes {
    release {
      isMinifyEnabled = false
      // For Play/update installs you need a stable signing key (configured via env in CI).
      signingConfig = signingConfigs.getByName("release")
      proguardFiles(
        getDefaultProguardFile("proguard-android-optimize.txt"),
        "proguard-rules.pro"
      )
    }
    debug {
      isMinifyEnabled = false
    }
  }

  buildFeatures {
    compose = true
  }
  composeOptions {
    kotlinCompilerExtensionVersion = "1.5.8"
  }

  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
  }

  kotlinOptions {
    jvmTarget = "17"
  }

  packaging {
    resources {
      excludes += setOf(
        "META-INF/DEPENDENCIES",
        "META-INF/LICENSE",
        "META-INF/LICENSE.txt",
        "META-INF/NOTICE",
        "META-INF/NOTICE.txt"
      )
    }
  }
}

dependencies {
  val composeBom = platform("androidx.compose:compose-bom:2024.02.02")
  implementation(composeBom)
  androidTestImplementation(composeBom)

  implementation("androidx.core:core-ktx:1.13.1")
  implementation("androidx.activity:activity-compose:1.9.2")
  implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.6")
  implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.6")
  implementation("androidx.navigation:navigation-compose:2.8.3")

  implementation("androidx.compose.ui:ui")
  implementation("androidx.compose.ui:ui-tooling-preview")
  implementation("androidx.compose.material3:material3")
  debugImplementation("androidx.compose.ui:ui-tooling")
  implementation("androidx.compose.material:material-icons-extended")

  // Networking
  implementation("com.squareup.okhttp3:okhttp:4.12.0")

  // JSON
  implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.3")
}

