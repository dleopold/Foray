import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../routing/routes.dart';

/// A prompt encouraging anonymous users to sign up or sign in.
///
/// Use this widget to display when a user tries to access
/// a feature that requires authentication.
class UpgradePrompt extends StatelessWidget {
  const UpgradePrompt({
    super.key,
    required this.message,
    this.feature,
    this.showButtons = true,
    this.compact = false,
  });

  /// Message explaining why authentication is needed.
  final String message;

  /// Optional feature name for context.
  final String? feature;

  /// Whether to show sign in/register buttons.
  final bool showButtons;

  /// Use compact layout.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return _buildCompact(context, theme);
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (showButtons) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => context.push(AppRoutes.login),
                  child: const Text('Sign In'),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: () => context.push(AppRoutes.register),
                  child: const Text('Create Account'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompact(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.lock_outline,
          color: AppColors.primary.withOpacity(0.7),
          size: 16,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
            ),
          ),
        ),
        if (showButtons)
          TextButton(
            onPressed: () => context.push(AppRoutes.login),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Sign In'),
          ),
      ],
    );
  }
}

/// A banner version of the upgrade prompt for the bottom of screens.
class UpgradeBanner extends StatelessWidget {
  const UpgradeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withOpacity(0.3),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Sign in to sync your data',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.login),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
