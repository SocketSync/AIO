# 📱 FinWise Android — Setup & Build Guide

This guide covers setting up, configuring, building, and running the **FinWise** mobile application in Android Studio.

---

## 🛠️ 1. Prerequisites & System Requirements

- **Android Studio**: Ladybug (2024.2.1) or newer.
- **JDK**: Java 17 (bundled with Android Studio JBR).
- **Android SDK**:
  - **Minimum SDK**: API 26 (Android 8.0 Oreo)
  - **Target / Compile SDK**: API 34 (Android 14)

---

## 📂 2. Opening the Project in Android Studio

1. Launch **Android Studio**.
2. Select **File > Open...** and choose the `FinWiseAndroid` directory inside the project repository.
3. Wait for Gradle Synchronization to finish.

---

## 🌐 3. Configuring the Backend API Connection

Open `FinWiseAndroid/app/src/main/java/com/finwise/app/network/ApiClient.java` to configure the backend URL:

### Option A: Android Emulator
```java
public static final String BASE_URL = "http://10.0.2.2:8000/backend/api/";
```

### Option B: Physical Android Device (Same Wi-Fi Network)
```java
public static final String BASE_URL = "http://YOUR_LOCAL_LAN_IP:8000/backend/api/";
```

---

## ▶️ 4. Running & Building the APK

1. Select your target device or emulator in Android Studio and click **Run 'app'** (`Shift + F10`).
2. Or build via CLI:
   ```bash
   cd FinWiseAndroid
   ./gradlew assembleDebug
   ```
3. To test with the pre-seeded demo account, use `demo@finwise-app.xyz`.
