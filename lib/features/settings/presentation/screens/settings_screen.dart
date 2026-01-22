import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/avatars/foray_avatar.dart';
import '../../../../routing/routes.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/widgets/upgrade_prompt.dart';

/// Settings screen with profile management and app preferences.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profile Section
          _buildProfileSection(context, ref, authState, theme),

          const Divider(height: 1),

          // Account Section
          _buildAccountSection(context, ref, authState, theme),

          const Divider(height: 1),

          // Preferences Section
          _buildPreferencesSection(context, ref, theme),

          const Divider(height: 1),

          // About Section
          _buildAboutSection(context, theme),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    WidgetRef ref,
    AppAuthState authState,
    ThemeData theme,
  ) {
    final user = authState.user;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              ForayAvatar(
                imageUrl: user?.avatarUrl,
                initials: _getInitials(user?.displayName),
                size: ForayAvatarSize.large,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Guest User',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    if (user?.email != null)
                      Text(
                        user!.email!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.7),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Icon(
                            Icons.cloud_off,
                            size: 14,
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Local only',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (authState.isAuthenticated)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showEditProfileDialog(context, ref, user),
                ),
            ],
          ),
          if (!authState.isAuthenticated) ...[
            const SizedBox(height: AppSpacing.md),
            const UpgradePrompt(
              message: 'Sign in to sync your data across devices '
                  'and join group forays.',
              compact: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountSection(
    BuildContext context,
    WidgetRef ref,
    AppAuthState authState,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text(
            'Account',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        if (authState.isAuthenticated) ...[
        ListTile(
          leading: const Icon(Icons.sync),
          title: const Text('Sync Status'),
          subtitle: const Text('All data synced'),
          trailing: const Icon(
            Icons.cloud_done,
            color: AppColors.success,
          ),
        ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () => _showSignOutDialog(context, ref),
          ),
        ] else ...[
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Sign In'),
            subtitle: const Text('Access your account'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.login),
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Create Account'),
            subtitle: const Text('Sync and collaborate'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.register),
          ),
        ],
      ],
    );
  }

  Widget _buildPreferencesSection(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text(
            'Preferences',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: const Text('Dark Mode'),
          trailing: Switch(
            value: theme.brightness == Brightness.dark,
            onChanged: (value) {
              // TODO: Implement theme toggle
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.straighten),
          title: const Text('Distance Units'),
          subtitle: const Text('Metric (km, m)'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Show units picker
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('Default Privacy'),
          subtitle: const Text('Private'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Show privacy picker
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text(
            'About',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Version'),
          subtitle: const Text('1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: () {
            // TODO: Open privacy policy
          },
        ),
        ListTile(
          leading: const Icon(Icons.gavel_outlined),
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: () {
            // TODO: Open terms
          },
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('Open Source Licenses'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showLicensePage(
              context: context,
              applicationName: 'Foray',
              applicationVersion: '1.0.0',
            );
          },
        ),
      ],
    );
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

  void _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
  ) {
    final nameController = TextEditingController(
      text: user?.displayName ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'How others see you',
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName.length >= 2) {
                ref
                    .read(authControllerProvider.notifier)
                    .updateProfile(displayName: newName);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Your local data will be preserved. '
          'Sign in again to sync with the cloud.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(authControllerProvider.notifier).signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
