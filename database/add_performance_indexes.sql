-- ==============================================================================
-- FinWise Migration: Database Performance Indexes (AIO-82)
-- Adds composite B-tree and JSONB GIN indexes on public.transactions for
-- common user-scoped date, category, and itemized receipt queries.
-- Safe to run multiple times (idempotent via IF NOT EXISTS).
-- ==============================================================================

-- 1. Speed up user-scoped transaction history ordered by most recent date
CREATE INDEX IF NOT EXISTS idx_transactions_user_date
    ON public.transactions (user_id, transaction_date DESC);

-- 2. Speed up user-scoped category filtering and budget/expense aggregations
CREATE INDEX IF NOT EXISTS idx_transactions_user_category
    ON public.transactions (user_id, category_id);

-- 3. Speed up JSONB containment/search queries on itemized receipt_items
CREATE INDEX IF NOT EXISTS idx_transactions_receipt_items_gin
    ON public.transactions USING GIN (receipt_items);
