/// Configuration for Supabase backend.
///
/// In production, these values should be provided via environment variables
/// using `--dart-define` flags during build:
///
/// ```bash
/// flutter build apk \
///   --dart-define=SUPABASE_URL=https://your-project.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=your-anon-key
/// ```
abstract class SupabaseConfig {
  /// Supabase project URL.
  ///
  /// Get this from your Supabase project settings.
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  /// Supabase anonymous/public key.
  ///
  /// This is safe to include in client apps - RLS protects your data.
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );

  /// OAuth redirect URL for deep linking.
  ///
  /// Must match the URL scheme configured in:
  /// - iOS: Info.plist
  /// - Android: AndroidManifest.xml
  static const String oauthRedirectUrl = 'io.foray.app://login-callback';

  /// Check if Supabase is properly configured.
  static bool get isConfigured =>
      url != 'https://your-project.supabase.co' && anonKey != 'your-anon-key';
}
