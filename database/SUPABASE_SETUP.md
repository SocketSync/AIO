# FinWise — Supabase Cloud Database Setup Guide

This guide explains how to connect **FinWise** (both the **Web Portal** and the **Flutter Mobile App**) to **Supabase PostgreSQL** so that user accounts, budgets, categories, and transactions synchronize in real time across all devices.

---

## 1. Create a Free Supabase Project
1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard) and sign in.
2. Click **New Project**.
3. Enter the project details:
   - **Name**: `FinWise`
   - **Database Password**: Choose a strong password and store it securely in a password manager.
   - **Region**: Select the region closest to you (e.g., `Southeast Asia (Singapore)`).
4. Click **Create new project** and wait ~60 seconds for the PostgreSQL database to initialize.

---

## 2. Run the SQL Schema & Security Hardening Scripts
Once your project is ready:
1. In the left sidebar of the Supabase Dashboard, click **SQL Editor** -> **New Query**.
2. Open `database/schema.sql` in this project, copy its contents into the SQL Editor, and click **Run**.
3. Open `database/security_hardening_cia.sql` (and `database/fix_transactions_and_seed_demo.sql`), paste its contents into a new query tab, and click **Run** to enforce Row Level Security (RLS), database integrity constraints, and seed the clean demo account (`demo@finwise-app.xyz`).

---

## 3. Get Your Supabase Project URL & Anon Key
1. In the left sidebar, click **Project Settings (Gear Icon)** -> **API**.
2. Copy the following two values:
   - **Project URL**: `https://xxxxxxxxxxxxxxxxxxxx.supabase.co`
   - **Project API Keys (`anon` `public`)**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
   - *Security Warning*: Never expose the `service_role` secret key in frontend code or `.env` files bundled with mobile/web clients.

---

## 4. Connect FinWise to Your Supabase Project

### A. Environment Variables (`.env`)
Copy `.env.example` to `.env` in the root folder and set:
```env
SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

### B. Web Portal (`public/*.html`)
The web portal automatically connects to Supabase using the public `SUPABASE_URL` and `SUPABASE_ANON_KEY` and subscribes to `postgres_changes` for real-time cross-device updates.

---

## 5. How Data Synchronization & Security Work
1. **Authentication (Confidentiality)**: Users register or log in via Supabase Auth (`signUp`, `signInWithPassword`, or `signInWithOAuth`).
2. **Row Level Security**: PostgreSQL RLS policies strictly enforce `auth.uid() = user_id` on `public.transactions` and `auth.uid() = id` on `public.profiles`.
3. **Data Integrity**: Database `CHECK` constraints enforce positive numeric transaction amounts (`amount > 0`), valid transaction types (`income` or `expense`), and non-empty titles.
