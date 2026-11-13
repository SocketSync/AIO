-- ==============================================================================
-- FinWise Feature: Itemized Receipt Scanning & AI Purchase Insights
-- Adds JSONB column `receipt_items` to `public.transactions`
-- Execute this script in your Supabase SQL Editor:
-- https://supabase.com/dashboard/project/vcxxsffdsznmqtpghrss/sql/new
-- ==============================================================================

ALTER TABLE public.transactions
ADD COLUMN IF NOT EXISTS receipt_items JSONB DEFAULT '[]'::jsonb;

-- Ensure existing NULL rows default to empty JSON array
UPDATE public.transactions
SET receipt_items = '[]'::jsonb
WHERE receipt_items IS NULL;

-- Optional: Populate realistic itemized receipt data on existing Demo Account records
UPDATE public.transactions
SET receipt_items = '[
  {"item_name": "Organic Bananas", "price": 14.50, "quantity": 1, "category": "Groceries"},
  {"item_name": "Farm Fresh Milk 2L", "price": 18.90, "quantity": 2, "category": "Groceries"},
  {"item_name": "Colgate Toothpaste", "price": 12.50, "quantity": 2, "category": "Groceries"},
  {"item_name": "Artisan Sourdough Loaf", "price": 16.00, "quantity": 1, "category": "Groceries"}
]'::jsonb
WHERE user_id = '00000000-0000-4000-8000-000000000001'
  AND title ILIKE '%Village Grocer%'
  AND (receipt_items IS NULL OR receipt_items = '[]'::jsonb);

UPDATE public.transactions
SET receipt_items = '[
  {"item_name": "Flat White Coffee", "price": 13.00, "quantity": 1, "category": "Food & Dining"},
  {"item_name": "Sourdough Avocado Toast", "price": 15.00, "quantity": 1, "category": "Food & Dining"}
]'::jsonb
WHERE user_id = '00000000-0000-4000-8000-000000000001'
  AND title ILIKE '%Coffee%'
  AND (receipt_items IS NULL OR receipt_items = '[]'::jsonb);

