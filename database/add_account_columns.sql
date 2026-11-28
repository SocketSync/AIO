-- Migration: Add account_type and account_name columns to public.transactions
ALTER TABLE public.transactions
  ADD COLUMN IF NOT EXISTS account_type VARCHAR(30),
  ADD COLUMN IF NOT EXISTS account_name VARCHAR(100);
