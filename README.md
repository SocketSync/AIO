# AIO (ALL IN ONE)
## Team Members
- Member 1: Yeoh Keng Wei (@kwei05)
- Member 2: Wong Sheng Yang (@shengyang19)
- Member 3: Ching Qi Yan (@chingqiyan)
- Member 4: Edwin Oo Ming Hao (@edwinoo05)

## Contact
- Email: alinone@gmail.com
- Support: GitHub Issues

-----------------------------------------------------------

# 💰 FinWise – AI-Powered Personal Finance Management App
**👥 Group Name:** All In One  
**📚 Course:** Application Development  
**🏫 Institution:** Universiti Teknologi Malaysia (UTM)  
**📱 Platform:** Cross-Platform Mobile Application

-----------------------------------------------------------

## 📌 Project Overview
FinWise is an AI-powered personal financial management mobile application designed to help university students and young working adults manage their income, expenses, budgets, and savings more effectively.

Many young people struggle to understand their spending habits, control unnecessary expenses, and plan their financial goals. Traditional expense-tracking applications mainly focus on recording transactions and displaying financial summaries, requiring users to analyze their financial situations manually.

FinWise addresses these challenges by integrating financial management tools with Artificial Intelligence (AI) to provide meaningful financial insights and smarter planning capabilities.

Users can track daily transactions, manage budgets, monitor savings goals, forecast future cash flow, and simulate hypothetical financial scenarios through a single mobile application.

## 🎯 Project Objectives
1. Develop a secure mobile application with user authentication and financial transaction management.
2. Implement a dynamic budgeting system with spending limits and real-time budget alerts.
3. Integrate an external AI API to generate personalized financial insights based on users' financial data.
4. Develop a cash flow forecasting engine to estimate future income, expenses, and available balances.
5. Build an interactive financial simulator to compare different hypothetical financial scenarios.
6. Improve financial awareness and encourage better financial planning among university students and young adults.

## ✨ Key Features
### 👤 1. User Authentication & Profile Management
- User registration and login.
- Secure authentication with UTM CIDOS SSO, Google SSO, and Biometric authentication.
- Student verification & perks activation (UTM @graduate.utm.my / @utm.my).
- Personal profile management.
- Individual financial data management.

### 💳 2. Transaction Management
- Add, view, edit, and delete financial transactions.
- Categorize income and expenses.
- View transaction history.
- Calculate total income, expenses, and remaining balance.

### 📊 3. Intelligent Budgeting
- Create monthly budgets.
- Set spending limits for different categories.
- Monitor spending progress.
- Receive alerts when approaching or exceeding budget limits.
- View budget utilization through visual charts.

### 🤖 4. AI-Powered Financial Insights
- Analyze users' spending patterns.
- Identify categories with high expenditure.
- Generate personalized budgeting suggestions.
- Provide understandable explanations of financial summaries.
- Deliver recommendations based on verified financial data.

### 🎯 5. Savings Goal Planning
- Create personalized savings goals.
- Set target amounts and deadlines.
- Track savings progress.
- Calculate required monthly savings.
- Monitor progress towards financial targets.

### 🔮 6. Cash Flow Forecasting
- Analyze historical income and expenses.
- Consider known recurring transactions.
- Estimate future financial balances.
- Visualize projected cash flow trends.
- Identify potential future budget shortages.

### 🧮 7. Financial Scenario Simulation
- Simulate hypothetical changes in income and expenses.
- Compare different spending scenarios.
- Estimate the impact of financial decisions on future balances.
- Visualize differences between current and simulated financial situations.

## 🛠️ Technology Stack
| Component | Technology |
|---|---|
| 📱 Mobile UI | HTML5, CSS3 (Pure Mobile Layout) |
| ⚙️ Backend & Auth | PHP, Java, C++ |
| 🗄️ Database | Cloud Database / MySQL |
| 🤖 AI Integration | External AI API |
| 🔧 Version Control | Git |
| ☁️ Code Repository | GitHub |
| 📋 Project Management | Jira |
| 🔄 Methodology | Agile Development |
| 🧪 Testing | Functional & Integration Testing |

## 💻 Pure Mobile App UI & Implementation

The FinWise project implements a pure mobile app interface containing **only the Login and Register pages**, developed using neat, clean **HTML, CSS, PHP, Java, and C++** with zero heavy frameworks or complex build tools.

### 📱 Pages & Features
- **FinWise - Login (`login.html` / `login.php`)**:
  - Pure mobile layout view.
  - Student Email / Matric ID input with UTM verified status badge.
  - Password input with peek visibility toggle and forgot password trigger.
  - Remember device checkbox and 256-bit AES security badge.
  - Interactive login and Touch ID / Face ID biometric simulation buttons.
  - UTM CIDOS SSO and Google Campus G-Suite quick access.
  - Recent campus savings activity pill for Kolej Tuanku Canselor.
  - One-click navigation to Register.
- **FinWise - Register (`register.html` / `register.php`)**:
  - Student Onboarding Step 1 of 2 with progress indicator.
  - UTM Student Benefit delight card (FinWise Pro & AI Assistant).
  - Institution selector (Universiti Teknologi Malaysia Skudai & KL).
  - Full Name & Student Email inputs with Instant Perks badge.
  - Live interactive password security strength meter (8+ chars, number, special symbol).
  - Terms of Service & student verification agreement.
  - UTM SSO and Google login buttons.
  - One-click navigation to Login.

### 🚀 How to View and Run

#### 1. Open Directly in Any Browser (Zero Installation)
Simply double-click or open:
- `login.html`
- `register.html`

#### 2. Run with PHP (Built-in or XAMPP)
```bash
# Run with PHP built-in server
php -S localhost:8000
```
Then navigate to `http://localhost:8000/login.php` in your browser.

#### 3. Java Authentication Service (Optional Testing)
```bash
javac java/User.java java/AuthService.java
java -cp java AuthService
```

#### 4. C++ Authentication Engine (Optional Testing)
```bash
g++ -o auth cpp/auth.cpp
./auth
```

## 🏗️ System Architecture

FinWise follows a client-server architecture integrated with an external AI service.

```text
       📱 Mobile Application
                |
                v
        ⚙️ Backend Server
                |
        +-------+-------+
        |               |
        v               v
   🗄️ Cloud         🤖 External
    Database           AI API
        |               |
        v               v
   User Data        AI Insights
   Transactions     Recommendations
   Budgets
   Savings Goals
```

The mobile application communicates with the backend server to process user requests and retrieve financial information. The backend manages financial calculations, database operations, and AI API communication.

## 📅 Project Management
FinWise adopts the Agile development methodology to organize development activities into manageable iterations.

The team uses:
- 📋 **Jira:** Sprint planning, task assignments, backlog management, and progress tracking.
- 🔧 **Git:** Source code version control.
- ☁️ **GitHub:** Code collaboration, repository management, and documentation.
- 🔄 **Agile Sprints:** Incremental development, testing, and continuous improvement.

The project is planned around four development sprints, with each sprint focusing on specific application modules and system integration.

## 🧪 Testing Strategy
| Testing Type | Purpose |
|---|---|
| Functional Testing | Verify that each feature works as expected. |
| Authentication Testing | Verify registration, login, and access control. |
| Integration Testing | Ensure mobile app, backend, database, and AI API communicate correctly. |
| Calculation Testing | Verify budget calculations, savings targets, and cash flow forecasts. |
| AI Response Testing | Evaluate the relevance and accuracy of AI-generated explanations. |
| User Acceptance Testing | Collect feedback from UTM students and improve usability. |

## 🌱 Community Engagement
FinWise targets university students and young adults, particularly the student community at Universiti Teknologi Malaysia (UTM).

The team plans to conduct beta testing and collect feedback from students to understand their financial management challenges.

Feedback will be used to improve the application's usability, budgeting functions, and AI-generated financial insights.

## 🔮 Future Improvements
- 🔗 Automated transaction importing through supported financial integrations.
- 🎯 Personalized financial goal recommendations.
- 📈 Advanced spending pattern detection.
- 📑 Customizable financial reports.
- 🔍 Improved forecasting using historical financial data.
- 🌍 Multi-currency support.
- 📊 Enhanced financial data visualization.

## ⚠️ Disclaimer
FinWise is an academic application development project intended for educational and personal financial management purposes.
AI-generated insights are provided for general financial awareness and planning. They should not be treated as professional financial advice.
