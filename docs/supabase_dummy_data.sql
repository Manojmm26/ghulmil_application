-- =====================================
-- GHULMIL APPLICATION · SERVICE DUMMY DATA SEED
-- Run this script in the Supabase SQL editor to populate demo records.
-- All UUIDs are fixed so the script can be re-run safely.
-- =====================================

BEGIN;

-- -------------------------------------
-- Cleanup previous demo data (idempotent)
-- -------------------------------------
DELETE FROM public.service_packages
WHERE id IN (
  'aaaa0000-0000-0000-0000-000000000001',
  'aaaa0000-0000-0000-0000-000000000002',
  'aaaa0000-0000-0000-0000-000000000003',
  'aaaa0000-0000-0000-0000-000000000004',
  'aaaa0000-0000-0000-0000-000000000005',
  'aaaa0000-0000-0000-0000-000000000006',
  'aaaa0000-0000-0000-0000-000000000007'
);

DELETE FROM public.services
WHERE id IN (
  'bbbb0000-0000-0000-0000-000000000001',
  'bbbb0000-0000-0000-0000-000000000002',
  'bbbb0000-0000-0000-0000-000000000003',
  'bbbb0000-0000-0000-0000-000000000004'
);

DELETE FROM public.service_categories
WHERE id IN (
  'cccc0000-0000-0000-0000-000000000001',
  'cccc0000-0000-0000-0000-000000000002',
  'cccc0000-0000-0000-0000-000000000003'
);

-- -------------------------------------
-- Seed service categories
-- -------------------------------------
INSERT INTO public.service_categories (id, name, description, icon_url, color, sort_order)
VALUES
  ('cccc0000-0000-0000-0000-000000000001', 'Cleaning', 'Professional home and office cleaning services', '/icons/cleaning.svg', '#0FA3B1', 1),
  ('cccc0000-0000-0000-0000-000000000002', 'Plumbing', 'Expert plumbing repairs and installations', '/icons/plumbing.svg', '#FF8A00', 2),
  ('cccc0000-0000-0000-0000-000000000003', 'Electrical', 'Certified electricians for installations and repairs', '/icons/electrical.svg', '#10B981', 3)
ON CONFLICT (id) DO UPDATE
  SET
    description = EXCLUDED.description,
    icon_url = EXCLUDED.icon_url,
    color = EXCLUDED.color,
    sort_order = EXCLUDED.sort_order,
    updated_at = NOW();

-- -------------------------------------
-- Seed services
-- -------------------------------------
INSERT INTO public.services (
  id,
  category_id,
  title,
  subtitle,
  description,
  rating,
  total_reviews,
  tags,
  image_url,
  is_featured,
  estimated_duration_minutes
)
VALUES
  (
    'bbbb0000-0000-0000-0000-000000000001',
    'cccc0000-0000-0000-0000-000000000001',
    'Premium Home Deep Clean',
    'Reset your home with a sparkling deep clean',
    'Floor-to-ceiling deep cleaning for apartments and villas, including appliance detailing and window treatments.',
    4.7,
    182,
    ARRAY['Deep Clean', 'Eco Friendly', 'Top Rated'],
    'https://images.ghulmil.dev/services/cleaning/deep-clean.jpg',
    TRUE,
    180
  ),
  (
    'bbbb0000-0000-0000-0000-000000000002',
    'cccc0000-0000-0000-0000-000000000001',
    'Move-In / Move-Out Cleaning',
    'Perfect for fresh beginnings or handover condition',
    'Comprehensive cleaning targeting cabinets, wardrobes, fixtures, balconies, and air vents to prepare homes for moves.',
    4.6,
    96,
    ARRAY['Move In', 'Handover', 'Detailed'],
    'https://images.ghulmil.dev/services/cleaning/move-in.jpg',
    FALSE,
    240
  ),
  (
    'bbbb0000-0000-0000-0000-000000000003',
    'cccc0000-0000-0000-0000-000000000002',
    'Emergency Plumbing Support',
    '24/7 rapid response for leaks and bursts',
    'Certified plumbers on standby for burst pipes, seepage control, drain blockages, and urgent fixture repairs.',
    4.5,
    74,
    ARRAY['Emergency', '24/7', 'Rapid Response'],
    'https://images.ghulmil.dev/services/plumbing/emergency.jpg',
    TRUE,
    90
  ),
  (
    'bbbb0000-0000-0000-0000-000000000004',
    'cccc0000-0000-0000-0000-000000000003',
    'Smart Home Electrical Setup',
    'Install and configure smart lighting & devices',
    'Licensed electricians to install smart switches, lighting, and home automation accessories with a safety audit.',
    4.8,
    128,
    ARRAY['Smart Home', 'Installation', 'Certified'],
    'https://images.ghulmil.dev/services/electrical/smart-home.jpg',
    TRUE,
    150
  )
ON CONFLICT (id) DO UPDATE
  SET
    category_id = EXCLUDED.category_id,
    subtitle = EXCLUDED.subtitle,
    description = EXCLUDED.description,
    rating = EXCLUDED.rating,
    total_reviews = EXCLUDED.total_reviews,
    tags = EXCLUDED.tags,
    image_url = EXCLUDED.image_url,
    is_featured = EXCLUDED.is_featured,
    estimated_duration_minutes = EXCLUDED.estimated_duration_minutes,
    updated_at = NOW();

-- -------------------------------------
-- Seed service packages
-- -------------------------------------
INSERT INTO public.service_packages (
  id,
  service_id,
  title,
  description,
  duration_minutes,
  base_price,
  currency,
  inclusions,
  exclusions,
  is_popular,
  sort_order
)
VALUES
  (
    'aaaa0000-0000-0000-0000-000000000001',
    'bbbb0000-0000-0000-0000-000000000001',
    'Essentials Deep Clean',
    'Bedrooms, bathrooms, kitchen, and living area deep cleaning with eco-friendly supplies.',
    180,
    89.99,
    'USD',
    ARRAY['Kitchen degreasing', 'Bathroom sanitizing', 'Dusting & vacuuming'],
    ARRAY['Outdoor areas', 'Laundry services'],
    TRUE,
    1
  ),
  (
    'aaaa0000-0000-0000-0000-000000000002',
    'bbbb0000-0000-0000-0000-000000000001',
    'Luxury Shine Upgrade',
    'Adds balcony wash, appliance detailing, and premium floor polishing for high-touch finishes.',
    240,
    149.00,
    'USD',
    ARRAY['Floor polishing', 'Appliance detailing', 'Balcony wash'],
    ARRAY['Carpet shampooing'],
    FALSE,
    2
  ),
  (
    'aaaa0000-0000-0000-0000-000000000003',
    'bbbb0000-0000-0000-0000-000000000002',
    'Move Prep Standard',
    'Surface cleaning and sanitisation for homes before move-in.',
    210,
    129.00,
    'USD',
    ARRAY['Cabinet wipe-down', 'Surface disinfecting', 'Floor scrubbing'],
    ARRAY['Furniture assembly'],
    TRUE,
    1
  ),
  (
    'aaaa0000-0000-0000-0000-000000000004',
    'bbbb0000-0000-0000-0000-000000000003',
    'Leak Fix Express',
    'Rapid leak detection and sealing with 30-day workmanship guarantee.',
    90,
    79.00,
    'USD',
    ARRAY['Leak inspection', 'Sealant application', 'Pressure testing'],
    ARRAY['Major pipe replacement'],
    TRUE,
    1
  ),
  (
    'aaaa0000-0000-0000-0000-000000000005',
    'bbbb0000-0000-0000-0000-000000000003',
    'Fixture Replacement Pro',
    'Replacement of faucets, shower heads, or basic fixtures (customer supplies hardware).',
    75,
    59.00,
    'USD',
    ARRAY['Fixture installation', 'Seal replacement', 'Leak test'],
    ARRAY['Fixture cost'],
    FALSE,
    2
  ),
  (
    'aaaa0000-0000-0000-0000-000000000006',
    'bbbb0000-0000-0000-0000-000000000004',
    'Smart Lighting Starter',
    'Install up to 6 smart switches and pair with existing assistants.',
    150,
    129.00,
    'USD',
    ARRAY['Switch installation', 'Device pairing', 'Basic usage training'],
    ARRAY['Hardware cost'],
    TRUE,
    1
  ),
  (
    'aaaa0000-0000-0000-0000-000000000007',
    'bbbb0000-0000-0000-0000-000000000004',
    'Automation Master Package',
    'Custom scenes, energy optimisation, and multi-room setup for smart devices.',
    210,
    199.00,
    'USD',
    ARRAY['Scene configuration', 'Energy audit', 'Mobile app walkthrough'],
    ARRAY['Additional hardware'],
    FALSE,
    2
  )
ON CONFLICT (id) DO UPDATE
  SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    duration_minutes = EXCLUDED.duration_minutes,
    base_price = EXCLUDED.base_price,
    currency = EXCLUDED.currency,
    inclusions = EXCLUDED.inclusions,
    exclusions = EXCLUDED.exclusions,
    is_popular = EXCLUDED.is_popular,
    sort_order = EXCLUDED.sort_order,
    updated_at = NOW();

COMMIT;

-- =====================================
-- End of dummy data seed
-- =====================================
