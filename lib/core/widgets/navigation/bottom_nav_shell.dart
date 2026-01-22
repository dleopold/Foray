import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';

/// Provider to track the current navigation tab index.
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Navigation destinations for the bottom navigation bar.
enum NavDestination {
  forays(
    label: 'Forays',
    icon: Icons.explore_outlined,
    selectedIcon: Icons.explore,
    route: '/',
  ),
  map(
    label: 'Map',
    icon: Icons.map_outlined,
    selectedIcon: Icons.map,
    route: '/map',
  ),
  settings(
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    route: '/settings',
  );

  const NavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
}

/// A scaffold shell with bottom navigation for main app screens.
///
/// Wraps child screens and provides consistent bottom navigation.
/// Use with GoRouter's ShellRoute for nested navigation.
///
/// Example:
/// ```dart
/// ShellRoute(
///   builder: (context, state, child) => BottomNavShell(child: child),
///   routes: [...],
/// )
/// ```
class BottomNavShell extends ConsumerWidget {
  /// Creates a [BottomNavShell].
  const BottomNavShell({
    super.key,
    required this.child,
  });

  /// The child widget (current route's screen).
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
          context.go(NavDestination.values[index].route);
        },
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        indicatorColor: AppColors.primary.withOpacity(0.15),
        destinations: NavDestination.values.map((dest) {
          return NavigationDestination(
            icon: Icon(dest.icon),
            selectedIcon: Icon(
              dest.selectedIcon,
              color: AppColors.primary,
            ),
            label: dest.label,
          );
        }).toList(),
      ),
    );
  }

  /// Updates the nav index based on the current route.
  ///
  /// Call this from route observers or redirect logic to sync
  /// the bottom nav state with deep links.
  static void syncIndexFromRoute(WidgetRef ref, String route) {
    final index = NavDestination.values.indexWhere(
      (dest) => route.startsWith(dest.route) && dest.route != '/' || route == dest.route,
    );
    if (index >= 0 && index != ref.read(bottomNavIndexProvider)) {
      ref.read(bottomNavIndexProvider.notifier).state = index;
    }
  }
}

/// A FAB configuration for screens within the navigation shell.
class NavShellFab {
  const NavShellFab({
    required this.icon,
    required this.onPressed,
    this.label,
    this.extended = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final bool extended;
}

/// An extended bottom nav shell that supports a floating action button.
///
/// Useful for the main foray list screen where a "Quick Start" FAB
/// is prominently featured.
class BottomNavShellWithFab extends ConsumerWidget {
  /// Creates a [BottomNavShellWithFab].
  const BottomNavShellWithFab({
    super.key,
    required this.child,
    this.fab,
  });

  /// The child widget (current route's screen).
  final Widget child;

  /// Optional floating action button configuration.
  final NavShellFab? fab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: child,
      floatingActionButton: fab != null
          ? fab!.extended && fab!.label != null
              ? FloatingActionButton.extended(
                  onPressed: fab!.onPressed,
                  icon: Icon(fab!.icon),
                  label: Text(fab!.label!),
                )
              : FloatingActionButton(
                  onPressed: fab!.onPressed,
                  child: Icon(fab!.icon),
                )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
          context.go(NavDestination.values[index].route);
        },
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        indicatorColor: AppColors.primary.withOpacity(0.15),
        destinations: NavDestination.values.map((dest) {
          return NavigationDestination(
            icon: Icon(dest.icon),
            selectedIcon: Icon(
              dest.selectedIcon,
              color: AppColors.primary,
            ),
            label: dest.label,
          );
        }).toList(),
      ),
    );
  }
}
