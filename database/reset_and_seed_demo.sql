-- ==============================================================================
-- FinWise Phase 1: Supabase Database Reset & Clean Demo Account Setup
-- Run this script in the Supabase SQL Editor (https://supabase.com/dashboard)
-- ==============================================================================

-- 1. Enable pgcrypto for password hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 2. Wipe all existing data in public.transactions and public.profiles
TRUNCATE TABLE public.transactions, public.profiles RESTART IDENTITY CASCADE;

-- 3. Delete all existing users from auth.users (and cascading auth.identities / sessions)
DELETE FROM auth.identities;
DELETE FROM auth.users;

-- 4. Ensure public.profiles has clean schema & trigger before seeding demo user
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, display_name, avatar_url, currency, monthly_budget)
    VALUES (
        NEW.id,
        COALESCE(NEW.email, 'demo@finwise-app.xyz'),
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1), 'Demo Finwise'),
        NEW.raw_user_meta_data->>'avatar_url',
        'RM',
        2500.00
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        display_name = COALESCE(EXCLUDED.display_name, public.profiles.display_name),
        avatar_url = COALESCE(EXCLUDED.avatar_url, public.profiles.avatar_url);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- 5. Seed the single clean Demo Account in auth.users:
--    Email:        demo@finwise-app.xyz
--    Display Name: Demo Finwise
--    Password:     FinWise2026!
--    UUID:         00000000-0000-4000-8000-000000000001
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-4000-8000-000000000001',
    'authenticated',
    'authenticated',
    'demo@finwise-app.xyz',
    crypt('FinWise2026!', gen_salt('bf')),
    NOW(),
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    '{"full_name": "Demo Finwise", "name": "Demo Finwise", "demo_password_initialized": true, "has_password_set": true}'::jsonb,
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
);

-- 6. Insert corresponding identity record in auth.identities so Supabase email login works seamlessly
INSERT INTO auth.identities (
    id,
    user_id,
    provider_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
) VALUES (
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000000001',
    jsonb_build_object(
        'sub', '00000000-0000-4000-8000-000000000001',
        'email', 'demo@finwise-app.xyz',
        'email_verified', true,
        'full_name', 'Demo Finwise'
    ),
    'email',
    NOW(),
    NOW(),
    NOW()
);

-- 7. Ensure clean Demo Finwise profile row exists in public.profiles (with no real personal info)
INSERT INTO public.profiles (
    id,
    email,
    display_name,
    avatar_url,
    currency,
    monthly_budget
) VALUES (
    '00000000-0000-4000-8000-000000000001',
    'demo@finwise-app.xyz',
    'Demo Finwise',
    NULL,
    'RM',
    2500.00
)
ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    display_name = EXCLUDED.display_name,
    avatar_url = NULL,
    currency = 'RM',
    monthly_budget = 2500.00;

-- 8. Enable Row Level Security (RLS) & establish unified policy
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

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

CREATE POLICY "Enable all actions for users based on user_id"
ON public.transactions FOR ALL TO authenticated
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Allow demo account operations"
ON public.transactions FOR ALL TO anon
USING (user_id = '00000000-0000-4000-8000-000000000001'::uuid)
WITH CHECK (user_id = '00000000-0000-4000-8000-000000000001'::uuid);

-- 9. Seed Demo Account Transactions (5 realistic transactions assigned to 00000000-0000-4000-8000-000000000001 using gen_random_uuid())
INSERT INTO public.transactions (
  id, user_id, title, amount, type, category_id, category, transaction_date, date, notes
) VALUES
(
  gen_random_uuid(),
  '00000000-0000-4000-8000-000000000001',
  'Monthly Tech Salary',
  4800.00,
  'income',
  'salary',
  'Salary',
  NOW() - INTERVAL '5 days',
  NOW() - INTERVAL '5 days',
  'Monthly direct deposit paycheck'
),
(
  gen_random_uuid(),
  '00000000-0000-4000-8000-000000000001',
  'Village Grocer Weekly',
  142.50,
  'expense',
  'groceries',
  'Groceries',
  NOW() - INTERVAL '3 days',
  NOW() - INTERVAL '3 days',
  'Fresh vegetables, dairy, and organic staples'
),
(
  gen_random_uuid(),
  '00000000-0000-4000-8000-000000000001',
  'Electricity & Water Utilities',
  115.80,
  'expense',
  'bills_utilities',
  'Bills & Utilities',
  NOW() - INTERVAL '2 days',
  NOW() - INTERVAL '2 days',
  'Monthly residential utility payment'
),
(
  gen_random_uuid(),
  '00000000-0000-4000-8000-000000000001',
  'Coffee & Bistro Lunch',
  28.00,
  'expense',
  'food_dining',
  'Food & Dining',
  NOW() - INTERVAL '1 day',
  NOW() - INTERVAL '1 day',
  'Artisanal coffee and sourdough toast'
),
(
  gen_random_uuid(),
  '00000000-0000-4000-8000-000000000001',
  'Touch N Go / Transit Reload',
  50.00,
  'expense',
  'transportation',
  'Transportation',
  NOW(),
  NOW(),
  'MRT transit weekly commute reload'
);

-- 10. Enable Supabase Realtime on public.transactions and public.profiles
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'transactions'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.transactions;
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'profiles'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
    END IF;
END $$;

SELECT 'Supabase Database Reset Complete! Clean demo account (demo@finwise-app.xyz / Demo Finwise) with 5 linked transactions is ready.' AS status;

