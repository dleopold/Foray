import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/foray_button.dart';

/// An illustrated empty state component for when there's no content to display.
///
/// Provides a consistent way to communicate empty states with optional
/// icon, title, description, and action button.
///
/// Example:
/// ```dart
/// EmptyState(
///   icon: Icons.search_off,
///   title: 'No results found',
///   description: 'Try adjusting your search criteria',
///   actionLabel: 'Clear filters',
///   onAction: () => clearFilters(),
/// )
/// ```
class EmptyState extends StatelessWidget {
  /// Creates an [EmptyState].
  const EmptyState({
    super.key,
    this.icon,
    this.iconWidget,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  }) : assert(
          icon == null || iconWidget == null,
          'Cannot provide both icon and iconWidget',
        );

  /// Icon to display. Mutually exclusive with [iconWidget].
  final IconData? icon;

  /// Custom widget to display instead of icon.
  final Widget? iconWidget;

  /// Primary message title.
  final String title;

  /// Optional secondary description text.
  final String? description;

  /// Label for the optional action button.
  final String? actionLabel;

  /// Callback for the action button.
  final VoidCallback? onAction;

  /// Whether to use a compact layout.
  final bool compact;

  /// Creates an empty state for when there are no observations.
  factory EmptyState.noObservations({
    VoidCallback? onAction,
    Key? key,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.camera_alt_outlined,
      title: 'No observations yet',
      description: 'Start documenting your finds by adding your first observation.',
      actionLabel: onAction != null ? 'Add Observation' : null,
      onAction: onAction,
    );
  }

  /// Creates an empty state for when there are no forays.
  factory EmptyState.noForays({
    VoidCallback? onAction,
    Key? key,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.explore_outlined,
      title: 'No forays yet',
      description: 'Create a solo foray to start collecting, or join a group foray.',
      actionLabel: onAction != null ? 'Start Foray' : null,
      onAction: onAction,
    );
  }

  /// Creates an empty state for search with no results.
  factory EmptyState.noResults({
    String? searchTerm,
    VoidCallback? onClear,
    Key? key,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.search_off,
      title: 'No results found',
      description: searchTerm != null
          ? 'No matches for "$searchTerm". Try a different search term.'
          : 'Try adjusting your search or filters.',
      actionLabel: onClear != null ? 'Clear Search' : null,
      onAction: onClear,
    );
  }

  /// Creates an empty state for offline mode.
  factory EmptyState.offline({
    VoidCallback? onRetry,
    Key? key,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.cloud_off_outlined,
      title: 'You\'re offline',
      description: 'Some features require an internet connection. '
          'Your data is saved locally and will sync when you\'re back online.',
      actionLabel: onRetry != null ? 'Try Again' : null,
      onAction: onRetry,
    );
  }

  /// Creates an empty state for generic errors.
  factory EmptyState.error({
    String? message,
    VoidCallback? onRetry,
    Key? key,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.error_outline,
      title: 'Something went wrong',
      description: message ?? 'An unexpected error occurred. Please try again.',
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }

  /// Creates an empty state for no participants.
  factory EmptyState.noParticipants({
    VoidCallback? onInvite,
    Key? key,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.group_outlined,
      title: 'No other participants',
      description: 'Share the join code to invite others to this foray.',
      actionLabel: onInvite != null ? 'Invite' : null,
      onAction: onInvite,
    );
  }

  /// Creates an empty state for no comments.
  factory EmptyState.noComments({
    Key? key,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.chat_bubble_outline,
      title: 'No comments yet',
      description: 'Be the first to add a comment.',
      compact: true,
    );
  }

  /// Creates an empty state for no identifications.
  factory EmptyState.noIdentifications({
    VoidCallback? onAddId,
    Key? key,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.science_outlined,
      title: 'No IDs yet',
      description: 'Add a species identification to help identify this specimen.',
      actionLabel: onAddId != null ? 'Add ID' : null,
      onAction: onAddId,
      compact: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final iconColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final iconSize = compact ? 48.0 : 72.0;
    final spacing = compact ? AppSpacing.md : AppSpacing.lg;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconWidget != null)
              iconWidget!
            else if (icon != null)
              Container(
                width: iconSize + 24,
                height: iconSize + 24,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor,
                ),
              ),
            if (icon != null || iconWidget != null) SizedBox(height: spacing),
            Text(
              title,
              style: compact
                  ? AppTypography.titleSmall.copyWith(
                      color: theme.colorScheme.onSurface,
                    )
                  : AppTypography.titleLarge.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
              Text(
                description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: iconColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: spacing),
              ForayButton(
                onPressed: onAction,
                label: actionLabel!,
                variant: ForayButtonVariant.primary,
                size: compact ? ForayButtonSize.small : ForayButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
