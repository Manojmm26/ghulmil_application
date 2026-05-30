-- =====================================
-- GHULMIL APPLICATION - SUPABASE RLS POLICIES
-- =====================================

-- =====================================
-- SECURITY DEFINER FUNCTIONS (PUBLIC SCHEMA)
-- =====================================

-- Function to check if current user is admin (avoids recursion)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND user_type = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if current user is provider
CREATE OR REPLACE FUNCTION public.is_provider()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND user_type = 'provider'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if current user is customer
CREATE OR REPLACE FUNCTION public.is_customer()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND user_type = 'customer'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================
-- USERS TABLE POLICIES
-- =====================================

-- Users can read their own profile
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Service providers can read customer profiles for bookings
DROP POLICY IF EXISTS "Providers can view customer profiles for bookings" ON public.users;
CREATE POLICY "Providers can view customer profiles for bookings" ON public.users
    FOR SELECT USING (
        auth.uid() IN (
            SELECT provider_id FROM public.bookings WHERE customer_id = users.id
        )
    );

-- Admin can manage all users (FIXED - using public schema function)
DROP POLICY IF EXISTS "Admin can manage all users" ON public.users;
CREATE POLICY "Admin can manage all users" ON public.users
    FOR ALL USING (public.is_admin());

-- =====================================
-- PROVIDERS TABLE POLICIES
-- =====================================

-- Anyone can view provider profiles
DROP POLICY IF EXISTS "Anyone can view provider profiles" ON public.providers;
CREATE POLICY "Anyone can view provider profiles" ON public.providers
    FOR SELECT TO authenticated USING (true);

-- Providers can update their own profile
DROP POLICY IF EXISTS "Providers can update own profile" ON public.providers;
CREATE POLICY "Providers can update own profile" ON public.providers
    FOR UPDATE USING (auth.uid() = id);

-- Admin can manage all providers (FIXED - using security definer function)
DROP POLICY IF EXISTS "Admin can manage providers" ON public.providers;
CREATE POLICY "Admin can manage providers" ON public.providers
    FOR ALL USING (public.is_admin());

-- =====================================
-- SERVICE CATEGORIES POLICIES
-- =====================================

-- Anyone can view service categories
DROP POLICY IF EXISTS "Anyone can view service categories" ON public.service_categories;
CREATE POLICY "Anyone can view service categories" ON public.service_categories
    FOR SELECT TO authenticated USING (true);

-- Admin can manage service categories (FIXED - using security definer function)
DROP POLICY IF EXISTS "Admin can manage service categories" ON public.service_categories;
CREATE POLICY "Admin can manage service categories" ON public.service_categories
    FOR ALL USING (public.is_admin());

-- =====================================
-- SERVICES TABLE POLICIES
-- =====================================

-- Anyone can view active services
DROP POLICY IF EXISTS "Anyone can view active services" ON public.services;
CREATE POLICY "Anyone can view active services" ON public.services
    FOR SELECT TO authenticated USING (is_active = true);

-- Admin can manage services (FIXED - using security definer function)
DROP POLICY IF EXISTS "Admin can manage services" ON public.services;
CREATE POLICY "Admin can manage services" ON public.services
    FOR ALL USING (public.is_admin());

-- =====================================
-- SERVICE PACKAGES POLICIES
-- =====================================

-- Anyone can view service packages
DROP POLICY IF EXISTS "Anyone can view service packages" ON public.service_packages;
CREATE POLICY "Anyone can view service packages" ON public.service_packages
    FOR SELECT TO authenticated USING (true);

-- Admin can manage service packages (FIXED - using security definer function)
DROP POLICY IF EXISTS "Admin can manage service packages" ON public.service_packages;
CREATE POLICY "Admin can manage service packages" ON public.service_packages
    FOR ALL USING (public.is_admin());

-- =====================================
-- ADDRESSES TABLE POLICIES
-- =====================================

-- Users can manage their own addresses
DROP POLICY IF EXISTS "Users can manage own addresses" ON public.addresses;
CREATE POLICY "Users can manage own addresses" ON public.addresses
    FOR ALL USING (auth.uid() = user_id);

-- =====================================
-- BOOKINGS TABLE POLICIES
-- =====================================

-- Customers can view their own bookings
DROP POLICY IF EXISTS "Customers can view own bookings" ON public.bookings;
CREATE POLICY "Customers can view own bookings" ON public.bookings
    FOR SELECT USING (auth.uid() = customer_id);

-- Providers can view bookings assigned to them
DROP POLICY IF EXISTS "Providers can view assigned bookings" ON public.bookings;
CREATE POLICY "Providers can view assigned bookings" ON public.bookings
    FOR SELECT USING (auth.uid() = provider_id);

-- Customers can create bookings
DROP POLICY IF EXISTS "Customers can create bookings" ON public.bookings;
CREATE POLICY "Customers can create bookings" ON public.bookings
    FOR INSERT WITH CHECK (
        auth.uid() = customer_id
        AND public.is_customer()
    );

-- Customers can update their pending/cancelled bookings
DROP POLICY IF EXISTS "Customers can update own pending bookings" ON public.bookings;
CREATE POLICY "Customers can update own pending bookings" ON public.bookings
    FOR UPDATE USING (
        auth.uid() = customer_id
        AND status IN ('pending', 'cancelled')
    );

-- Providers can update booking status for their bookings
DROP POLICY IF EXISTS "Providers can update booking status" ON public.bookings;
CREATE POLICY "Providers can update booking status" ON public.bookings
    FOR UPDATE USING (
        auth.uid() = provider_id
        AND public.is_provider()
    );

-- Admin can manage all bookings (FIXED - using security definer function)
DROP POLICY IF EXISTS "Admin can manage all bookings" ON public.bookings;
CREATE POLICY "Admin can manage all bookings" ON public.bookings
    FOR ALL USING (public.is_admin());

-- =====================================
-- GHULMIL APPLICATION - SUPABASE SCHEMA
-- =====================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- =====================================
-- TABLES
-- =====================================

-- 1. USER PROFILES AND AUTHENTICATION
DROP TABLE IF EXISTS public.users CASCADE;
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    user_type TEXT NOT NULL CHECK (user_type IN ('customer', 'provider', 'admin')),
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. SERVICE PROVIDER PROFILES
DROP TABLE IF EXISTS public.providers CASCADE;
CREATE TABLE public.providers (
    id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    bio TEXT,
    experience_years INTEGER DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0.00,
    completed_jobs INTEGER DEFAULT 0,
    languages TEXT[] DEFAULT '{}',
    certifications TEXT[] DEFAULT '{}',
    is_available BOOLEAN DEFAULT TRUE,
    response_time_minutes INTEGER,
    location GEOGRAPHY(POINT),
    service_radius_km INTEGER DEFAULT 50,
    working_hours JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. SERVICE CATEGORIES
DROP TABLE IF EXISTS public.service_categories CASCADE;
CREATE TABLE public.service_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    icon_url TEXT,
    color TEXT DEFAULT '#0FA3B1',
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. SERVICES
DROP TABLE IF EXISTS public.services CASCADE;
CREATE TABLE public.services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID REFERENCES public.service_categories(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    subtitle TEXT,
    description TEXT,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INTEGER DEFAULT 0,
    tags TEXT[] DEFAULT '{}',
    image_url TEXT,
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    estimated_duration_minutes INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. SERVICE PACKAGES
DROP TABLE IF EXISTS public.service_packages CASCADE;
CREATE TABLE public.service_packages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    duration_minutes INTEGER NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'USD',
    inclusions TEXT[] DEFAULT '{}',
    exclusions TEXT[] DEFAULT '{}',
    is_popular BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. ADDRESSES
DROP TABLE IF EXISTS public.addresses CASCADE;
CREATE TABLE public.addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    label TEXT NOT NULL,
    street TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT,
    postal_code TEXT,
    country TEXT DEFAULT 'India',
    location GEOGRAPHY(POINT),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. BOOKINGS
DROP TABLE IF EXISTS public.bookings CASCADE;
CREATE TABLE public.bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    provider_id UUID REFERENCES public.providers(id) ON DELETE SET NULL,
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    address_id UUID REFERENCES public.addresses(id) ON DELETE SET NULL,
    scheduled_at TIMESTAMPTZ NOT NULL,
    duration_minutes INTEGER,
    total_amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'USD',
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled')),
    special_instructions TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. PAYMENT METHODS
DROP TABLE IF EXISTS public.payment_methods CASCADE;
CREATE TABLE public.payment_methods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('credit_card', 'debit_card', 'upi', 'net_banking', 'wallet')),
    provider TEXT,
    last_four TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. PAYMENTS
DROP TABLE IF EXISTS public.payments CASCADE;
CREATE TABLE public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'USD',
    method TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'refunded')),
    transaction_id TEXT,
    payment_gateway TEXT,
    metadata JSONB DEFAULT '{}',
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. REVIEWS
DROP TABLE IF EXISTS public.reviews CASCADE;
CREATE TABLE public.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES public.providers(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    images TEXT[] DEFAULT '{}',
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. SUBSCRIPTIONS
DROP TABLE IF EXISTS public.subscriptions CASCADE;
CREATE TABLE public.subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    plan_name TEXT NOT NULL,
    plan_type TEXT CHECK (plan_type IN ('monthly', 'yearly')),
    price DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'USD',
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired')),
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ,
    auto_renew BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. PROVIDER AVAILABILITY
DROP TABLE IF EXISTS public.provider_availability CASCADE;
CREATE TABLE public.provider_availability (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID NOT NULL REFERENCES public.providers(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(provider_id, day_of_week, start_time, end_time)
);

-- 13. TRACKING UPDATES
DROP TABLE IF EXISTS public.tracking_updates CASCADE;
CREATE TABLE public.tracking_updates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES public.providers(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('confirmed', 'in_transit', 'arrived', 'in_progress', 'completed')),
    location GEOGRAPHY(POINT),
    notes TEXT,
    estimated_arrival TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 14. NOTIFICATIONS
DROP TABLE IF EXISTS public.notifications CASCADE;
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'info' CHECK (type IN ('info', 'success', 'warning', 'error')),
    is_read BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================
-- INDEXES
-- =====================================

-- Users table indexes
DROP INDEX IF EXISTS idx_users_email;
DROP INDEX IF EXISTS idx_users_user_type;
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_user_type ON public.users(user_type);

-- Providers table indexes
DROP INDEX IF EXISTS idx_providers_location;
DROP INDEX IF EXISTS idx_providers_rating;
CREATE INDEX idx_providers_location ON public.providers USING GIST(location);
CREATE INDEX idx_providers_rating ON public.providers(rating);

-- Services table indexes
DROP INDEX IF EXISTS idx_services_category;
DROP INDEX IF EXISTS idx_services_active;
CREATE INDEX idx_services_category ON public.services(category_id);
CREATE INDEX idx_services_active ON public.services(is_active);

-- Bookings table indexes
DROP INDEX IF EXISTS idx_bookings_customer;
DROP INDEX IF EXISTS idx_bookings_provider;
DROP INDEX IF EXISTS idx_bookings_status;
DROP INDEX IF EXISTS idx_bookings_scheduled_at;
CREATE INDEX idx_bookings_customer ON public.bookings(customer_id);
CREATE INDEX idx_bookings_provider ON public.bookings(provider_id);
CREATE INDEX idx_bookings_status ON public.bookings(status);
CREATE INDEX idx_bookings_scheduled_at ON public.bookings(scheduled_at);

-- Reviews table indexes
DROP INDEX IF EXISTS idx_reviews_provider;
DROP INDEX IF EXISTS idx_reviews_rating;
CREATE INDEX idx_reviews_provider ON public.reviews(provider_id);
CREATE INDEX idx_reviews_rating ON public.reviews(rating);

-- Provider availability indexes
DROP INDEX IF EXISTS idx_provider_availability_provider;
DROP INDEX IF EXISTS idx_provider_availability_day;
CREATE INDEX idx_provider_availability_provider ON public.provider_availability(provider_id);
CREATE INDEX idx_provider_availability_day ON public.provider_availability(day_of_week);

-- Notifications indexes
DROP INDEX IF EXISTS idx_notifications_user;
DROP INDEX IF EXISTS idx_notifications_read;
CREATE INDEX idx_notifications_user ON public.notifications(user_id);
CREATE INDEX idx_notifications_read ON public.notifications(is_read);

-- =====================================
-- ROW LEVEL SECURITY
-- =====================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.providers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.provider_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tracking_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- =====================================
-- SECURITY DEFINER FUNCTIONS (PUBLIC SCHEMA)
-- =====================================

-- Function to check if current user is admin (avoids recursion)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND user_type = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if current user is provider
CREATE OR REPLACE FUNCTION public.is_provider()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND user_type = 'provider'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if current user is customer
CREATE OR REPLACE FUNCTION public.is_customer()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND user_type = 'customer'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================
-- RLS POLICIES
-- =====================================

-- USERS TABLE POLICIES
-- Users can read their own profile
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Service providers can read customer profiles for bookings
DROP POLICY IF EXISTS "Providers can view customer profiles for bookings" ON public.users;
CREATE POLICY "Providers can view customer profiles for bookings" ON public.users
    FOR SELECT USING (
        auth.uid() IN (
            SELECT provider_id FROM public.bookings WHERE customer_id = users.id
        )
    );

-- Admin can manage all users (FIXED - using public schema function)
DROP POLICY IF EXISTS "Admin can manage all users" ON public.users;
CREATE POLICY "Admin can manage all users" ON public.users
    FOR ALL USING (public.is_admin());

-- PROVIDERS TABLE POLICIES
-- Anyone can view provider profiles
DROP POLICY IF EXISTS "Anyone can view provider profiles" ON public.providers;
CREATE POLICY "Anyone can view provider profiles" ON public.providers
    FOR SELECT TO authenticated USING (true);

-- Providers can update their own profile
DROP POLICY IF EXISTS "Providers can update own profile" ON public.providers;
CREATE POLICY "Providers can update own profile" ON public.providers
    FOR UPDATE USING (auth.uid() = id);

-- Admin can manage all providers (FIXED - using public schema function)
DROP POLICY IF EXISTS "Admin can manage providers" ON public.providers;
CREATE POLICY "Admin can manage providers" ON public.providers
    FOR ALL USING (public.is_admin());

-- SERVICE CATEGORIES POLICIES
-- Anyone can view service categories
DROP POLICY IF EXISTS "Anyone can view service categories" ON public.service_categories;
CREATE POLICY "Anyone can view service categories" ON public.service_categories
    FOR SELECT TO authenticated USING (true);

-- Admin can manage service categories (FIXED - using public schema function)
DROP POLICY IF EXISTS "Admin can manage service categories" ON public.service_categories;
CREATE POLICY "Admin can manage service categories" ON public.service_categories
    FOR ALL USING (public.is_admin());

-- SERVICES TABLE POLICIES
-- Anyone can view active services
DROP POLICY IF EXISTS "Anyone can view active services" ON public.services;
CREATE POLICY "Anyone can view active services" ON public.services
    FOR SELECT TO authenticated USING (is_active = true);

-- Admin can manage services (FIXED - using public schema function)
DROP POLICY IF EXISTS "Admin can manage services" ON public.services;
CREATE POLICY "Admin can manage services" ON public.services
    FOR ALL USING (public.is_admin());

-- SERVICE PACKAGES POLICIES
-- Anyone can view service packages
DROP POLICY IF EXISTS "Anyone can view service packages" ON public.service_packages;
CREATE POLICY "Anyone can view service packages" ON public.service_packages
    FOR SELECT TO authenticated USING (true);

-- Admin can manage service packages (FIXED - using public schema function)
DROP POLICY IF EXISTS "Admin can manage service packages" ON public.service_packages;
CREATE POLICY "Admin can manage service packages" ON public.service_packages
    FOR ALL USING (public.is_admin());

-- ADDRESSES TABLE POLICIES
-- Users can manage their own addresses
DROP POLICY IF EXISTS "Users can manage own addresses" ON public.addresses;
CREATE POLICY "Users can manage own addresses" ON public.addresses
    FOR ALL USING (auth.uid() = user_id);

-- BOOKINGS TABLE POLICIES
-- Customers can view their own bookings
DROP POLICY IF EXISTS "Customers can view own bookings" ON public.bookings;
CREATE POLICY "Customers can view own bookings" ON public.bookings
    FOR SELECT USING (auth.uid() = customer_id);

-- Providers can view bookings assigned to them
DROP POLICY IF EXISTS "Providers can view assigned bookings" ON public.bookings;
CREATE POLICY "Providers can view assigned bookings" ON public.bookings
    FOR SELECT USING (auth.uid() = provider_id);

-- Customers can create bookings
DROP POLICY IF EXISTS "Customers can create bookings" ON public.bookings;
CREATE POLICY "Customers can create bookings" ON public.bookings
    FOR INSERT WITH CHECK (
        auth.uid() = customer_id
        AND public.is_customer()
    );

-- Customers can update their pending/cancelled bookings
DROP POLICY IF EXISTS "Customers can update own pending bookings" ON public.bookings;
CREATE POLICY "Customers can update own pending bookings" ON public.bookings
    FOR UPDATE USING (
        auth.uid() = customer_id
        AND status IN ('pending', 'cancelled')
    );

-- Providers can update booking status for their bookings
DROP POLICY IF EXISTS "Providers can update booking status" ON public.bookings;
CREATE POLICY "Providers can update booking status" ON public.bookings
    FOR UPDATE USING (
        auth.uid() = provider_id
        AND public.is_provider()
    );

-- Admin can manage all bookings (FIXED - using public schema function)
DROP POLICY IF EXISTS "Admin can manage all bookings" ON public.bookings;
CREATE POLICY "Admin can manage all bookings" ON public.bookings
    FOR ALL USING (public.is_admin());

-- PAYMENT METHODS POLICIES
-- Users can manage their own payment methods
DROP POLICY IF EXISTS "Users can manage own payment methods" ON public.payment_methods;
CREATE POLICY "Users can manage own payment methods" ON public.payment_methods
    FOR ALL USING (auth.uid() = user_id);

-- PAYMENTS TABLE POLICIES
-- Users can view payments for their bookings
DROP POLICY IF EXISTS "Users can view booking payments" ON public.payments;
CREATE POLICY "Users can view booking payments" ON public.payments
    FOR SELECT USING (
        auth.uid() IN (
            SELECT customer_id FROM public.bookings WHERE id = payments.booking_id
        )
        OR auth.uid() IN (
            SELECT provider_id FROM public.bookings WHERE id = payments.booking_id
        )
    );

-- Customers can create payments
DROP POLICY IF EXISTS "Customers can create payments" ON public.payments;
CREATE POLICY "Customers can create payments" ON public.payments
    FOR INSERT WITH CHECK (
        auth.uid() IN (
            SELECT customer_id FROM public.bookings WHERE id = booking_id
        )
    );

-- Admin can manage all payments (FIXED - using public schema function)
DROP POLICY IF EXISTS "Admin can manage payments" ON public.payments;
CREATE POLICY "Admin can manage payments" ON public.payments
    FOR ALL USING (public.is_admin());

-- REVIEWS TABLE POLICIES
-- Anyone can view reviews
DROP POLICY IF EXISTS "Anyone can view reviews" ON public.reviews;
CREATE POLICY "Anyone can view reviews" ON public.reviews
    FOR SELECT TO authenticated USING (true);

-- Customers can create reviews for completed bookings
DROP POLICY IF EXISTS "Customers can create reviews" ON public.reviews;
CREATE POLICY "Customers can create reviews" ON public.reviews
    FOR INSERT WITH CHECK (
        auth.uid() = customer_id
        AND EXISTS (
            SELECT 1 FROM public.bookings
            WHERE id = booking_id
            AND customer_id = auth.uid()
            AND status = 'completed'
        )
    );

-- Customers can update their own reviews
DROP POLICY IF EXISTS "Customers can update own reviews" ON public.reviews;
CREATE POLICY "Customers can update own reviews" ON public.reviews
    FOR UPDATE USING (auth.uid() = customer_id);

-- Admin can manage all reviews (FIXED - using public schema function)
DROP POLICY IF EXISTS "Admin can manage reviews" ON public.reviews;
CREATE POLICY "Admin can manage reviews" ON public.reviews
    FOR ALL USING (public.is_admin());

-- SUBSCRIPTIONS TABLE POLICIES
-- Customers can manage their own subscriptions
DROP POLICY IF EXISTS "Customers can manage own subscriptions" ON public.subscriptions;
CREATE POLICY "Customers can manage own subscriptions" ON public.subscriptions
    FOR ALL USING (auth.uid() = customer_id);

-- PROVIDER AVAILABILITY POLICIES
-- Providers can manage their own availability
DROP POLICY IF EXISTS "Providers can manage own availability" ON public.provider_availability;
CREATE POLICY "Providers can manage own availability" ON public.provider_availability
    FOR ALL USING (
        auth.uid() = provider_id
        AND public.is_provider()
    );

-- Anyone can view provider availability for booking
DROP POLICY IF EXISTS "Anyone can view provider availability" ON public.provider_availability;
CREATE POLICY "Anyone can view provider availability" ON public.provider_availability
    FOR SELECT TO authenticated USING (true);

-- TRACKING UPDATES POLICIES
-- Providers can create tracking updates for their bookings
DROP POLICY IF EXISTS "Providers can create tracking updates" ON public.tracking_updates;
CREATE POLICY "Providers can create tracking updates" ON public.tracking_updates
    FOR INSERT WITH CHECK (
        auth.uid() = provider_id
        AND public.is_provider()
    );

-- Customers and providers can view tracking for their bookings
DROP POLICY IF EXISTS "Users can view booking tracking" ON public.tracking_updates;
CREATE POLICY "Users can view booking tracking" ON public.tracking_updates
    FOR SELECT USING (
        auth.uid() IN (
            SELECT customer_id FROM public.bookings WHERE id = tracking_updates.booking_id
        )
        OR auth.uid() IN (
            SELECT provider_id FROM public.bookings WHERE id = tracking_updates.booking_id
        )
    );

-- NOTIFICATIONS TABLE POLICIES
-- Users can manage their own notifications
DROP POLICY IF EXISTS "Users can manage own notifications" ON public.notifications;
CREATE POLICY "Users can manage own notifications" ON public.notifications
    FOR ALL USING (auth.uid() = user_id);

-- =====================================
-- FUNCTION SECURITY
-- =====================================

-- Grant execute permissions on functions
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_provider() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_customer() TO authenticated;
GRANT EXECUTE ON FUNCTION find_nearby_providers(UUID, GEOGRAPHY, INTEGER, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION update_provider_rating() TO authenticated;
GRANT EXECUTE ON FUNCTION update_service_rating() TO authenticated;
