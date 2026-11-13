-- ============================================================
-- FinWise: Savings Goals - Migration Script
-- Task 1: Table Schema + Row Level Security (RLS)
-- ============================================================

-- 1. Create the savings_goals table
CREATE TABLE IF NOT EXISTS public.savings_goals (
  id                   UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              UUID           NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  goal_name            TEXT           NOT NULL,
  target_amount        NUMERIC(12, 2) NOT NULL CHECK (target_amount > 0),
  current_saved_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (current_saved_amount >= 0),
  target_date          DATE           NOT NULL,
  created_at           TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  updated_at           TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

-- 2. Auto-update updated_at on row modification
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_savings_goals_updated_at ON public.savings_goals;
CREATE TRIGGER trg_savings_goals_updated_at
  BEFORE UPDATE ON public.savings_goals
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 3. Enable Row Level Security
ALTER TABLE public.savings_goals ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies: each user can only CRUD their own rows
-- SELECT
DROP POLICY IF EXISTS "savings_goals_select_own" ON public.savings_goals;
CREATE POLICY "savings_goals_select_own"
  ON public.savings_goals FOR SELECT
  USING (auth.uid() = user_id);

-- INSERT
DROP POLICY IF EXISTS "savings_goals_insert_own" ON public.savings_goals;
CREATE POLICY "savings_goals_insert_own"
  ON public.savings_goals FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- UPDATE
DROP POLICY IF EXISTS "savings_goals_update_own" ON public.savings_goals;
CREATE POLICY "savings_goals_update_own"
  ON public.savings_goals FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- DELETE
DROP POLICY IF EXISTS "savings_goals_delete_own" ON public.savings_goals;
CREATE POLICY "savings_goals_delete_own"
  ON public.savings_goals FOR DELETE
  USING (auth.uid() = user_id);

-- 5. Performance index on user_id (for fast per-user queries)
CREATE INDEX IF NOT EXISTS idx_savings_goals_user_id
  ON public.savings_goals (user_id);
