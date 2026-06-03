-- Migration: Create pricing_configs table for Ghulmil application
-- Paste and run this in your Supabase Dashboard SQL Editor

-- 1. Create the table
CREATE TABLE IF NOT EXISTS public.pricing_configs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_type VARCHAR(50) UNIQUE NOT NULL, -- 'civil', 'electrical', 'plumbing', 'carpentry', 'painting', 'flooring'
    base_rate NUMERIC(10, 2) NOT NULL DEFAULT 1000.00,
    mistri_daily_wage NUMERIC(10, 2) NOT NULL DEFAULT 800.00,
    beldar_daily_wage NUMERIC(10, 2) NOT NULL DEFAULT 450.00,
    material_coefficient NUMERIC(5, 2) NOT NULL DEFAULT 1.00,
    additional_meta JSONB NOT NULL DEFAULT '{}'::jsonb, -- specialized parameters
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_by UUID REFERENCES auth.users(id)
);

-- 2. Add indexing for optimized service-type lookups
CREATE INDEX IF NOT EXISTS idx_pricing_configs_service_type ON public.pricing_configs(service_type);

-- 3. Insert default pricing configuration corresponding to Launch requirements in Pithoragarh
INSERT INTO public.pricing_configs (service_type, base_rate, mistri_daily_wage, beldar_daily_wage, material_coefficient, additional_meta)
VALUES
  ('electrical', 800.00, 750.00, 450.00, 1.00, '{"rough_in_material_rate": 120.00, "finish_material_rate": 70.00, "rough_in_labor_rate": 50.00, "finish_labor_rate": 30.00}'),
  ('plumbing', 900.00, 800.00, 450.00, 1.00, '{"concealed_material_rate": 1500.00, "exposed_material_rate": 800.00, "concealed_labor_rate": 600.00, "exposed_labor_rate": 350.00}'),
  ('carpentry', 1500.00, 850.00, 450.00, 1.00, '{"wardrobe_material_rate": 180.00, "other_material_rate": 250.00, "wardrobe_labor_rate": 60.00, "other_labor_rate": 80.00}'),
  ('painting', 1000.00, 800.00, 450.00, 1.00, '{"fresh_premium_rate": 12.00, "fresh_standard_rate": 6.00, "repaint_premium_rate": 8.00, "repaint_standard_rate": 4.00, "labor_only_rate": 3.00}'),
  ('flooring', 1200.00, 900.00, 450.00, 1.00, '{"marble_material_rate": 4.50, "tiles_material_rate": 2.00, "labor_only_rate": 1.20, "mirror_polish_material_premium": 2.50, "mirror_polish_labor_premium": 1.50}'),
  ('civil', 1200.00, 800.00, 450.00, 1.00, '{"material_rate_premium": 2.50, "material_rate_semi_premium": 1.50, "material_rate_standard": 1.00, "labor_factor": 0.45}')
ON CONFLICT (service_type) DO UPDATE 
SET 
  base_rate = EXCLUDED.base_rate,
  mistri_daily_wage = EXCLUDED.mistri_daily_wage,
  beldar_daily_wage = EXCLUDED.beldar_daily_wage,
  material_coefficient = EXCLUDED.material_coefficient,
  additional_meta = EXCLUDED.additional_meta,
  updated_at = timezone('utc'::text, now());

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.pricing_configs ENABLE ROW LEVEL SECURITY;

-- 5. Drop policies if they exist to allow clean re-runs
DROP POLICY IF EXISTS "Allow public read access to pricing_configs" ON public.pricing_configs;
DROP POLICY IF EXISTS "Restrict write access to admin users only" ON public.pricing_configs;

-- 6. Create Select policy: everyone can read pricing configurations
CREATE POLICY "Allow public read access to pricing_configs"
ON public.pricing_configs FOR SELECT
TO public
USING (true);

-- 7. Create Write policies: only user_type = 'admin' in public.users table can insert/update/delete configs
CREATE POLICY "Restrict write access to admin users only"
ON public.pricing_configs FOR ALL
TO authenticated
USING (
  (SELECT user_type FROM public.users WHERE id = auth.uid()) = 'admin'
)
WITH CHECK (
  (SELECT user_type FROM public.users WHERE id = auth.uid()) = 'admin'
);
