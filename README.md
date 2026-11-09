# 💰 FinWise – AI-Powered Personal Financial Management Mobile Application
**👥 Group Name:** All In One (AIO)  
**📚 Course:** Application Development (Semester 3)  
**🏫 Institution:** Universiti Teknologi Malaysia (UTM), Skudai Campus  
**📱 Platform:** Native Android Application (Java SDK)  

---

## 👥 Team Members
- **Member 1:** Yeoh Keng Wei ([@kwei05](https://github.com/kwei05))
- **Member 2:** Wong Sheng Yang ([@shengyang19](https://github.com/shengyang19))
- **Member 3:** Ching Qi Yan ([@chingqiyan](https://github.com/chingqiyan))
- **Member 4:** Edwin Oo Ming Hao ([@edwinoo05](https://github.com/edwinoo05))

---

## 📌 Project Overview
**FinWise** is an AI-powered personal financial management Android application designed specifically to empower university students and young adults in managing their income, semester allowance, campus meal spending, and personal savings.

Unlike generic budgeting apps, FinWise integrates a campus financial context (UTM Skudai Campus, Arked meal spending patterns, semester runway forecasts) and an AI Copilot engine to provide actionable, student-tailored insights.

---

## 🛠️ Technology Stack & Strict Language Compliance

| Layer | Language / Technology | Purpose |
|---|---|---|
| **📱 Mobile Client** | **Java (Android SDK Native)** | Native Android UI built **100% programmatically in Java** (Activities, Fragments, RecyclerView, Custom Views). **No WebViews, no JavaScript, no Kotlin, no Flutter.** |
| **⚙️ Backend API** | **PHP 8.0+** | RESTful backend, authentication, PDO prepared statements, password hashing, secure OTP verification, and 60s throttling. |
| **🗄️ Database** | **MySQL 5.7+ / 8.0+ / MariaDB** | Relational data persistence with strict foreign keys and indexes. |
| **📧 Email Delivery** | **HTML & PHP SMTP** | Multipart HTML verification email templates dispatched over SSL/TLS sockets. |
| **🧮 Simulation Module** | **C++ (C++17)** | High-performance financial simulation, semester runway projections, and Monte Carlo algorithms. |

---

## 🏗️ Project Architecture & Repository Structure

```text
AIO/
├── FinWiseAndroid/                  # Complete Native Android Studio Project
│   ├── app/
│   │   ├── build.gradle             # Android build configuration
│   │   ├── proguard-rules.pro
│   │   └── src/main/
│   │       ├── AndroidManifest.xml  # Platform configuration & permissions
│   │       ├── java/com/finwise/app/
│   │       │   ├── activities/      # LoginActivity, RegisterActivity, VerificationActivity,
│   │       │   │                    # ForgotPasswordActivity, MainActivity
│   │       │   ├── fragments/       # HomeFragment, BudgetFragment, InsightsFragment,
│   │       │   │                    # SimulatorFragment, AddTransactionDialogFragment
│   │       │   ├── adapters/        # TransactionAdapter (Programmatic RecyclerView)
│   │       │   ├── models/          # User, Transaction, DashboardData, ApiResponse
│   │       │   ├── network/         # ApiClient (pure Java HttpURLConnection), AuthService, DashboardService
│   │       │   ├── ui/              # ThemeColors, ViewFactory, OutflowTrendBarView, BottomNavBarView
│   │       │   └── utils/           # ValidationUtils, SessionManager, CountdownManager, SecurityUtils
│   │       └── res/values/          # strings.xml, styles.xml
│   ├── build.gradle
│   ├── settings.gradle
│   ├── gradlew.bat
│   └── gradle.properties
│
├── backend/                         # Pure PHP REST Backend
│   ├── api/                         # login.php, register.php, verify_email.php, resend_otp.php,
│   │                                # forgot_password.php, dashboard.php, logout.php
│   ├── config/                      # database.php (PDO), smtp.php (SMTP credentials)
│   ├── database/                    # finwise_db.sql (MySQL schema & seed data)
│   ├── includes/                    # authentication.php, validation.php, email_service.php,
│   │                                # otp_service.php, security.php
│   └── templates/                   # verification_email.html (HTML email template)
│
├── cpp/                             # C++ Financial Calculation & Simulation Engine
│   ├── FinancialSimulator.h         # Simulation interface & data structures
│   └── FinancialSimulator.cpp       # Runway forecasting & compound interest math
│
└── docs/                            # Comprehensive Project Documentation
    ├── ANDROID_SETUP_GUIDE.md       # Android Studio installation & APK build guide
    ├── BACKEND_DEPLOYMENT.md        # PHP backend & MySQL setup guide
    └── TESTING_REPORT.md            # Comprehensive 16-point authentication & UI test report
```

---

## 📱 Implemented Android Application Screens

1. **Screen 1: Login (`LoginActivity.java`)**
   - UTM Portal Sync badge & Semester Allowance card.
   - Dynamic form validation, password show/hide toggle.
   - Remember device preference with 256-bit AES badge.
   - UTM CIDOS SSO & Google Campus login options.
   - Biometric touch ID / face ID integration flow.

2. **Screen 2: Registration (`RegisterActivity.java`)**
   - Full student registration (Full Name, Student Email, Matric ID, Passwords).
   - Validation for duplicate email, password complexity, and confirmation match.
   - Backend dispatch generating 6-digit OTP code.

3. **Screen 3: Email Verification (`VerificationActivity.java`)**
   - 6-digit OTP code validation against server bcrypt hash.
   - Strict 60-second resend restriction enforced via server timestamps and Android Handler.
   - Expiration checking (10-minute validity) and max attempt throttle.

4. **Screen 4: Home Dashboard (`MainActivity.java` & `HomeFragment.java`)**
   - Header with notification modal and student profile dialog with logout.
   - AI Copilot banner with interactive preview.
   - Total Available Balance Bento Hero card with privacy toggle.
   - Smart Spend Alert widget with demonstration quick transfer.
   - 7-Day Outflow Trend interactive bar chart.
   - Recent Transactions RecyclerView with category badges.
   - 5-item native bottom navigation bar.

5. **Screen 5: Forgot Password (`ForgotPasswordActivity.java`)**
   - Email a 6-digit reset code, verify it, and set a new password through the password-reset API.
   - Server-enforced 60-second resend limit with an on-screen countdown.

---

## 🚀 Quick Start Guide

### 1. Backend Setup
1. Import `backend/database/finwise_db.sql` into MySQL.
2. Start the configured development API and mail server:
   ```bash
   powershell -ExecutionPolicy Bypass -File .\backend\start-dev-server.ps1
   ```
   The script securely prompts for your Gmail address, Gmail App Password (hidden input), and MySQL settings. Create an App Password in your Google account first; never put it in source code or send it in chat. The script runs PHP with real SMTP delivery enabled and does not store the credentials. If TLS certificate verification fails on Windows, configure PHP's `openssl.cafile` with a current CA bundle; do not disable certificate verification.

### 2. Android Studio Setup
1. Open the `FinWiseAndroid` folder in Android Studio.
2. In `ApiClient.java`, verify the base URL (`http://10.0.2.2:8000/backend/api/` for emulator).
3. Connect an Android device or start an emulator (API 26+).
4. Click **Run > Run 'app'** or build the APK via `gradlew assembleDebug`.

---

## 📅 Development Roadmap (4 Sprints)

- **✅ Sprint 1 – Android Foundation & Authentication (Completed):**
  - Native Android project setup & programmatic UI framework.
  - Complete Login, Registration, Email Verification, and Forgot Password flows.
  - 60-second OTP resend restriction with timestamp persistence.
  - PHP REST API and MySQL database structure.
  - Full Dashboard layout with balance hero, outflow trend chart, and transactions.
  - C++ simulation module architecture.

- **⏳ Sprint 2 – Financial Management:**
  - Add, edit, delete real-time transactions.
  - Category management & monthly spending limits.
  - Dynamic budget utilization alerts.
  - Savings goal tracker with milestone calculations.

- **⏳ Sprint 3 – AI & Financial Intelligence:**
  - Gemini AI API integration for conversational Copilot.
  - Receipt OCR parser.
  - Spending anomaly detection.
  - JNI bindings connecting C++ `FinancialSimulator` into Android.

- **⏳ Sprint 4 – Integration & Testing:**
  - End-to-end user acceptance testing with UTM students.
  - Performance profiling, security auditing, and release APK signing.
