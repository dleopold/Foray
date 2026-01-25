import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';

/// Whether Supabase is available (configured AND initialized).
///
/// Returns true when Supabase credentials are provided via --dart-define or .env file.
bool get isSupabaseAvailable =>
    SupabaseConfig.isConfigured;

/// Provides the Supabase client instance.
///
/// Returns null if Supabase is not configured.
/// The client is initialized in main.dart before the app starts.
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  if (!isSupabaseAvailable) return null;
  return Supabase.instance.client;
});

/// Provides the Supabase auth client.
///
/// Returns null if Supabase is not available.
/// Use this for all authentication operations.
final supabaseAuthProvider = Provider<GoTrueClient?>((ref) {
  return ref.watch(supabaseClientProvider)?.auth;
});

/// Provides the current Supabase session.
///
/// Returns null if not authenticated or Supabase not available.
final supabaseSessionProvider = Provider<Session?>((ref) {
  return ref.watch(supabaseClientProvider)?.auth.currentSession;
});

/// Provides the current Supabase user.
///
/// Returns null if not authenticated or Supabase not available.
final supabaseUserProvider = Provider<User?>((ref) {
  return ref.watch(supabaseSessionProvider)?.user;
});
