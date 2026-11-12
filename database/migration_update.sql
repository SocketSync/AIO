-- ==============================================================================
-- FinWise Database Update & Migration Script
-- Compatible with Supabase / PostgreSQL
-- Run this in the Supabase SQL Editor to update your database schema
-- ==============================================================================

-- 1. Drop strict foreign key constraint if present so Demo Accounts and OAuth accounts can sync freely, and add optional profile columns
ALTER TABLE IF EXISTS public.profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;

ALTER TABLE IF EXISTS public.profiles 
    ADD COLUMN IF NOT EXISTS phone VARCHAR(30),
    ADD COLUMN IF NOT EXISTS occupation VARCHAR(100),
    ADD COLUMN IF NOT EXISTS currency VARCHAR(10) DEFAULT 'RM',
    ADD COLUMN IF NOT EXISTS monthly_budget NUMERIC(12, 2) DEFAULT 2500.00,
    ADD COLUMN IF NOT EXISTS password_hash TEXT;

-- 2. Ensure Categories exist with the 12 modern FinWise categories
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
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    icon_name = EXCLUDED.icon_name,
    color_hex = EXCLUDED.color_hex,
    type = EXCLUDED.type;

-- 3. Update RLS Policies on public.profiles to enable multi-device sync
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public profiles are readable by owner" ON public.profiles;
DROP POLICY IF EXISTS "Public profiles are readable by all" ON public.profiles;
CREATE POLICY "Public profiles are readable by all"
    ON public.profiles FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Profiles are updatable by owner" ON public.profiles;
DROP POLICY IF EXISTS "Profiles are updatable by all" ON public.profiles;
CREATE POLICY "Profiles are updatable by all"
    ON public.profiles FOR UPDATE
    USING (true);

DROP POLICY IF EXISTS "Profiles are insertable by owner" ON public.profiles;
DROP POLICY IF EXISTS "Profiles are insertable by all" ON public.profiles;
CREATE POLICY "Profiles are insertable by all"
    ON public.profiles FOR INSERT
    WITH CHECK (true);

-- 4. Update RLS Policies on public.transactions for multi-device cross-browser access
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own transactions" ON public.transactions;
DROP POLICY IF EXISTS "Transactions readable by all" ON public.transactions;
CREATE POLICY "Transactions readable by all"
    ON public.transactions FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Users can insert own transactions" ON public.transactions;
DROP POLICY IF EXISTS "Transactions insertable by all" ON public.transactions;
CREATE POLICY "Transactions insertable by all"
    ON public.transactions FOR INSERT
    WITH CHECK (true);

DROP POLICY IF EXISTS "Users can update own transactions" ON public.transactions;
DROP POLICY IF EXISTS "Transactions updatable by all" ON public.transactions;
CREATE POLICY "Transactions updatable by all"
    ON public.transactions FOR UPDATE
    USING (true);

DROP POLICY IF EXISTS "Users can delete own transactions" ON public.transactions;
DROP POLICY IF EXISTS "Transactions deletable by all" ON public.transactions;
CREATE POLICY "Transactions deletable by all"
    ON public.transactions FOR DELETE
    USING (true);

-- 5. Update the handle_new_user trigger to save phone & occupation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, display_name, avatar_url, phone, occupation)
    VALUES (
        NEW.id,
        COALESCE(NEW.email, 'user@finwise.app'),
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1), 'FinWise Member'),
        NEW.raw_user_meta_data->>'avatar_url',
        NEW.raw_user_meta_data->>'phone',
        NEW.raw_user_meta_data->>'occupation'
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        display_name = COALESCE(EXCLUDED.display_name, profiles.display_name),
        avatar_url = COALESCE(EXCLUDED.avatar_url, profiles.avatar_url),
        phone = COALESCE(EXCLUDED.phone, profiles.phone),
        occupation = COALESCE(EXCLUDED.occupation, profiles.occupation);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Re-bind trigger to auth.users if not already active
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- 7. Enable Supabase Realtime publication for live cross-device synchronization
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

-- 8. Notify complete
SELECT 'FinWise multi-device database schema successfully updated!' AS status;
