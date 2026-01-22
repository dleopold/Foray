import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Size presets for [ForayAvatar].
enum ForayAvatarSize {
  /// 24x24 - Extra small, for tight spaces.
  xs(24),

  /// 32x32 - Small, for list items.
  small(32),

  /// 40x40 - Medium, default size.
  medium(40),

  /// 56x56 - Large, for profile displays.
  large(56),

  /// 80x80 - Extra large, for profile pages.
  xlarge(80);

  const ForayAvatarSize(this.size);

  /// The pixel size of the avatar.
  final double size;
}

/// A user/entity avatar with fallback options.
///
/// Displays an image, initials, or icon as fallback.
/// Supports optional badge overlay for status indicators.
///
/// Example:
/// ```dart
/// ForayAvatar(
///   imageUrl: user.photoUrl,
///   initials: user.initials,
///   size: ForayAvatarSize.large,
///   badge: OnlineBadge(),
/// )
/// ```
class ForayAvatar extends StatelessWidget {
  /// Creates a [ForayAvatar].
  const ForayAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.icon,
    this.size = ForayAvatarSize.medium,
    this.backgroundColor,
    this.foregroundColor,
    this.badge,
    this.borderColor,
    this.borderWidth,
    this.onTap,
  });

  /// URL of the avatar image.
  final String? imageUrl;

  /// Initials to display if no image is available.
  final String? initials;

  /// Icon to display if no image or initials are available.
  final IconData? icon;

  /// Size of the avatar.
  final ForayAvatarSize size;

  /// Background color. Defaults to primary color.
  final Color? backgroundColor;

  /// Foreground color for initials/icon.
  final Color? foregroundColor;

  /// Optional badge widget overlaid on the avatar.
  final Widget? badge;

  /// Optional border color.
  final Color? borderColor;

  /// Border width if borderColor is set.
  final double? borderWidth;

  /// Called when the avatar is tapped.
  final VoidCallback? onTap;

  /// Creates an avatar from a user's name.
  factory ForayAvatar.fromName({
    Key? key,
    required String name,
    String? imageUrl,
    ForayAvatarSize size = ForayAvatarSize.medium,
    Color? backgroundColor,
    Widget? badge,
    VoidCallback? onTap,
  }) {
    return ForayAvatar(
      key: key,
      imageUrl: imageUrl,
      initials: _getInitials(name),
      size: size,
      backgroundColor: backgroundColor,
      badge: badge,
      onTap: onTap,
    );
  }

  static String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ?? AppColors.primary.withOpacity(0.15);
    final effectiveForegroundColor =
        foregroundColor ?? AppColors.primary;

    final avatarSize = size.size;
    final fontSize = _getFontSize();
    final iconSize = _getIconSize();

    Widget avatarContent;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarContent = ClipOval(
        child: Image.network(
          imageUrl!,
          width: avatarSize,
          height: avatarSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallback(
              effectiveBackgroundColor,
              effectiveForegroundColor,
              avatarSize,
              fontSize,
              iconSize,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: effectiveBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width: avatarSize * 0.4,
                  height: avatarSize * 0.4,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: effectiveForegroundColor.withOpacity(0.5),
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      avatarContent = _buildFallback(
        effectiveBackgroundColor,
        effectiveForegroundColor,
        avatarSize,
        fontSize,
        iconSize,
      );
    }

    // Add border if specified
    if (borderColor != null) {
      avatarContent = Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor!,
            width: borderWidth ?? 2,
          ),
        ),
        child: ClipOval(
          child: SizedBox(
            width: avatarSize - ((borderWidth ?? 2) * 2),
            height: avatarSize - ((borderWidth ?? 2) * 2),
            child: avatarContent,
          ),
        ),
      );
    }

    // Add badge if present
    if (badge != null) {
      avatarContent = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarContent,
          Positioned(
            right: 0,
            bottom: 0,
            child: badge!,
          ),
        ],
      );
    }

    // Add tap handler if present
    if (onTap != null) {
      avatarContent = GestureDetector(
        onTap: onTap,
        child: avatarContent,
      );
    }

    return SizedBox(
      width: avatarSize,
      height: avatarSize,
      child: avatarContent,
    );
  }

  Widget _buildFallback(
    Color backgroundColor,
    Color foregroundColor,
    double avatarSize,
    double fontSize,
    double iconSize,
  ) {
    Widget content;

    if (initials != null && initials!.isNotEmpty) {
      content = Text(
        initials!,
        style: AppTypography.labelLarge.copyWith(
          color: foregroundColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      content = Icon(
        icon ?? Icons.person,
        size: iconSize,
        color: foregroundColor,
      );
    }

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(child: content),
    );
  }

  double _getFontSize() {
    switch (size) {
      case ForayAvatarSize.xs:
        return 10;
      case ForayAvatarSize.small:
        return 12;
      case ForayAvatarSize.medium:
        return 14;
      case ForayAvatarSize.large:
        return 20;
      case ForayAvatarSize.xlarge:
        return 28;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ForayAvatarSize.xs:
        return 14;
      case ForayAvatarSize.small:
        return 18;
      case ForayAvatarSize.medium:
        return 22;
      case ForayAvatarSize.large:
        return 30;
      case ForayAvatarSize.xlarge:
        return 42;
    }
  }
}

/// A row of overlapping avatars for displaying multiple users.
class ForayAvatarStack extends StatelessWidget {
  /// Creates a [ForayAvatarStack].
  const ForayAvatarStack({
    super.key,
    required this.avatars,
    this.maxVisible = 4,
    this.size = ForayAvatarSize.small,
    this.overlapFactor = 0.3,
    this.borderColor,
  });

  /// List of avatar data (imageUrl, initials pairs).
  final List<({String? imageUrl, String? initials})> avatars;

  /// Maximum number of avatars to display.
  final int maxVisible;

  /// Size of each avatar.
  final ForayAvatarSize size;

  /// How much avatars overlap (0.0 - 1.0).
  final double overlapFactor;

  /// Border color for each avatar.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveBorderColor = borderColor ??
        (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

    final visible = avatars.take(maxVisible).toList();
    final overflow = avatars.length - maxVisible;
    final avatarSize = size.size;
    final overlap = avatarSize * overlapFactor;

    return SizedBox(
      height: avatarSize,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...visible.asMap().entries.map((entry) {
            final index = entry.key;
            final avatar = entry.value;
            return Transform.translate(
              offset: Offset(-index * overlap, 0),
              child: ForayAvatar(
                imageUrl: avatar.imageUrl,
                initials: avatar.initials,
                size: size,
                borderColor: effectiveBorderColor,
                borderWidth: 2,
              ),
            );
          }),
          if (overflow > 0)
            Transform.translate(
              offset: Offset(-visible.length * overlap, 0),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: effectiveBorderColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$overflow',
                    style: AppTypography.labelSmall.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
