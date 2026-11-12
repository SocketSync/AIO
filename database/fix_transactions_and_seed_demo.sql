-- ==============================================================================
-- FinWise: Fix Transaction CRUD, RLS Policies & Seed Linked Demo Data
-- Execute this script in your Supabase SQL Editor:
-- https://supabase.com/dashboard/project/vcxxsffdsznmqtpghrss/sql/new
-- ==============================================================================

-- 1. Ensure public.profiles has the Demo Account record (so user_id FK passes)
ALTER TABLE IF EXISTS public.profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;

INSERT INTO public.profiles (id, email, display_name, currency, monthly_budget)
VALUES (
  '00000000-0000-4000-8000-000000000001',
  'demo@finwise-app.xyz',
  'Demo Finwise',
  'RM',
  2500.00
)
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  display_name = EXCLUDED.display_name,
  currency = 'RM',
  monthly_budget = 2500.00,
  updated_at = NOW();

-- 2. Ensure Categories Exist for Foreign Keys
INSERT INTO public.categories (id, name, icon_name, color_hex, type) VALUES
    ('food_dining', 'Food & Dining', 'restaurant', '#FF9800', 'expense'),
    ('transportation', 'Transportation', 'directions_car', '#2196F3', 'expense'),
    ('groceries', 'Groceries', 'shopping_cart', '#4CAF50', 'expense'),
    ('shopping', 'Shopping', 'shopping_bag', '#9C27B0', 'expense'),
    ('entertainment', 'Entertainment', 'sports_esports', '#E91E63', 'expense'),
    ('bills_utilities', 'Bills & Utilities', 'receipt_long', '#F44336', 'expense'),
    ('health_wellness', 'Health & Wellness', 'medical_services', '#009688', 'expense'),
    ('education', 'Education & Self-Care', 'school', '#3F51B5', 'expense'),
    ('salary', 'Salary / Employment', 'payments', '#006C49', 'income'),
    ('freelance', 'Freelance & Side Gig', 'laptop_mac', '#00BCD4', 'income'),
    ('investments', 'Investments & Returns', 'trending_up', '#673AB7', 'income'),
    ('other', 'General / Other', 'category', '#607D8B', 'expense')
ON CONFLICT (id) DO NOTHING;

-- 3. Enhance public.transactions columns (support category and date aliases)
ALTER TABLE public.transactions ADD COLUMN IF NOT EXISTS category VARCHAR(100);
ALTER TABLE public.transactions ADD COLUMN IF NOT EXISTS date TIMESTAMPTZ;
ALTER TABLE public.transactions ALTER COLUMN category_id DROP NOT NULL;
ALTER TABLE public.transactions ALTER COLUMN transaction_date DROP NOT NULL;

-- 4. Enable Row Level Security (RLS), enforce strict policies & DB CHECK constraints
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Profiles RLS Policies (strict owner isolation + scoped demo profile)
DROP POLICY IF EXISTS "Public profiles are readable by all" ON public.profiles;
DROP POLICY IF EXISTS "Profiles are updatable by all" ON public.profiles;
DROP POLICY IF EXISTS "Profiles are insertable by all" ON public.profiles;
DROP POLICY IF EXISTS "Enable all actions for users based on id" ON public.profiles;
DROP POLICY IF EXISTS "Allow demo profile operations" ON public.profiles;

CREATE POLICY "Enable all actions for users based on id"
ON public.profiles FOR ALL TO authenticated
USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

CREATE POLICY "Allow demo profile operations"
ON public.profiles FOR ALL TO anon
USING (id = '00000000-0000-4000-8000-000000000001'::uuid)
WITH CHECK (id = '00000000-0000-4000-8000-000000000001'::uuid);

-- Integrity Constraints on public.transactions
ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS chk_transactions_amount_nonnegative;
ALTER TABLE public.transactions ADD CONSTRAINT chk_transactions_amount_nonnegative
    CHECK (amount >= 0 AND amount <= 1000000000);

ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS chk_transactions_title_nonempty;
ALTER TABLE public.transactions ADD CONSTRAINT chk_transactions_title_nonempty
    CHECK (char_length(trim(title)) >= 1 AND char_length(title) <= 150);

ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS chk_transactions_type_valid;
ALTER TABLE public.transactions ADD CONSTRAINT chk_transactions_type_valid
    CHECK (type::text IN ('income', 'expense'));

-- Drop legacy/conflicting policies
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

-- Unified Policy for Authenticated Users (Google OAuth, Email/Password users)
CREATE POLICY "Enable all actions for users based on user_id"
ON public.transactions FOR ALL TO authenticated
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Seamless Demo Account Policy for public / demo user operations
CREATE POLICY "Allow demo account operations"
ON public.transactions FOR ALL TO anon
USING (user_id = '00000000-0000-4000-8000-000000000001'::uuid)
WITH CHECK (user_id = '00000000-0000-4000-8000-000000000001'::uuid);

-- 5. Seed Demo Account Data (5 realistic transactions assigned to 00000000-0000-4000-8000-000000000001 using gen_random_uuid())
DELETE FROM public.transactions WHERE user_id = '00000000-0000-4000-8000-000000000001';

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

