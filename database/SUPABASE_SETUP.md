# FinWise - Supabase Database Integration Guide

## 1. Overview
FinWise uses **Supabase (PostgreSQL)** as its cloud database and authentication backend.
The integration includes:
- **`profiles` Table**: User profile data (`display_name`, `email`, `phone`, `occupation`, `avatar_url`), custom currency, and monthly budget limits.
- **`categories` Table**: System and custom transaction categories with icons and colors.
- **`transactions` Table**: Full CRUD support for daily financial records (Amount, Type, Category, Date, Notes).
- **Row Level Security (RLS)**: Enforces strict user isolation so users can only view, create, edit, and delete their own financial records.
- **Automatic Triggers**: Automatically updates `updated_at` timestamps and creates user profile entries when signing in with Google.
- **Migration Script**: Run [`database/migration_update.sql`](file:///c:/Users/ykeng/Desktop/y3s1/AIO/database/migration_update.sql) to add new fields (`phone`, `occupation`) to an existing database.

---

## 2. Quick Setup Steps (3 Minutes)

### Step 1: Create a Supabase Project
1. Go to [https://supabase.com](https://supabase.com) and sign in.
2. Click **New Project** and choose your preferred database region (e.g. `Singapore` or closest to you).
3. Set a database password and click **Create new project**.

### Step 2: Deploy the Database Schema
1. In your Supabase dashboard, click **SQL Editor** from the left sidebar.
2. Click **New Query**.
3. Copy the entire contents of [`database/schema.sql`](file:///c:/Users/ykeng/Desktop/y3s1/AIO/database/schema.sql) and paste it into the editor.
4. Click **Run** (green button).
   - This creates all tables (`profiles`, `categories`, `transactions`), seeds the 12 default categories, sets up Row Level Security (RLS), and registers the auto-profile triggers.

### Step 3: Add Credentials to `.env`
1. In your Supabase dashboard, go to **Project Settings** (gear icon) > **API**.
2. Copy:
   - **Project URL** (e.g., `https://vcxxsffdsznmqtpghrss.supabase.co`)
   - **Project API keys** > **`anon` / `public` key**
3. Open the [`.env`](file:///c:/Users/ykeng/Desktop/y3s1/AIO/.env) file in your project root and paste them:
   ```env
   SUPABASE_URL=https://vcxxsffdsznmqtpghrss.supabase.co
   SUPABASE_ANON_KEY=your-actual-anon-key-here
   ```

---

## 3. Google Sign-In Setup in Supabase (1 Minute)

To enable the official **Google popup sign-in** (`accounts.google.com`) with Supabase:

1. **In Google Cloud Console**:
   - Go to [Google Cloud Console Credentials](https://console.cloud.google.com/apis/credentials).
   - Create an **OAuth 2.0 Client ID** (Application type: **Web application**).
   - Add **Authorized redirect URI**:
     ```
     https://vcxxsffdsznmqtpghrss.supabase.co/auth/v1/callback
     ```
   - Copy your **Client ID** and **Client Secret**.

2. **In Supabase Dashboard**:
   - Navigate to **Authentication** > **Providers** > **Google**.
   - Switch the toggle to **ON** (Enabled).
   - Paste your **Client ID** and **Client Secret**.
   - Click **Save**.

3. **Production Domain & Redirect URLs (finwise-app.xyz)**:
   - In Supabase Dashboard, navigate to **Authentication** > **URL Configuration**.
   - Set **Site URL**: `https://www.finwise-app.xyz`
   - Under **Redirect URLs**, add:
     - `https://www.finwise-app.xyz/**`
     - `https://www.finwise-app.xyz/login`
     - `https://www.finwise-app.xyz/dashboard`
   - In Google Cloud Console Credentials, ensure Authorized JavaScript origins include:
     - `https://www.finwise-app.xyz`
     - `https://finwise-app.xyz`

4. **Instant Development & Testing Fallback**:
   - If Google OAuth has not been toggled on yet in Supabase, clicking **Continue with Google** opens the **Google Account Fetcher**.
   - Enter your personal Gmail address (e.g. `your.name@gmail.com`).
   - FinWise will automatically extract your name, avatar, generate a user UUID, create a verified session, and sync to Supabase.

---

## 4. Architecture & Code Integration

* **Client Service**: [`lib/services/supabase_service.dart`](file:///c:/Users/ykeng/Desktop/y3s1/AIO/lib/services/supabase_service.dart) initializes the Supabase client when valid credentials exist in `.env`.
* **Database CRUD Operations**: [`lib/services/database_service.dart`](file:///c:/Users/ykeng/Desktop/y3s1/AIO/lib/services/database_service.dart) automatically uses live Supabase PostgREST for all `createTransaction`, `getTransactions`, `updateTransaction`, `deleteTransaction`, and `updateMonthlyBudget` operations, falling back gracefully to high-speed local cache whenever offline.
* **Authentication Service**: [`lib/services/auth_service.dart`](file:///c:/Users/ykeng/Desktop/y3s1/AIO/lib/services/auth_service.dart) handles Google Sign-In, Supabase OAuth state changes, and session management.
* **SQL Schema**: [`database/schema.sql`](file:///c:/Users/ykeng/Desktop/y3s1/AIO/database/schema.sql).
