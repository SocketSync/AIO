-- ==============================================================================
-- FinWise: Comprehensive Security Audit & CIA Triad Hardening (PostgreSQL / Supabase)
-- Execute this script in your Supabase SQL Editor:
-- https://supabase.com/dashboard/project/vcxxsffdsznmqtpghrss/sql/new
-- ==============================================================================

-- ==============================================================================
-- PHASE 2: CONFIDENTIALITY (Row Level Security & Strict Access Control)
-- ==============================================================================

-- 1. Enable RLS across all public tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- 2. Drop overly permissive legacy policies on public.profiles
DROP POLICY IF EXISTS "Public profiles are readable by owner" ON public.profiles;
DROP POLICY IF EXISTS "Public profiles are readable by all" ON public.profiles;
DROP POLICY IF EXISTS "Profiles are updatable by owner" ON public.profiles;
DROP POLICY IF EXISTS "Profiles are updatable by all" ON public.profiles;
DROP POLICY IF EXISTS "Profiles are insertable by owner" ON public.profiles;
DROP POLICY IF EXISTS "Profiles are insertable by all" ON public.profiles;
DROP POLICY IF EXISTS "Enable all actions for users based on id" ON public.profiles;
DROP POLICY IF EXISTS "Allow demo profile operations" ON public.profiles;

-- Strict Owner-Only Policy for Authenticated Users on public.profiles (auth.uid() = id)
CREATE POLICY "Enable all actions for users based on id"
ON public.profiles FOR ALL TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Scoped Demo Profile Policy (restricted strictly to the single public demo UUID)
CREATE POLICY "Allow demo profile operations"
ON public.profiles FOR ALL TO anon
USING (id = '00000000-0000-4000-8000-000000000001'::uuid)
WITH CHECK (id = '00000000-0000-4000-8000-000000000001'::uuid);

-- 3. Drop overly permissive legacy policies on public.transactions
DROP POLICY IF EXISTS "Enable all actions for users based on user_id" ON public.transactions;
DROP POLICY IF EXISTS "Users can read own transactions" ON public.transactions;
DROP POLICY IF EXISTS "Users can insert own transactions" ON public.transactions;
DROP POLICY IF EXISTS "Users can update own transactions" ON public.transactions;
DROP POLICY IF EXISTS "Users can delete own transactions" ON public.transactions;
DROP POLICY IF EXISTS "Transactions readable by all" ON public.transactions;
DROP POLICY IF EXISTS "Transactions insertable by all" ON public.transactions;
DROP POLICY IF EXISTS "Transactions updatable by all" ON public.transactions;
DROP POLICY IF EXISTS "Transactions deletable by all" ON public.transactions;
DROP POLICY IF EXISTS "Allow demo account operations" ON public.transactions;

-- Strict Owner-Only Policy for Authenticated Users on public.transactions (auth.uid() = user_id)
CREATE POLICY "Enable all actions for users based on user_id"
ON public.transactions FOR ALL TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Scoped Demo Account Policy (restricted strictly to the single public demo UUID)
CREATE POLICY "Allow demo account operations"
ON public.transactions FOR ALL TO anon
USING (user_id = '00000000-0000-4000-8000-000000000001'::uuid)
WITH CHECK (user_id = '00000000-0000-4000-8000-000000000001'::uuid);

-- 4. Read-Only Default Categories Policy
DROP POLICY IF EXISTS "Categories readable by all" ON public.categories;
CREATE POLICY "Categories readable by all"
ON public.categories FOR SELECT
USING (true);

-- ==============================================================================
-- PHASE 3: INTEGRITY (Database-Level Constraints & Validation)
-- ==============================================================================

-- 1. Ensure required columns are NOT NULL
ALTER TABLE public.transactions ALTER COLUMN title SET NOT NULL;
ALTER TABLE public.transactions ALTER COLUMN amount SET NOT NULL;
ALTER TABLE public.transactions ALTER COLUMN type SET NOT NULL;

-- 2. Add strict CHECK constraints on public.transactions
ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS chk_transactions_amount_nonnegative;
ALTER TABLE public.transactions ADD CONSTRAINT chk_transactions_amount_nonnegative
    CHECK (amount >= 0 AND amount <= 1000000000);

ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS chk_transactions_title_nonempty;
ALTER TABLE public.transactions ADD CONSTRAINT chk_transactions_title_nonempty
    CHECK (char_length(trim(title)) >= 1 AND char_length(title) <= 150);

ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS chk_transactions_type_valid;
ALTER TABLE public.transactions ADD CONSTRAINT chk_transactions_type_valid
    CHECK (type::text IN ('income', 'expense'));

-- 3. Add strict CHECK constraints on public.profiles
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS chk_profiles_budget_nonnegative;
ALTER TABLE public.profiles ADD CONSTRAINT chk_profiles_budget_nonnegative
    CHECK (monthly_budget IS NULL OR (monthly_budget >= 0 AND monthly_budget <= 1000000000));

ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS chk_profiles_email_nonempty;
ALTER TABLE public.profiles ADD CONSTRAINT chk_profiles_email_nonempty
    CHECK (char_length(trim(email)) >= 3);
