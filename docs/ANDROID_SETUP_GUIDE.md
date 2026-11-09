# FinWise Android Native Application Setup Guide
**Course:** Application Development (Sem 3) &bull; **Institution:** Universiti Teknologi Malaysia (UTM)  
**Package:** `com.finwise.app` &bull; **Language:** Java 8+ / 17  

---

## 1. Architectural Principles & Strict Guidelines

As mandated by project specifications:
- **Language:** **100% Java** (Native Android SDK).
- **No WebViews:** All user interfaces are dynamically constructed **programmatically using native Android Java components** (`android.widget.*`, `android.view.*`, `androidx.cardview.*`, `androidx.recyclerview.*`) rather than relying on HTML or WebView wrappers.
- **No Prohibited Technologies:** Zero JavaScript, TypeScript, Python, Kotlin, Node.js, React, or Flutter.
- **Platform Configuration:** XML is strictly limited to mandatory configuration (`AndroidManifest.xml`, `strings.xml`, `styles.xml`).

---

## 2. Directory Structure

```text
FinWiseAndroid/
├── app/
│   ├── build.gradle
│   ├── proguard-rules.pro
│   └── src/
│       └── main/
│           ├── AndroidManifest.xml
│           ├── java/
│           │   └── com/finwise/app/
│           │       ├── activities/
│           │       │   ├── LoginActivity.java
│           │       │   ├── RegisterActivity.java
│           │       │   ├── VerificationActivity.java
│           │       │   ├── ForgotPasswordActivity.java
│           │       │   └── MainActivity.java
│           │       ├── fragments/
│           │       │   ├── HomeFragment.java
│           │       │   ├── BudgetFragment.java
│           │       │   ├── InsightsFragment.java
│           │       │   ├── SimulatorFragment.java
│           │       │   └── AddTransactionDialogFragment.java
│           │       ├── adapters/
│           │       │   └── TransactionAdapter.java
│           │       ├── models/
│           │       │   ├── User.java
│           │       │   ├── Transaction.java
│           │       │   ├── DashboardData.java
│           │       │   └── ApiResponse.java
│           │       ├── network/
│           │       │   ├── ApiClient.java
│           │       │   ├── AuthService.java
│           │       │   └── DashboardService.java
│           │       ├── ui/
│           │       │   ├── ThemeColors.java
│           │       │   ├── ViewFactory.java
│           │       │   ├── OutflowTrendBarView.java
│           │       │   └── BottomNavBarView.java
│           │       └── utils/
│           │           ├── ValidationUtils.java
│           │           ├── SessionManager.java
│           │           ├── CountdownManager.java
│           │           └── SecurityUtils.java
│           └── res/
│               └── values/
│                   ├── strings.xml
│                   └── styles.xml
├── build.gradle
├── settings.gradle
└── gradle.properties
```

---

## 3. How to Open and Build in Android Studio

### Prerequisites
1. **Android Studio:** Hedgehog (2023.1.1) or newer / Ladybug (2024.2+).
2. **JDK:** Java 11 or Java 17 (bundled with Android Studio).
3. **Android SDK:** Platform 34 (Android 14) installed via SDK Manager.
4. **Android Device / Emulator:** API Level 26 (Android 8.0 Oreo) or newer.

### Opening the Project
1. Launch Android Studio.
2. Select **File > Open...**
3. Navigate to and select the `FinWiseAndroid` directory inside the repository.
4. Click **OK** to initiate Gradle sync.

### Configuring Backend Endpoint
In `com.finwise.app.network.ApiClient.java`:
```java
// Default emulator access to host machine localhost:
private static String baseUrl = "http://10.0.2.2/AIO/backend/api/";

// When testing on a physical Android phone on the same Wi-Fi network:
// ApiClient.setBaseUrl("http://192.168.1.xxx/AIO/backend/api/");
```

### Building the APK
- In Android Studio, go to **Build > Build Bundle(s) / APK(s) > Build APK(s)**.
- Or via terminal:
  ```bash
  cd FinWiseAndroid
  gradlew assembleDebug
  ```
- Output location:
  `FinWiseAndroid/app/build/outputs/apk/debug/app-debug.apk`

---

## 4. Native Screen Implementations

| Screen | Java Class | Key Features |
|---|---|---|
| **Screen 1: Login** | `LoginActivity.java` | FinWise branding, UTM verified badge, Semester Allowance card, password toggle, 256-bit AES badge, SSO notices, server authentication. |
| **Screen 2: Registration** | `RegisterActivity.java` | Full name, student email, matric ID, password validation, confirmation match, server registration dispatch. |
| **Screen 3: Verification** | `VerificationActivity.java` | 6-digit OTP box, 60s countdown timer with restart persistence, server timestamp verification, resend throttle. |
| **Screen 4: Dashboard** | `MainActivity.java` & `HomeFragment.java` | Bento balance card, privacy toggle, 7-day outflow trend bar chart, recent transactions RecyclerView, 5-item bottom bar. |
| **Screen 5: Forgot Password** | `ForgotPasswordActivity.java` | Two-stage password recovery (request 6-digit code, submit new password with OTP). |

