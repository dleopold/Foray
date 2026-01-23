INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'photos',
  'photos',
  true,
  10485760,
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "photos_upload_authenticated" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'photos' AND (storage.foldername(name))[1] = 'observations');

CREATE POLICY "photos_read_public" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'photos');

CREATE POLICY "photos_delete_owner" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'photos' 
    AND auth.uid()::text = (storage.foldername(name))[2]
  );
