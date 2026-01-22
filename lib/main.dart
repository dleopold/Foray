import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } else if (kDebugMode) {
    // In debug mode, warn about missing configuration
    debugPrint(
      'WARNING: Supabase not configured. '
      'Set SUPABASE_URL and SUPABASE_ANON_KEY environment variables '
      'or use --dart-define flags. '
      'Running in offline-only mode.',
    );
  }

  runApp(
    const ProviderScope(
      child: ForayApp(),
    ),
  );
}
