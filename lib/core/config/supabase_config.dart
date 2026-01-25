import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration for Supabase backend.
///
/// Values are read in this priority order:
/// 1. `--dart-define` flags (for production builds)
/// 2. `.env` file (for local development, not available on web)
/// 3. Default placeholder values
///
/// Production build example:
/// ```bash
/// flutter build apk \
///   --dart-define=SUPABASE_URL=https://your-project.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=your-anon-key
/// ```
abstract class SupabaseConfig {
  static const _defaultUrl = 'https://your-project.supabase.co';
  static const _defaultKey = 'your-anon-key';

  /// Helper to safely get dotenv value (not available on web).
  static String? _getDotenvValue(String key) {
    if (kIsWeb) return null;
    try {
      return dotenv.env[key];
    } catch (_) {
      return null;
    }
  }

  /// Supabase project URL.
  static String get url {
    const dartDefine = String.fromEnvironment('SUPABASE_URL');
    if (dartDefine.isNotEmpty) return dartDefine;
    return _getDotenvValue('SUPABASE_URL') ?? _defaultUrl;
  }

  /// Supabase anonymous/public key (safe for client apps - RLS protects data).
  static String get anonKey {
    const dartDefine = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (dartDefine.isNotEmpty) return dartDefine;
    return _getDotenvValue('SUPABASE_ANON_KEY') ?? _defaultKey;
  }

  /// OAuth redirect URL for deep linking.
  static const String oauthRedirectUrl = 'io.foray.app://login-callback';

   /// Whether Supabase is properly configured.
   /// On web, requires --dart-define flags at build time.
   /// On native, can use .env file or --dart-define flags.
   static bool get isConfigured =>
       url != _defaultUrl && anonKey != _defaultKey;
}
