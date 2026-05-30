# Supabase RLS (Row Level Security) Setup Guide

## Issue Analysis

The error `new row violates row-level security policy for table "users"` occurs because Supabase RLS policies are blocking user profile creation after signup.

## Root Cause

When users sign up, the app tries to create a profile in the `users` table, but RLS policies prevent this operation because:

1. **Default RLS Policies**: Supabase tables have RLS enabled by default
2. **Restrictive Policies**: Default policies may be too restrictive for user self-registration
3. **Authentication Context**: The user session may not have proper permissions

## Solutions

### Solution 1: Fix RLS Policies (Recommended)

Create a policy that allows authenticated users to insert their own profile:

```sql
-- Enable RLS on users table (if not already enabled)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Allow users to insert their own profile
CREATE POLICY "Users can insert their own profile" ON users
FOR INSERT
WITH CHECK (auth.uid() = id);

-- Allow users to view their own profile
CREATE POLICY "Users can view their own profile" ON users
FOR SELECT
USING (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update their own profile" ON users
FOR UPDATE
USING (auth.uid() = id);

-- Allow service role to manage all profiles (for admin functions)
CREATE POLICY "Service role can manage all profiles" ON users
FOR ALL
USING (current_setting('role') = 'service_role');
```

### Solution 2: Use Database Triggers (Alternative)

Create a trigger that automatically creates user profiles when auth.users is created:

```sql
-- Create function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name, user_type, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    'customer',
    NOW(),
    NOW()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

### Solution 3: Disable RLS Temporarily (Development Only)

```sql
-- Disable RLS for development (NOT recommended for production)
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
```

## Implementation Steps

### Step 1: Run SQL in Supabase Dashboard

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Run the appropriate SQL commands above

### Step 2: Update Your App Code

The app code has been updated to handle RLS errors gracefully:

```dart
// Check if profile already exists before creating
final existingProfile = await _supabase
    .from('users')
    .select('id')
    .eq('id', user.id)
    .maybeSingle();

if (existingProfile != null) {
  Logger.debug('User profile already exists');
  return;
}
```

### Step 3: Test the Fix

1. **Manual Signup**: Create a new account with email/password
2. **Google Signup**: Test Google Sign-In
3. **Profile Creation**: Verify profiles are created in the users table

## Verification

Check your Supabase logs in the **Authentication** > **Users** section to ensure profiles are being created correctly.

## Security Considerations

- **Solution 1** is most secure as it maintains RLS while allowing proper access
- **Solution 2** is good for automatic profile creation but requires careful trigger management
- **Solution 3** should only be used in development environments

## Troubleshooting

If you still get RLS errors:

1. **Check Policy Syntax**: Verify SQL syntax in Supabase SQL Editor
2. **Verify User Session**: Ensure users are properly authenticated
3. **Check Table Schema**: Confirm your users table has the correct columns
4. **Review Logs**: Check Supabase logs for detailed error information

## Next Steps

After implementing the RLS fix:
1. Test both manual and Google signup flows
2. Verify user profiles are created in the database
3. Ensure users can sign in and access their profiles
4. Set up proper profile management features
