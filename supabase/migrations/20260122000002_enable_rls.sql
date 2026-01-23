-- Enable Row Level Security and create policies for privacy model

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE forays ENABLE ROW LEVEL SECURITY;
ALTER TABLE foray_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE observations ENABLE ROW LEVEL SECURITY;
ALTER TABLE photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE identifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE identification_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- ===================
-- USERS POLICIES
-- ===================

CREATE POLICY "users_select_all" ON users
  FOR SELECT USING (true);

CREATE POLICY "users_insert_self" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "users_update_self" ON users
  FOR UPDATE USING (auth.uid() = id);

-- ===================
-- FORAYS POLICIES
-- ===================

CREATE POLICY "forays_select_participant" ON forays
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM foray_participants 
      WHERE foray_participants.foray_id = forays.id 
      AND foray_participants.user_id = auth.uid()
    )
  );

CREATE POLICY "forays_insert_authenticated" ON forays
  FOR INSERT WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "forays_update_creator" ON forays
  FOR UPDATE USING (auth.uid() = creator_id);

CREATE POLICY "forays_delete_creator" ON forays
  FOR DELETE USING (auth.uid() = creator_id);

-- ===================
-- FORAY PARTICIPANTS POLICIES
-- ===================

CREATE POLICY "participants_select_member" ON foray_participants
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM foray_participants fp
      WHERE fp.foray_id = foray_participants.foray_id 
      AND fp.user_id = auth.uid()
    )
  );

CREATE POLICY "participants_insert_self_or_creator" ON foray_participants
  FOR INSERT WITH CHECK (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM forays 
      WHERE forays.id = foray_id 
      AND forays.creator_id = auth.uid()
    )
  );

CREATE POLICY "participants_delete_creator" ON foray_participants
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM forays 
      WHERE forays.id = foray_id 
      AND forays.creator_id = auth.uid()
    )
  );

-- ===================
-- OBSERVATIONS POLICIES (privacy-aware)
-- ===================

CREATE POLICY "observations_select_privacy" ON observations
  FOR SELECT USING (
    privacy_level IN ('publicExact', 'publicObscured')
    OR collector_id = auth.uid()
    OR (
      privacy_level IN ('foray', 'private') 
      AND EXISTS (
        SELECT 1 FROM foray_participants 
        WHERE foray_participants.foray_id = observations.foray_id 
        AND foray_participants.user_id = auth.uid()
      )
    )
  );

CREATE POLICY "observations_insert_participant" ON observations
  FOR INSERT WITH CHECK (
    collector_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM foray_participants 
      WHERE foray_participants.foray_id = observations.foray_id 
      AND foray_participants.user_id = auth.uid()
    )
  );

CREATE POLICY "observations_update_collector" ON observations
  FOR UPDATE USING (collector_id = auth.uid());

CREATE POLICY "observations_delete_organizer" ON observations
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM forays 
      WHERE forays.id = foray_id 
      AND forays.creator_id = auth.uid()
    )
  );

-- ===================
-- PHOTOS POLICIES
-- ===================

CREATE POLICY "photos_select_with_observation" ON photos
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM observations 
      WHERE observations.id = photos.observation_id
    )
  );

CREATE POLICY "photos_insert_observation_owner" ON photos
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM observations 
      WHERE observations.id = observation_id 
      AND observations.collector_id = auth.uid()
    )
  );

CREATE POLICY "photos_delete_observation_owner" ON photos
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM observations 
      WHERE observations.id = observation_id 
      AND observations.collector_id = auth.uid()
    )
  );

-- ===================
-- IDENTIFICATIONS POLICIES
-- ===================

CREATE POLICY "identifications_select_participant" ON identifications
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM observations o
      JOIN foray_participants fp ON fp.foray_id = o.foray_id
      WHERE o.id = identifications.observation_id 
      AND fp.user_id = auth.uid()
    )
  );

CREATE POLICY "identifications_insert_participant" ON identifications
  FOR INSERT WITH CHECK (
    identifier_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM observations o
      JOIN foray_participants fp ON fp.foray_id = o.foray_id
      WHERE o.id = observation_id 
      AND fp.user_id = auth.uid()
    )
  );

CREATE POLICY "identifications_delete_owner_or_organizer" ON identifications
  FOR DELETE USING (
    identifier_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM observations o
      JOIN forays f ON f.id = o.foray_id
      WHERE o.id = observation_id 
      AND f.creator_id = auth.uid()
    )
  );

-- ===================
-- VOTES POLICIES
-- ===================

CREATE POLICY "votes_select_participant" ON identification_votes
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM identifications i
      JOIN observations o ON o.id = i.observation_id
      JOIN foray_participants fp ON fp.foray_id = o.foray_id
      WHERE i.id = identification_votes.identification_id 
      AND fp.user_id = auth.uid()
    )
  );

CREATE POLICY "votes_insert_self" ON identification_votes
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "votes_delete_self" ON identification_votes
  FOR DELETE USING (user_id = auth.uid());

-- ===================
-- COMMENTS POLICIES
-- ===================

CREATE POLICY "comments_select_participant" ON comments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM observations o
      JOIN foray_participants fp ON fp.foray_id = o.foray_id
      WHERE o.id = comments.observation_id 
      AND fp.user_id = auth.uid()
    )
  );

CREATE POLICY "comments_insert_participant" ON comments
  FOR INSERT WITH CHECK (
    author_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM observations o
      JOIN foray_participants fp ON fp.foray_id = o.foray_id
      WHERE o.id = observation_id 
      AND fp.user_id = auth.uid()
    )
  );

CREATE POLICY "comments_delete_owner_or_organizer" ON comments
  FOR DELETE USING (
    author_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM observations o
      JOIN forays f ON f.id = o.foray_id
      WHERE o.id = observation_id 
      AND f.creator_id = auth.uid()
    )
  );
