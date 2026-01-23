import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/dev/component_showcase_screen.dart';
import '../features/forays/presentation/screens/create_foray_screen.dart';
import '../features/forays/presentation/screens/foray_detail_screen.dart';
import '../features/forays/presentation/screens/foray_list_screen.dart';
import '../features/forays/presentation/screens/join_foray_screen.dart';
import '../features/maps/presentation/screens/personal_map_screen.dart';
import '../features/navigation/presentation/screens/compass_navigation_screen.dart';
import '../features/observations/presentation/screens/observation_detail_screen.dart';
import '../features/observations/presentation/screens/observation_entry_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import 'auth_guard.dart';
import 'routes.dart';
import 'transitions.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    // Apply auth guard to all routes
    redirect: authGuard(ref),
    // Refresh router when auth state changes
    refreshListenable: _AuthStateNotifier(ref),
    routes: [
      // Home - Foray List
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const ForayListScreen(),
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Foray routes
      GoRoute(
        path: AppRoutes.createForay,
        pageBuilder: (context, state) => AppTransitions.slideUp(
          context: context,
          state: state,
          child: const CreateForayScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.joinForay,
        pageBuilder: (context, state) => AppTransitions.slideUp(
          context: context,
          state: state,
          child: const JoinForayScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forayDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppTransitions.slideRight(
            context: context,
            state: state,
            child: ForayDetailScreen(forayId: id),
          );
        },
      ),

      // Observation routes
      GoRoute(
        path: AppRoutes.createObservation,
        pageBuilder: (context, state) {
          final forayId = state.pathParameters['forayId']!;
          return AppTransitions.slideUp(
            context: context,
            state: state,
            child: ObservationEntryScreen(forayId: forayId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.observationDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppTransitions.slideRight(
            context: context,
            state: state,
            child: ObservationDetailScreen(observationId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.editObservation,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppTransitions.slideUp(
            context: context,
            state: state,
            child: ObservationEntryScreen(
              forayId: '', // Will be loaded from observation
              observationId: id,
            ),
          );
        },
      ),

      // Navigation route
      GoRoute(
        path: AppRoutes.navigate,
        pageBuilder: (context, state) {
          final observationId = state.pathParameters['observationId']!;
          return AppTransitions.scaleFade(
            context: context,
            state: state,
            child: CompassNavigationScreen(observationId: observationId),
          );
        },
      ),

      // Map route
      GoRoute(
        path: AppRoutes.personalMap,
        pageBuilder: (context, state) => AppTransitions.fade(
          context: context,
          state: state,
          child: const PersonalMapScreen(),
        ),
      ),

      // Settings
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => AppTransitions.slideUp(
          context: context,
          state: state,
          child: const SettingsScreen(),
        ),
      ),

      // Development routes
      GoRoute(
        path: AppRoutes.devComponents,
        builder: (context, state) => const ComponentShowcaseScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});

/// Notifier that triggers router refresh when auth state changes.
class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier(this._ref) {
    _ref.listen(authControllerProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
