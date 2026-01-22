import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../routing/routes.dart';
import 'avatars/foray_avatar.dart';

/// An app bar action that shows auth status.
///
/// Shows a sign in button for anonymous users, or an avatar
/// for authenticated users that navigates to settings.
class AuthAppBarAction extends ConsumerWidget {
  const AuthAppBarAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (authState.isAuthenticated) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ForayAvatar(
          imageUrl: authState.user?.avatarUrl,
          initials: _getInitials(authState.user?.displayName),
          size: ForayAvatarSize.small,
          onTap: () => context.push(AppRoutes.settings),
        ),
      );
    } else {
      return TextButton(
        onPressed: () => context.push(AppRoutes.login),
        child: const Text('Sign In'),
      );
    }
  }

  String? _getInitials(String? name) {
    if (name == null || name.isEmpty) return null;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return null;
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : null;
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

/// A chip showing the current auth status.
///
/// Useful for displaying sync capability status.
class AuthStatusChip extends ConsumerWidget {
  const AuthStatusChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    if (authState.isAuthenticated) {
      return Chip(
        avatar: const Icon(Icons.cloud_done, size: 18),
        label: const Text('Synced'),
        backgroundColor: theme.colorScheme.primaryContainer,
        labelStyle: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontSize: 12,
        ),
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    } else {
      return GestureDetector(
        onTap: () => context.push(AppRoutes.login),
        child: Chip(
          avatar: Icon(
            Icons.cloud_off,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          label: const Text('Local only'),
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          labelStyle: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }
  }
}
