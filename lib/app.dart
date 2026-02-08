import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'routing/router.dart';
import 'services/sync/sync_queue_processor.dart';

class ForayApp extends ConsumerStatefulWidget {
  const ForayApp({super.key});

  @override
  ConsumerState<ForayApp> createState() => _ForayAppState();
}

class _ForayAppState extends ConsumerState<ForayApp> {
  @override
  void initState() {
    super.initState();
    // Start the sync queue processor when the app launches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncQueueProcessorProvider).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Foray',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
