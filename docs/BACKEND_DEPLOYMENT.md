# FinWise PHP Backend & Database Deployment Guide
**Course:** Application Development (Sem 3) &bull; **Institution:** Universiti Teknologi Malaysia (UTM)  
**Backend Technology:** Pure PHP 8.0+ &bull; **Database:** MySQL 5.7+ / 8.0+ / MariaDB  

---

## 1. Backend Architecture

The FinWise backend is developed strictly using **pure PHP** without third-party frameworks or Node.js/JavaScript dependencies. It strictly adheres to:
- **Prepared Statements with PDO:** Complete protection against SQL injection.
- **Secure Password Hashing:** Uses `password_hash($password, PASSWORD_BCRYPT)`.
- **Server-Side OTP Security:** 6-digit cryptographic random code, bcrypt hashed, 10-minute expiry, and strict server timestamp 60-second resend throttling.
- **RESTful JSON Responses:** Clear HTTP status codes (200, 201, 400, 401, 403, 404, 405, 409, 422, 429).

---

## 2. Database Setup

### Step 1: Open MySQL Console or phpMyAdmin
Log into your MySQL server:
```bash
mysql -u root -p
```

### Step 2: Import the Database Schema
Execute the SQL script located in `backend/database/finwise_db.sql`:
```sql
SOURCE /path/to/AIO/backend/database/finwise_db.sql;
```
Or import via phpMyAdmin by selecting **Import** and choosing `finwise_db.sql`.

### Pre-Seeded Default Test Accounts
- **Student Email:** `yeoh.k@graduate.utm.my`
- **Matric ID:** `A23CS0123`
- **Default Password:** `SecretStudentPass99`
- **Verification Status:** Verified (`email_verified = 1`)

---

## 3. Configuration

### Database Credentials (`backend/config/database.php`)
Set environment variables or edit the default fallback credentials in `backend/config/database.php`:
```php
$host     = getenv('DB_HOST') ?: '127.0.0.1';
$port     = getenv('DB_PORT') ?: '3306';
$dbName   = getenv('DB_NAME') ?: 'finwise_db';
$user     = getenv('DB_USER') ?: 'root';
$password = getenv('DB_PASS') !== false ? getenv('DB_PASS') : '';
```

### SMTP Email Dispatch (`backend/config/smtp.php`)
Configure your university SMTP or personal Gmail App Password:
```php
'host'       => getenv('SMTP_HOST') ?: 'smtp.gmail.com',
'port'       => 587,
'encryption' => 'tls',
'username'   => 'your-campus-auth@gmail.com',
'password'   => 'your-app-password',
'from_email' => 'noreply@finwise.campus.utm.my',
'from_name'  => 'FinWise Campus Banking',
'simulate'   => false // Set to true to log OTPs to storage/logs/ without sending real emails
```

> **Testing Tip:** When `simulate` is `true` or credentials are left default, the OTP will be dispatched to `backend/storage/logs/email_deliveries.log` for offline evaluation without requiring external network access!

---

## 4. Running the Backend Server

### Option A: Built-in PHP Development Server (Quickest)
From the repository root directory:
```bash
php -S 0.0.0.0:8000
```
Then in Android `ApiClient.java`, set base URL:
`http://10.0.2.2:8000/backend/api/`

### Option B: XAMPP / WampServer / Apache
Copy or symlink the `AIO` project directory to:
`C:\xampp\htdocs\AIO`
Start the **Apache** and **MySQL** modules from the XAMPP Control Panel.
Endpoint URL will be:
`http://10.0.2.2/AIO/backend/api/`

---

## 5. API Endpoints Specification

| Endpoint | Method | Headers / Auth | Payload Parameters | Purpose |
|---|---|---|---|---|
| `api/register.php` | `POST` | None | `full_name`, `email`, `matric_id`, `password`, `confirm_password` | Register new student, generate OTP, send email. |
| `api/login.php` | `POST` | None | `identifier` (email or matric ID), `password` | Authenticate user, verify credentials, return session token. |
| `api/verify_email.php` | `POST` | None | `email`, `otp`, `purpose` | Verify 6-digit OTP code, activate account. |
| `api/resend_otp.php` | `POST` | None | `email`, `purpose` | Enforce 60s restriction, issue new OTP code. |
| `api/forgot_password.php` | `POST` | None | `action`, `email`, `otp`, `new_password`, `confirm_password` | Request password reset code or update password. |
| `api/dashboard.php` | `GET` | `Bearer <token>` | None | Retrieve user balance, 7-day trends, and recent transactions. |
| `api/dashboard.php` | `POST` | `Bearer <token>` | `action: "quick_transfer_savings" \| "add_transaction"` | Execute student transfer or add transaction. |
| `api/logout.php` | `POST` | `Bearer <token>` | None | Revoke active session token. |

