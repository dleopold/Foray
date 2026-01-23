CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER forays_updated_at
  BEFORE UPDATE ON forays
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER observations_updated_at
  BEFORE UPDATE ON observations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE OR REPLACE FUNCTION update_identification_vote_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE identifications 
    SET vote_count = vote_count + 1 
    WHERE id = NEW.identification_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE identifications 
    SET vote_count = vote_count - 1 
    WHERE id = OLD.identification_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER votes_update_count
  AFTER INSERT OR DELETE ON identification_votes
  FOR EACH ROW EXECUTE FUNCTION update_identification_vote_count();

CREATE OR REPLACE FUNCTION get_foray_by_join_code(code TEXT)
RETURNS TABLE (
  id UUID,
  name TEXT,
  date DATE,
  location_name TEXT,
  creator_display_name TEXT,
  participant_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    f.id,
    f.name,
    f.date,
    f.location_name,
    u.display_name as creator_display_name,
    COUNT(fp.user_id) as participant_count
  FROM forays f
  JOIN users u ON u.id = f.creator_id
  LEFT JOIN foray_participants fp ON fp.foray_id = f.id
  WHERE f.join_code = code AND f.status = 'active'
  GROUP BY f.id, f.name, f.date, f.location_name, u.display_name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
