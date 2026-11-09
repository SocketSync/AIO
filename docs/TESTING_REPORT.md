# FinWise Application Testing Report
**Course:** Application Development (Sem 3) &bull; **Institution:** Universiti Teknologi Malaysia (UTM)  
**Date:** November 2026 &bull; **Version:** 1.0.0 &bull; **Sprint:** Sprint 1  

---

## 1. Executive Summary

This testing report documents the verification and validation of the native Java Android application and PHP REST backend for FinWise. All 16 mandatory authentication test cases, UI responsiveness benchmarks, and programmatic Android components have been evaluated.

---

## 2. Authentication Test Cases (16/16 Passed)

| Test ID | Test Scenario | Input Data | Expected Result | Actual Result | Status |
|---|---|---|---|---|---|
| **TC-AUTH-01** | Valid Registration | Name: "Yeoh Keng Wei", Email: "yeoh.k@graduate.utm.my", Pass: "SecretPass123" | User created with `email_verified=0`, 6-digit OTP generated and dispatched via HTML email, navigation to `VerificationActivity`. | Returned HTTP 201, dispatched email, redirected to verification screen. | **PASS** |
| **TC-AUTH-02** | Invalid Email Format | Name: "Wong Sheng Yang", Email: "not-an-email", Pass: "Password123" | Client & server validation error: "Invalid email address." Registration halted. | Validation prevented submission; error toasted. | **PASS** |
| **TC-AUTH-03** | Duplicate Email | Email: "yeoh.k@graduate.utm.my" (already registered & verified) | Server returns HTTP 409: "Email already registered." | Received HTTP 409 error response with appropriate message. | **PASS** |
| **TC-AUTH-04** | Password Mismatch | Password: "Password123", Confirm: "Password456" | Validation error: "Passwords do not match." Form rejected. | Blocked prior to submission with focus on confirm field. | **PASS** |
| **TC-AUTH-05** | Successful Email Delivery | Registered valid student email | SMTP client sends MIME HTML template with 6-digit code. | Socket TLS communication completed with SMTP 250 response / logged in simulation storage. | **PASS** |
| **TC-AUTH-06** | Incorrect OTP | Submitted OTP: "000000" (Expected: "654321") | Backend rejects hash match, increments `attempts`, returns HTTP 400: "Invalid verification code. Please try again." | Error toasted; code cleared for retry. | **PASS** |
| **TC-AUTH-07** | Expired OTP | Submitted valid OTP code after 10 minutes | Server checks `expires_at < NOW()`, returns HTTP 400: "Verification code has expired." | Expired error received. User prompted to resend. | **PASS** |
| **TC-AUTH-08** | Correct OTP | Submitted matching 6-digit OTP code | Server verifies hash, updates `users.email_verified=1`, generates auth token, navigates to Dashboard. | User verified; session created; navigated to `MainActivity`. | **PASS** |
| **TC-AUTH-09** | Login Before Verification | Credentials of registered user with `email_verified=0` | Server returns HTTP 403: "Please verify your email before logging in." Client directs user to `VerificationActivity`. | Received HTTP 403; opened verification activity with email pre-filled. | **PASS** |
| **TC-AUTH-10** | Incorrect Password | Valid email, wrong password | Server returns HTTP 401: "Incorrect email or password." No sensitive details leaked. | Received HTTP 401 with generic error message. | **PASS** |
| **TC-AUTH-11** | Successful Login | Valid email & password | Server returns HTTP 200 with Bearer auth token and user profile; stored in `SessionManager`. | Authenticated session established; opened Dashboard. | **PASS** |
| **TC-AUTH-12** | Resend Before 60 Seconds | User attempts resend code at 35 seconds | Both Android UI disables button and PHP backend compares `last_sent_at` timestamp. Server rejects with HTTP 429 and remaining seconds. | Strict restriction enforced on server and client. | **PASS** |
| **TC-AUTH-13** | Resend After 60 Seconds | User clicks Resend after 60-second countdown | Old OTP invalidated, new OTP generated, new 10-minute expiry set, countdown restarts at 00:60. | New email dispatched; countdown reset. | **PASS** |
| **TC-AUTH-14** | App Restart During Countdown | Close / kill app with 42s remaining on timer, re-open `VerificationActivity` | `CountdownManager` computes remaining time from persisted timestamp: `expiry - currentTimeMillis()`. Countdown resumes at ~40s without reset to 60. | Countdown accurately resumed without timer evasion. | **PASS** |
| **TC-AUTH-15** | Logout | Click User Avatar > Log Out | Server invalidates session token in DB; client clears `SessionManager` preferences and redirects to `LoginActivity`. | Session cleared; back stack purged. | **PASS** |
| **TC-AUTH-16** | Access Dashboard Without Authentication | Launch `MainActivity` with empty or expired session | `MainActivity.onCreate()` detects `!sessionManager.isLoggedIn()`, redirects to `LoginActivity`, finishes `MainActivity`. | Unauthorized access blocked. | **PASS** |

---

## 3. UI and Mobile Usability Test Cases

| Component / Flow | Test Scenario | Observation | Result |
|---|---|---|---|
| **Login Layout** | Check layout rendering on diverse screen densities (hdpi to xxhdpi) | Programmatic DP scaling via `ViewFactory.dp()` guarantees pixel-perfect layout and touch target compliance (>48dp). | **PASS** |
| **Registration Layout** | Form fields alignment, scrolling with software keyboard visible | Handled via `ScrollView` with `windowSoftInputMode="adjustResize"`; no views obscured by soft keyboard. | **PASS** |
| **Email Verification** | Monospace 6-digit OTP box input | Big font size (26sp), centered, restricts input to digits only with max length 6. | **PASS** |
| **Bento Hero Card** | Balance privacy toggle | Clicking the eye icon toggles between `RM 3,420.50` and `••••••••` instantaneously without reloading data. | **PASS** |
| **7-Day Outflow Trend** | Visual bar chart heights & peak highlight | Saturday is highlighted in Coral (peak), Sunday is highlighted in Navy Blue (today), bars scale proportionally. | **PASS** |
| **Recent Transactions** | RecyclerView list rendering | Transaction rows display category icons, formatted date/time, and colored +/- amounts accurately. | **PASS** |
| **Bottom Navigation** | 5-item bottom bar switching | Seamlessly transitions across Home, Budgets, Insights, and Simulator tabs; center `+` button opens `AddTransactionDialogFragment`. | **PASS** |
| **Android Back Button** | Pressing back on secondary tab vs home | Secondary tabs navigate back to Home; pressing back on Home exits the app cleanly. | **PASS** |

