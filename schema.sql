-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Define Custom ENUM Types
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('farmer', 'agronomist', 'admin');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE irrigation_type AS ENUM ('rainfed', 'drip', 'sprinkler', 'flood', 'center_pivot');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE soil_texture AS ENUM (
      'sandy', 'loamy_sand', 'sandy_loam', 'loam', 'silt_loam', 
      'silt', 'clay_loam', 'sandy_clay', 'silty_clay', 'heavy_clay'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE advisory_status AS ENUM ('draft', 'generated', 'applied', 'archived');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 1. Users Table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    phone_number VARCHAR(30),
    role user_role DEFAULT 'farmer' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- 2. Farm Parcels Table
CREATE TABLE IF NOT EXISTS farm_parcels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    size_in_hectares NUMERIC(8, 2) NOT NULL CHECK (size_in_hectares > 0),
    latitude NUMERIC(9, 6),
    longitude NUMERIC(9, 6),
    soil_texture soil_texture NOT NULL,
    irrigation irrigation_type NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- 3. Soil Test Records
CREATE TABLE IF NOT EXISTS soil_tests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parcel_id UUID NOT NULL REFERENCES farm_parcels(id) ON DELETE CASCADE,
    test_date DATE NOT NULL,
    ph_level NUMERIC(4, 2) NOT NULL CHECK (ph_level BETWEEN 2.0 AND 12.0),
    electrical_conductivity NUMERIC(6, 2), -- dS/m
    organic_carbon_percentage NUMERIC(5, 2),
    nitrogen_kg_per_ha NUMERIC(7, 2) NOT NULL,
    phosphorus_kg_per_ha NUMERIC(7, 2) NOT NULL,
    potassium_kg_per_ha NUMERIC(7, 2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- 4. Agronomic Advisories Table
CREATE TABLE IF NOT EXISTS advisories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parcel_id UUID REFERENCES farm_parcels(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    crop_name VARCHAR(100) NOT NULL,
    crop_stage VARCHAR(100) NOT NULL,
    season VARCHAR(50) NOT NULL,
    input_payload JSONB NOT NULL,
    advisory_output JSONB NOT NULL,
    status advisory_status DEFAULT 'generated' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- 5. Field Action Log (Tracking implementation of steps)
CREATE TABLE IF NOT EXISTS advisory_action_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    advisory_id UUID NOT NULL REFERENCES advisories(id) ON DELETE CASCADE,
    phase_title VARCHAR(150) NOT NULL,
    action_type VARCHAR(50) NOT NULL, -- e.g., 'fertilizer', 'irrigation', 'spray'
    instruction TEXT NOT NULL,
    target_date DATE,
    is_completed BOOLEAN DEFAULT FALSE NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Indexes for high-frequency queries
CREATE INDEX IF NOT EXISTS idx_parcels_user ON farm_parcels(user_id);
CREATE INDEX IF NOT EXISTS idx_soil_tests_parcel ON soil_tests(parcel_id);
CREATE INDEX IF NOT EXISTS idx_advisories_user ON advisories(user_id);
CREATE INDEX IF NOT EXISTS idx_advisories_parcel ON advisories(parcel_id);
CREATE INDEX IF NOT EXISTS idx_advisories_created ON advisories(created_at DESC);
