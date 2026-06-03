-- Supabase Sync: Trigger to automatically sync auth.users -> public.users
-- Run this in your Supabase Dashboard SQL Editor

-- 1. Create handle_new_user trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name, phone, avatar_url, user_type, is_verified)
  VALUES (
    NEW.id,
    COALESCE(NEW.email, ''),
    COALESCE(
      NEW.raw_user_meta_data->>'full_name', 
      NEW.raw_user_meta_data->>'fullName', 
      split_part(NEW.email, '@', 1)
    ),
    COALESCE(NEW.raw_user_meta_data->>'phone', NEW.phone, ''),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', NEW.raw_user_meta_data->>'avatarUrl', ''),
    COALESCE(NEW.raw_user_meta_data->>'user_type', 'customer'),
    FALSE
  )
  ON CONFLICT (id) DO NOTHING;
  
  -- If the user is registered as a service provider, create their entry in public.providers
  IF COALESCE(NEW.raw_user_meta_data->>'user_type', 'customer') = 'provider' THEN
    INSERT INTO public.providers (id, experience_years, rating, completed_jobs, is_available)
    VALUES (NEW.id, 0, 5.00, 0, TRUE)
    ON CONFLICT (id) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Bind trigger to auth.users table
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 3. Backfill all existing users who registered prior to the trigger being created
INSERT INTO public.users (id, email, full_name, phone, avatar_url, user_type, is_verified)
SELECT 
  id,
  COALESCE(email, ''),
  COALESCE(
    raw_user_meta_data->>'full_name', 
    raw_user_meta_data->>'fullName', 
    split_part(email, '@', 1)
  ),
  COALESCE(raw_user_meta_data->>'phone', phone, ''),
  COALESCE(raw_user_meta_data->>'avatar_url', raw_user_meta_data->>'avatarUrl', ''),
  COALESCE(raw_user_meta_data->>'user_type', 'customer'),
  FALSE
FROM auth.users
ON CONFLICT (id) DO NOTHING;

-- 4. Backfill public.providers for any existing provider users
INSERT INTO public.providers (id, experience_years, rating, completed_jobs, is_available)
SELECT 
  id,
  0,
  5.00,
  0,
  TRUE
FROM public.users
WHERE user_type = 'provider'
ON CONFLICT (id) DO NOTHING;
