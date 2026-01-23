CREATE INDEX IF NOT EXISTS idx_forays_creator ON forays(creator_id);
CREATE INDEX IF NOT EXISTS idx_forays_join_code ON forays(join_code) WHERE join_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_forays_date ON forays(date);

CREATE INDEX IF NOT EXISTS idx_observations_foray ON observations(foray_id);
CREATE INDEX IF NOT EXISTS idx_observations_collector ON observations(collector_id);
CREATE INDEX IF NOT EXISTS idx_observations_observed_at ON observations(observed_at);
CREATE INDEX IF NOT EXISTS idx_observations_privacy ON observations(privacy_level);

CREATE INDEX IF NOT EXISTS idx_photos_observation ON photos(observation_id);
CREATE INDEX IF NOT EXISTS idx_photos_sort ON photos(observation_id, sort_order);

CREATE INDEX IF NOT EXISTS idx_identifications_observation ON identifications(observation_id);
CREATE INDEX IF NOT EXISTS idx_identifications_votes ON identifications(observation_id, vote_count DESC);

CREATE INDEX IF NOT EXISTS idx_comments_observation ON comments(observation_id);
CREATE INDEX IF NOT EXISTS idx_comments_created ON comments(observation_id, created_at);
