-- Migration: Create core tables for Foray app
-- Date: 2026-01-22
-- Phase: 9 - Sync System

-- ============================================================================
-- Users Table
-- ============================================================================
-- Stores user profiles. Synced from Supabase Auth on registration.
-- Anonymous local users are NOT synced here - they live only in local Drift DB.

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  display_name TEXT NOT NULL,
  email TEXT UNIQUE,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE users IS 'User profiles for authenticated users';
COMMENT ON COLUMN users.id IS 'Matches Supabase Auth user ID';

-- ============================================================================
-- Forays Table
-- ============================================================================
-- A foray is a collection event/expedition. Can be solo or group.

CREATE TABLE IF NOT EXISTS forays (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL CHECK (char_length(name) >= 1 AND char_length(name) <= 200),
  description TEXT,
  date DATE NOT NULL,
  location_name TEXT,
  default_privacy TEXT NOT NULL DEFAULT 'private' 
    CHECK (default_privacy IN ('private', 'foray', 'publicExact', 'publicObscured')),
  join_code CHAR(6) UNIQUE,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed')),
  is_solo BOOLEAN NOT NULL DEFAULT false,
  observations_locked BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE forays IS 'Collection events/expeditions';
COMMENT ON COLUMN forays.join_code IS '6-character code for joining group forays';
COMMENT ON COLUMN forays.is_solo IS 'True for personal/solo forays';
COMMENT ON COLUMN forays.observations_locked IS 'When true, no new observations or edits allowed';

-- ============================================================================
-- Foray Participants Table
-- ============================================================================
-- Junction table linking users to forays with their role.

CREATE TABLE IF NOT EXISTS foray_participants (
  foray_id UUID NOT NULL REFERENCES forays(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'participant' CHECK (role IN ('organizer', 'participant')),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (foray_id, user_id)
);

COMMENT ON TABLE foray_participants IS 'Maps users to forays with their role';
COMMENT ON COLUMN foray_participants.role IS 'organizer has full control, participant has limited permissions';

-- ============================================================================
-- Observations Table
-- ============================================================================
-- Core entity: a single fungal find/collection with location and metadata.

CREATE TABLE IF NOT EXISTS observations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  foray_id UUID NOT NULL REFERENCES forays(id) ON DELETE CASCADE,
  collector_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Location data
  latitude DOUBLE PRECISION NOT NULL CHECK (latitude >= -90 AND latitude <= 90),
  longitude DOUBLE PRECISION NOT NULL CHECK (longitude >= -180 AND longitude <= 180),
  gps_accuracy DOUBLE PRECISION CHECK (gps_accuracy >= 0),
  altitude DOUBLE PRECISION,
  
  -- Privacy
  privacy_level TEXT NOT NULL DEFAULT 'private'
    CHECK (privacy_level IN ('private', 'foray', 'publicExact', 'publicObscured')),
  
  -- Timestamps
  observed_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Specimen tracking
  specimen_id TEXT,
  collection_number TEXT,
  
  -- Field data
  substrate TEXT,
  habitat_notes TEXT,
  field_notes TEXT,
  spore_print_color TEXT,
  
  -- Preliminary identification by collector
  preliminary_id TEXT,
  preliminary_id_confidence TEXT CHECK (
    preliminary_id_confidence IS NULL OR 
    preliminary_id_confidence IN ('guess', 'likely', 'confident')
  )
);

COMMENT ON TABLE observations IS 'Fungal finds/collections with location and metadata';
COMMENT ON COLUMN observations.privacy_level IS 'Controls visibility: private (creator only), foray (participants), publicExact, publicObscured (10km blur)';
COMMENT ON COLUMN observations.specimen_id IS 'Physical specimen ID for barcode/QR lookup';

-- ============================================================================
-- Photos Table
-- ============================================================================
-- Images attached to observations. Stored in Supabase Storage.

CREATE TABLE IF NOT EXISTS photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  observation_id UUID NOT NULL REFERENCES observations(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  url TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  caption TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE photos IS 'Photos attached to observations';
COMMENT ON COLUMN photos.storage_path IS 'Path in Supabase Storage bucket';
COMMENT ON COLUMN photos.url IS 'Public URL for the photo';
COMMENT ON COLUMN photos.sort_order IS '0 = primary photo';

-- ============================================================================
-- Identifications Table
-- ============================================================================
-- Species IDs proposed by users for observations. Voted on by participants.

CREATE TABLE IF NOT EXISTS identifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  observation_id UUID NOT NULL REFERENCES observations(id) ON DELETE CASCADE,
  identifier_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  species_name TEXT NOT NULL,
  common_name TEXT,
  confidence TEXT NOT NULL DEFAULT 'likely' CHECK (confidence IN ('guess', 'likely', 'confident')),
  notes TEXT,
  vote_count INTEGER NOT NULL DEFAULT 0 CHECK (vote_count >= 0),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE identifications IS 'Species identifications proposed for observations';
COMMENT ON COLUMN identifications.vote_count IS 'Denormalized count for efficient sorting';

-- ============================================================================
-- Identification Votes Table
-- ============================================================================
-- Votes for identifications. Each user can vote once per observation.

CREATE TABLE IF NOT EXISTS identification_votes (
  identification_id UUID NOT NULL REFERENCES identifications(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  voted_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (identification_id, user_id)
);

COMMENT ON TABLE identification_votes IS 'User votes for identifications';

-- ============================================================================
-- Comments Table
-- ============================================================================
-- Discussion comments on observations. Flat structure (no threading).

CREATE TABLE IF NOT EXISTS comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  observation_id UUID NOT NULL REFERENCES observations(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL CHECK (char_length(content) >= 1 AND char_length(content) <= 2000),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE comments IS 'Discussion comments on observations';
