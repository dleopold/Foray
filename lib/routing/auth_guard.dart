import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/auth_state.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import 'routes.dart';

/// Routes that require full authentication (not anonymous).
const _authRequiredRoutes = <String>{
  AppRoutes.createForay, // Group foray creation
  AppRoutes.joinForay, // Joining forays
};

/// Routes that should redirect to home if already authenticated.
const _authRoutes = <String>{
  AppRoutes.login,
  AppRoutes.register,
};

/// Creates a redirect function for GoRouter that handles auth guards.
///
/// Usage in router:
/// ```dart
/// GoRouter(
///   redirect: authGuard(ref),
///   ...
/// )
/// ```
String? Function(BuildContext, GoRouterState) authGuard(Ref ref) {
  return (context, state) {
    final authState = ref.read(authControllerProvider);
    final currentPath = state.uri.path;

    // Still loading - don't redirect yet
    if (authState.status == AppAuthStatus.initial ||
        authState.status == AppAuthStatus.loading) {
      return null;
    }

    final isAuthenticated = authState.isAuthenticated;
    final isAuthRoute = _authRoutes.contains(currentPath);
    final requiresAuth = _authRequiredRoutes.contains(currentPath);

    // If authenticated and trying to access auth routes, redirect to home
    if (isAuthenticated && isAuthRoute) {
      return AppRoutes.home;
    }

    // If not authenticated and trying to access protected routes
    if (!isAuthenticated && requiresAuth) {
      // Store the intended destination for after login
      return '${AppRoutes.login}?redirect=${Uri.encodeComponent(currentPath)}';
    }

    return null; // No redirect needed
  };
}

/// Provider for checking if a route requires authentication.
final routeRequiresAuthProvider = Provider.family<bool, String>((ref, route) {
  return _authRequiredRoutes.contains(route);
});

/// Provider for the post-login redirect URL.
///
/// Use this to redirect users back to their intended destination after login.
final postLoginRedirectProvider = StateProvider<String?>((ref) => null);

/// Helper to handle post-login redirect.
///
/// Call this after successful login to navigate to the stored redirect URL
/// or the default home route.
String getPostLoginRedirect(WidgetRef ref) {
  final redirect = ref.read(postLoginRedirectProvider);
  // Clear the stored redirect
  ref.read(postLoginRedirectProvider.notifier).state = null;
  return redirect ?? AppRoutes.home;
}
