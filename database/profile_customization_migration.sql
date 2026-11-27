-- FinWise profile customization fields.
-- Run in the Supabase SQL editor after deploying the application.

ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS username VARCHAR(30);
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS bio VARCHAR(160);
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS theme_preference VARCHAR(10) DEFAULT 'system';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS ai_insights_enabled BOOLEAN DEFAULT true;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS overspending_alerts_enabled BOOLEAN DEFAULT true;

UPDATE public.profiles
SET username = lower(regexp_replace(split_part(email, '@', 1), '[^a-zA-Z0-9_]', '', 'g'))
WHERE username IS NULL OR btrim(username) = '';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'profiles_username_key'
      AND conrelid = 'public.profiles'::regclass
  ) THEN
    ALTER TABLE public.profiles
      ADD CONSTRAINT profiles_username_key UNIQUE (username);
  END IF;
END $$;

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_username_format
  CHECK (
    username IS NULL
    OR username ~ '^[A-Za-z0-9_]{3,30}$'
  );

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_bio_limit
  CHECK (bio IS NULL OR char_length(bio) <= 160);

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_theme_preference
  CHECK (theme_preference IN ('light', 'dark', 'system'));
