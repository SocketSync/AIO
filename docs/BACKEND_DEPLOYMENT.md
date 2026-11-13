# 🖥️ FinWise Backend — Deployment & Configuration Guide

This guide documents how to deploy and configure the **FinWise** backend services (Supabase Cloud PostgreSQL + optional PHP/Python local sync server).

---

## 🗄️ 1. Supabase Cloud Database Setup (Primary Production Backend)

1. Open the **Supabase SQL Editor** for your project.
2. Execute `database/schema.sql` to create `public.profiles`, `public.categories`, and `public.transactions`.
3. Execute `database/security_hardening_cia.sql` to enforce Row Level Security (`auth.uid() = user_id`), database `CHECK` constraints, and seed the clean demo user (`demo@finwise-app.xyz`).

---

## ⚙️ 2. Environment Variable Configuration (`.env`)

All sensitive and environment-specific settings are managed via `.env` (which is strictly ignored by Git via `.gitignore`):

```env
APP_URL=https://www.finwise-app.xyz
FINWISE_PUBLIC_URL=https://www.finwise-app.xyz
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-public-anon-key
```

### Optional PHP MySQL & SMTP Environment Variables
`backend/config/database.php` and `backend/config/smtp.php` read credentials exclusively from environment variables (`DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASS`, `SMTP_HOST`, `SMTP_USER`, `SMTP_PASS`) and never hardcode secrets in source code.

---

## 🚀 3. Starting the Development Server

- **Python Real-Time Sync Server**:
  ```bash
  python server.py 3000 public
  ```
- **PHP Backend Server**:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\backend\start-dev-server.ps1
  ```
