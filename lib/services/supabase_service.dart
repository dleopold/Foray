import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides the Supabase client instance.
///
/// The client is initialized in main.dart before the app starts.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provides the Supabase auth client.
///
/// Use this for all authentication operations.
final supabaseAuthProvider = Provider<GoTrueClient>((ref) {
  return ref.watch(supabaseClientProvider).auth;
});

/// Provides the current Supabase session.
///
/// Returns null if not authenticated.
final supabaseSessionProvider = Provider<Session?>((ref) {
  return ref.watch(supabaseClientProvider).auth.currentSession;
});

/// Provides the current Supabase user.
///
/// Returns null if not authenticated.
final supabaseUserProvider = Provider<User?>((ref) {
  return ref.watch(supabaseSessionProvider)?.user;
});
