-- ==============================================================================
-- FinWise Mobile Application - Database Schema (PostgreSQL / Supabase)
-- Sprint 1: User Profiles, Categorized Transactions, and Security Policies (RLS)
-- ==============================================================================

-- 1. Create Enums
DO $$ BEGIN
    CREATE TYPE transaction_type AS ENUM ('income', 'expense');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    avatar_url TEXT,
    phone VARCHAR(30),
    occupation VARCHAR(100),
    currency VARCHAR(10) DEFAULT 'RM',
    monthly_budget NUMERIC(12, 2) DEFAULT 2500.00,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Migration safety: ensure phone and occupation exist if table was already created
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone VARCHAR(30);
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS occupation VARCHAR(100);
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS currency VARCHAR(10) DEFAULT 'RM';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS monthly_budget NUMERIC(12, 2) DEFAULT 2500.00;

-- 3. Categories Table
CREATE TABLE IF NOT EXISTS public.categories (
    id VARCHAR(50) PRIMARY KEY,
    name TEXT NOT NULL,
    icon_name TEXT NOT NULL,
    color_hex VARCHAR(10) NOT NULL,
    type transaction_type NOT NULL DEFAULT 'expense',
    is_default BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed Default Categories
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

-- 4. Transactions Table
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    type transaction_type NOT NULL,
    category_id VARCHAR(50) NOT NULL REFERENCES public.categories(id),
    transaction_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Indexes for Query Performance
CREATE INDEX IF NOT EXISTS idx_transactions_user_date ON public.transactions(user_id, transaction_date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_user_category ON public.transactions(user_id, category_id);

-- 6. Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- 7. RLS Policies for Profiles
DROP POLICY IF EXISTS "Public profiles are readable by owner" ON public.profiles;
CREATE POLICY "Public profiles are readable by owner"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "Profiles are updatable by owner" ON public.profiles;
CREATE POLICY "Profiles are updatable by owner"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "Profiles are insertable by owner" ON public.profiles;
CREATE POLICY "Profiles are insertable by owner"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- 8. RLS Policies for Categories (Default categories readable by all users)
DROP POLICY IF EXISTS "Categories readable by all" ON public.categories;
CREATE POLICY "Categories readable by all"
    ON public.categories FOR SELECT
    USING (true);

-- 9. RLS Policies for Transactions (Strict User Isolation)
DROP POLICY IF EXISTS "Users can read own transactions" ON public.transactions;
CREATE POLICY "Users can read own transactions"
    ON public.transactions FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own transactions" ON public.transactions;
CREATE POLICY "Users can insert own transactions"
    ON public.transactions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own transactions" ON public.transactions;
CREATE POLICY "Users can update own transactions"
    ON public.transactions FOR UPDATE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own transactions" ON public.transactions;
CREATE POLICY "Users can delete own transactions"
    ON public.transactions FOR DELETE
    USING (auth.uid() = user_id);

-- 10. Automatically update updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;
CREATE TRIGGER set_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS set_transactions_updated_at ON public.transactions;
CREATE TRIGGER set_transactions_updated_at
    BEFORE UPDATE ON public.transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 11. Auto-create User Profile on Google Auth Signup
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

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();
