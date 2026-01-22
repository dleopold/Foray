import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const _PlaceholderScreen(title: 'Home'),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const _PlaceholderScreen(title: 'Login'),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Register'),
      ),
      GoRoute(
        path: AppRoutes.createForay,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Create Foray'),
      ),
      GoRoute(
        path: AppRoutes.joinForay,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Join Foray'),
      ),
      GoRoute(
        path: AppRoutes.forayDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _PlaceholderScreen(title: 'Foray: $id');
        },
      ),
      GoRoute(
        path: AppRoutes.createObservation,
        builder: (context, state) {
          final forayId = state.pathParameters['forayId']!;
          return _PlaceholderScreen(title: 'New Observation (Foray: $forayId)');
        },
      ),
      GoRoute(
        path: AppRoutes.observationDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _PlaceholderScreen(title: 'Observation: $id');
        },
      ),
      GoRoute(
        path: AppRoutes.navigate,
        builder: (context, state) {
          final observationId = state.pathParameters['observationId']!;
          return _PlaceholderScreen(title: 'Navigate to: $observationId');
        },
      ),
      GoRoute(
        path: AppRoutes.personalMap,
        builder: (context, state) => const _PlaceholderScreen(title: 'My Map'),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Settings'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});

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
