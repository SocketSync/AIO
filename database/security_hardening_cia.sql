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

-- Scoped Demo Profile Policy (Read-Only: demo profile cannot be altered or deleted)
DROP POLICY IF EXISTS "Allow demo profile read only" ON public.profiles;
CREATE POLICY "Allow demo profile read only"
ON public.profiles FOR SELECT TO anon, authenticated
USING (id = '00000000-0000-4000-8000-000000000001'::uuid);

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

-- ==============================================================================
-- PHASE 4: DEMO PROTECTION TRIGGER & SUPER SECURE ACCOUNT PURGE RPC
-- ==============================================================================

-- 1. Database Trigger: Strictly Prohibit Altering or Deleting Demo Account Profile
CREATE OR REPLACE FUNCTION public.protect_demo_profile()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE' AND OLD.id = '00000000-0000-4000-8000-000000000001'::uuid) THEN
        RAISE EXCEPTION 'Demo account profile cannot be deleted. The demo account is strictly reserved for testing input and output transactions.';
    END IF;
    IF (TG_OP = 'UPDATE' AND (OLD.id = '00000000-0000-4000-8000-000000000001'::uuid OR NEW.id = '00000000-0000-4000-8000-000000000001'::uuid)) THEN
        RAISE EXCEPTION 'Demo account profile cannot be altered. The demo account is strictly reserved for testing input and output transactions.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_protect_demo_profile ON public.profiles;
CREATE TRIGGER trg_protect_demo_profile
    BEFORE UPDATE OR DELETE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.protect_demo_profile();

-- 2. Super Secure PostgreSQL RPC: Delete User Account & Purge from Supabase
-- Can only be executed by the authenticated owner of the account (auth.uid())
CREATE OR REPLACE FUNCTION public.delete_user_account()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
    current_user_id UUID;
    current_email TEXT;
BEGIN
    current_user_id := auth.uid();
    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required to delete account.';
    END IF;

    -- STRICT SECURITY CHECK: Prohibit deleting the demo account
    IF current_user_id = '00000000-0000-4000-8000-000000000001'::uuid THEN
        RAISE EXCEPTION 'Demo account profile cannot be deleted. The demo account is strictly reserved for testing input and output transactions.';
    END IF;

    SELECT email INTO current_email FROM auth.users WHERE id = current_user_id;
    IF current_email = 'demo@finwise-app.xyz' THEN
        RAISE EXCEPTION 'Demo account profile cannot be deleted. The demo account is strictly reserved for testing input and output transactions.';
    END IF;

    -- 1. Purge all transactions belonging to this user
    DELETE FROM public.transactions WHERE user_id = current_user_id;

    -- 2. Purge user profile
    DELETE FROM public.profiles WHERE id = current_user_id;

    -- 3. Purge user from auth.users (cascades sessions, refresh tokens, identities)
    DELETE FROM auth.users WHERE id = current_user_id;

    RETURN jsonb_build_object(
        'success', true,
        'message', 'User profile, transactions, and authentication record permanently deleted.'
    );
END;
$$;

-- Revoke execute from public and grant strictly to authenticated users
REVOKE EXECUTE ON FUNCTION public.delete_user_account() FROM public;
GRANT EXECUTE ON FUNCTION public.delete_user_account() TO authenticated;

