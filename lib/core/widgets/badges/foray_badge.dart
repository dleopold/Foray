import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Color variants for [ForayBadge].
enum ForayBadgeVariant {
  /// Primary color badge.
  primary,

  /// Secondary color badge.
  secondary,

  /// Success/green badge.
  success,

  /// Warning/amber badge.
  warning,

  /// Error/red badge.
  error,

  /// Neutral/gray badge.
  neutral,

  /// Info/blue badge.
  info,
}

/// Size variants for [ForayBadge].
enum ForayBadgeSize {
  /// Small badge.
  small,

  /// Medium badge (default).
  medium,

  /// Large badge.
  large,
}

/// A general-purpose badge/chip component.
///
/// Displays a label with optional leading icon and dismiss button.
/// Supports multiple color variants and sizes.
///
/// Example:
/// ```dart
/// ForayBadge(
///   label: 'New',
///   variant: ForayBadgeVariant.success,
///   icon: Icons.star,
/// )
/// ```
class ForayBadge extends StatelessWidget {
  /// Creates a [ForayBadge].
  const ForayBadge({
    super.key,
    required this.label,
    this.variant = ForayBadgeVariant.neutral,
    this.size = ForayBadgeSize.medium,
    this.icon,
    this.onDismiss,
    this.onTap,
    this.outlined = false,
  });

  /// The text label of the badge.
  final String label;

  /// Color variant of the badge.
  final ForayBadgeVariant variant;

  /// Size of the badge.
  final ForayBadgeSize size;

  /// Optional leading icon.
  final IconData? icon;

  /// Called when the dismiss button is tapped. Shows dismiss button if not null.
  final VoidCallback? onDismiss;

  /// Called when the badge is tapped.
  final VoidCallback? onTap;

  /// Whether to use an outlined style instead of filled.
  final bool outlined;

  /// Creates a count badge (e.g., notification count).
  factory ForayBadge.count({
    Key? key,
    required int count,
    int maxCount = 99,
    ForayBadgeVariant variant = ForayBadgeVariant.error,
  }) {
    final displayCount = count > maxCount ? '$maxCount+' : count.toString();
    return ForayBadge(
      key: key,
      label: displayCount,
      variant: variant,
      size: ForayBadgeSize.small,
    );
  }

  /// Creates a status badge.
  factory ForayBadge.status({
    Key? key,
    required String status,
    required ForayBadgeVariant variant,
    IconData? icon,
  }) {
    return ForayBadge(
      key: key,
      label: status,
      variant: variant,
      icon: icon,
      size: ForayBadgeSize.small,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final colors = _getColors(isDark);
    final backgroundColor = outlined ? Colors.transparent : colors.background;
    final foregroundColor = outlined ? colors.background : colors.foreground;
    final borderColor = outlined ? colors.background : Colors.transparent;

    final padding = _getPadding();
    final fontSize = _getFontSize();
    final iconSize = _getIconSize();

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize, color: foregroundColor),
          SizedBox(width: size == ForayBadgeSize.small ? 4 : 6),
        ],
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            fontSize: fontSize,
            color: foregroundColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (onDismiss != null) ...[
          SizedBox(width: size == ForayBadgeSize.small ? 4 : 6),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              Icons.close,
              size: iconSize,
              color: foregroundColor,
            ),
          ),
        ],
      ],
    );

    Widget badge = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: outlined ? 1.5 : 0,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: content,
    );

    if (onTap != null) {
      badge = GestureDetector(
        onTap: onTap,
        child: badge,
      );
    }

    return badge;
  }

  _BadgeColors _getColors(bool isDark) {
    switch (variant) {
      case ForayBadgeVariant.primary:
        return _BadgeColors(
          background: AppColors.primary,
          foreground: Colors.white,
        );
      case ForayBadgeVariant.secondary:
        return _BadgeColors(
          background: AppColors.secondary,
          foreground: Colors.white,
        );
      case ForayBadgeVariant.success:
        return _BadgeColors(
          background: AppColors.success,
          foreground: Colors.white,
        );
      case ForayBadgeVariant.warning:
        return _BadgeColors(
          background: AppColors.warning,
          foreground: AppColors.textPrimaryLight,
        );
      case ForayBadgeVariant.error:
        return _BadgeColors(
          background: AppColors.error,
          foreground: Colors.white,
        );
      case ForayBadgeVariant.info:
        return _BadgeColors(
          background: AppColors.info,
          foreground: Colors.white,
        );
      case ForayBadgeVariant.neutral:
        return _BadgeColors(
          background:
              isDark ? AppColors.dividerDark : AppColors.textSecondaryLight,
          foreground: isDark ? AppColors.textPrimaryDark : Colors.white,
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ForayBadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 2);
      case ForayBadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
      case ForayBadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 6);
    }
  }

  double _getFontSize() {
    switch (size) {
      case ForayBadgeSize.small:
        return 10;
      case ForayBadgeSize.medium:
        return 12;
      case ForayBadgeSize.large:
        return 14;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ForayBadgeSize.small:
        return 12;
      case ForayBadgeSize.medium:
        return 14;
      case ForayBadgeSize.large:
        return 16;
    }
  }
}

class _BadgeColors {
  const _BadgeColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}

/// A group of badges displayed in a wrap layout.
class ForayBadgeGroup extends StatelessWidget {
  /// Creates a [ForayBadgeGroup].
  const ForayBadgeGroup({
    super.key,
    required this.children,
    this.spacing = AppSpacing.xs,
    this.runSpacing = AppSpacing.xs,
  });

  /// Badge widgets to display.
  final List<Widget> children;

  /// Horizontal spacing between badges.
  final double spacing;

  /// Vertical spacing between rows.
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children,
    );
  }
}
