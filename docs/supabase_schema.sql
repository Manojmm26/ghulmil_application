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
CREATE TABLE public.addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    label TEXT NOT NULL,
    street TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip_code TEXT NOT NULL,
    country TEXT DEFAULT 'US',
    coordinates GEOGRAPHY(POINT),
    instructions TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. BOOKINGS
CREATE TABLE public.bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    provider_id UUID REFERENCES public.providers(id) ON DELETE SET NULL,
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    package_id UUID NOT NULL REFERENCES public.service_packages(id) ON DELETE CASCADE,
    address_id UUID NOT NULL REFERENCES public.addresses(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('pending', 'confirmed', 'enroute', 'in_progress', 'completed', 'cancelled')),
    scheduled_at TIMESTAMPTZ NOT NULL,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    cancellation_reason TEXT,
    special_instructions TEXT,
    total_amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'USD',
    payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'refunded', 'failed')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. PAYMENT METHODS
CREATE TABLE public.payment_methods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('credit_card', 'debit_card', 'digital_wallet', 'cash')),
    provider TEXT CHECK (provider IN ('stripe', 'paypal', 'apple_pay', 'google_pay')),
    last_four TEXT,
    brand TEXT,
    expiry_month INTEGER,
    expiry_year INTEGER,
    is_default BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    encrypted_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. PAYMENTS
CREATE TABLE public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    payment_method_id UUID REFERENCES public.payment_methods(id) ON DELETE SET NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'USD',
    status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'refunded')),
    external_payment_id TEXT, -- Stripe/PayPal payment ID
    payment_provider TEXT,
    processed_at TIMESTAMPTZ,
    refunded_at TIMESTAMPTZ,
    refund_amount DECIMAL(10,2),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. REVIEWS
CREATE TABLE public.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES public.providers(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    images TEXT[] DEFAULT '{}',
    is_verified BOOLEAN DEFAULT FALSE,
    helpful_votes INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. SUBSCRIPTIONS
CREATE TABLE public.subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    package_id UUID NOT NULL REFERENCES public.service_packages(id) ON DELETE CASCADE,
    address_id UUID NOT NULL REFERENCES public.addresses(id) ON DELETE CASCADE,
    payment_method_id UUID NOT NULL REFERENCES public.payment_methods(id) ON DELETE CASCADE,
    frequency TEXT NOT NULL CHECK (frequency IN ('weekly', 'bi_weekly', 'monthly')),
    preferred_day_of_week TEXT CHECK (preferred_day_of_week IN ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday')),
    preferred_time TIME,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'cancelled')),
    next_booking_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. PROVIDER AVAILABILITY
CREATE TABLE public.provider_availability (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID NOT NULL REFERENCES public.providers(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(provider_id, date, start_time, end_time)
);

-- 13. TRACKING UPDATES
CREATE TABLE public.tracking_updates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES public.providers(id) ON DELETE CASCADE,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    heading INTEGER, -- 0-360 degrees
    speed_kmh DECIMAL(5,2),
    eta_minutes INTEGER,
    location GEOGRAPHY(POINT) GENERATED ALWAYS AS (ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)) STORED,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 14. NOTIFICATIONS
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('booking', 'payment', 'review', 'system', 'promotion')),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================
-- INDEXES FOR PERFORMANCE
-- =====================================

-- Users
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_user_type ON public.users(user_type);
CREATE INDEX idx_users_created_at ON public.users(created_at);

-- Providers
CREATE INDEX idx_providers_location ON public.providers USING GIST(location);
CREATE INDEX idx_providers_rating ON public.providers(rating DESC);
CREATE INDEX idx_providers_is_available ON public.providers(is_available);

-- Services
CREATE INDEX idx_services_category_id ON public.services(category_id);
CREATE INDEX idx_services_rating ON public.services(rating DESC);
CREATE INDEX idx_services_is_featured ON public.services(is_featured);
CREATE INDEX idx_services_tags ON public.services USING GIN(tags);

-- Bookings
CREATE INDEX idx_bookings_customer_id ON public.bookings(customer_id);
CREATE INDEX idx_bookings_provider_id ON public.bookings(provider_id);
CREATE INDEX idx_bookings_status ON public.bookings(status);
CREATE INDEX idx_bookings_scheduled_at ON public.bookings(scheduled_at);
CREATE INDEX idx_bookings_created_at ON public.bookings(created_at);

-- Reviews
CREATE INDEX idx_reviews_booking_id ON public.reviews(booking_id);
CREATE INDEX idx_reviews_provider_id ON public.reviews(provider_id);
CREATE INDEX idx_reviews_rating ON public.reviews(rating DESC);

-- Provider Availability
CREATE INDEX idx_provider_availability_provider_date ON public.provider_availability(provider_id, date);

-- Tracking
CREATE INDEX idx_tracking_updates_booking_id ON public.tracking_updates(booking_id);
CREATE INDEX idx_tracking_updates_created_at ON public.tracking_updates(created_at);
CREATE INDEX idx_tracking_updates_location ON public.tracking_updates USING GIST(location);

-- Notifications
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at);

-- =====================================
-- FUNCTIONS
-- =====================================

-- Function to update provider rating
CREATE OR REPLACE FUNCTION update_provider_rating()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.providers
        SET
            rating = (
                SELECT AVG(r.rating)
                FROM public.reviews r
                WHERE r.provider_id = NEW.provider_id
            ),
            completed_jobs = (
                SELECT COUNT(*)
                FROM public.bookings b
                WHERE b.provider_id = NEW.provider_id
                AND b.status = 'completed'
            )
        WHERE id = NEW.provider_id;
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE public.providers
        SET
            rating = (
                SELECT AVG(r.rating)
                FROM public.reviews r
                WHERE r.provider_id = NEW.provider_id
            ),
            completed_jobs = (
                SELECT COUNT(*)
                FROM public.bookings b
                WHERE b.provider_id = NEW.provider_id
                AND b.status = 'completed'
            )
        WHERE id = NEW.provider_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.providers
        SET
            rating = (
                SELECT AVG(r.rating)
                FROM public.reviews r
                WHERE r.provider_id = OLD.provider_id
            ),
            completed_jobs = (
                SELECT COUNT(*)
                FROM public.bookings b
                WHERE b.provider_id = OLD.provider_id
                AND b.status = 'completed'
            )
        WHERE id = OLD.provider_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function to update service rating
CREATE OR REPLACE FUNCTION update_service_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.services
    SET
        rating = (
            SELECT AVG(r.rating)
            FROM public.reviews r
            JOIN public.bookings b ON r.booking_id = b.id
            WHERE b.service_id = COALESCE(NEW.service_id, OLD.service_id)
        ),
        total_reviews = (
            SELECT COUNT(*)
            FROM public.reviews r
            JOIN public.bookings b ON r.booking_id = b.id
            WHERE b.service_id = COALESCE(NEW.service_id, OLD.service_id)
        )
    WHERE id = COALESCE(NEW.service_id, OLD.service_id);
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Function to find nearby providers
CREATE OR REPLACE FUNCTION find_nearby_providers(
    service_id_param UUID,
    customer_location GEOGRAPHY,
    max_distance_km INTEGER DEFAULT 50,
    limit_count INTEGER DEFAULT 10
)
RETURNS TABLE (
    provider_id UUID,
    provider_name TEXT,
    rating DECIMAL(3,2),
    distance_km DECIMAL(10,2),
    eta_minutes INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        u.full_name,
        p.rating,
        ST_Distance(p.location, customer_location) / 1000 AS distance_km,
        CASE
            WHEN ST_Distance(p.location, customer_location) / 1000 <= 5 THEN 15
            WHEN ST_Distance(p.location, customer_location) / 1000 <= 10 THEN 25
            WHEN ST_Distance(p.location, customer_location) / 1000 <= 20 THEN 35
            ELSE 45
        END as eta_minutes
    FROM public.providers p
    JOIN public.users u ON p.id = u.id
    WHERE
        p.is_available = TRUE
        AND ST_DWithin(p.location, customer_location, max_distance_km * 1000)
        AND p.service_radius_km >= ST_Distance(p.location, customer_location) / 1000
    ORDER BY
        p.rating DESC,
        ST_Distance(p.location, customer_location)
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================
-- TRIGGERS
-- =====================================

-- Trigger to update provider rating on review changes
CREATE TRIGGER trigger_update_provider_rating
    AFTER INSERT OR UPDATE OR DELETE ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION update_provider_rating();

-- Trigger to update service rating on booking completion
CREATE TRIGGER trigger_update_service_rating
    AFTER UPDATE ON public.bookings
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM NEW.status AND NEW.status = 'completed')
    EXECUTE FUNCTION update_service_rating();

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

-- RLS Policies will be defined in separate migration file

-- =====================================
-- INITIAL DATA
-- =====================================

-- Insert default service categories
INSERT INTO public.service_categories (name, description, icon_url, color, sort_order) VALUES
('Cleaning', 'Professional home and office cleaning services', '/icons/cleaning.svg', '#0FA3B1', 1),
('Plumbing', 'Expert plumbing repairs and installations', '/icons/plumbing.svg', '#FF8A00', 2),
('Electrical', 'Licensed electrical work and repairs', '/icons/electrical.svg', '#10B981', 3),
('Home Repair', 'General home maintenance and repairs', '/icons/repair.svg', '#8B5CF6', 4),
('Gardening', 'Lawn care and landscaping services', '/icons/gardening.svg', '#F59E0B', 5),
('Moving', 'Professional moving and relocation services', '/icons/moving.svg', '#EF4444', 6);

-- Insert sample services (will be expanded)
INSERT INTO public.services (category_id, title, subtitle, description, tags, estimated_duration_minutes) VALUES
((SELECT id FROM public.service_categories WHERE name = 'Cleaning'),
 'Household Cleaning', 'Professional cleaning for your home',
 'Comprehensive home cleaning service including bedrooms, bathrooms, kitchen, and living areas',
 ARRAY['Cleaning', 'Home', 'Verified'], 120),

((SELECT id FROM public.service_categories WHERE name = 'Plumbing'),
 'Emergency Plumbing', '24/7 emergency plumbing services',
 'Urgent plumbing repairs for leaks, clogs, and pipe issues',
 ARRAY['Plumbing', 'Emergency', '24/7'], 60);

-- Insert sample packages
INSERT INTO public.service_packages (service_id, title, description, duration_minutes, base_price, inclusions, is_popular, sort_order)
SELECT
    s.id,
    'Standard Clean',
    'Basic cleaning package for regular maintenance',
    120,
    49.99,
    ARRAY['2 bedrooms, 1 bathroom', 'Kitchen cleaning', 'Living room dusting'],
    TRUE,
    1
FROM public.services s
WHERE s.title = 'Household Cleaning';

-- =====================================
-- COMMENTS
-- =====================================

COMMENT ON TABLE public.users IS 'User profiles linked to Supabase auth';
COMMENT ON TABLE public.providers IS 'Service provider profiles with location and availability';
COMMENT ON TABLE public.bookings IS 'Service booking records with status tracking';
COMMENT ON TABLE public.tracking_updates IS 'Real-time location updates for service tracking';
COMMENT ON TABLE public.subscriptions IS 'Recurring service subscriptions';
COMMENT ON COLUMN public.providers.location IS 'Geographic location for proximity matching';
COMMENT ON COLUMN public.providers.working_hours IS 'JSON object with availability schedule';
COMMENT ON COLUMN public.bookings.total_amount IS 'Calculated total including taxes and fees';
