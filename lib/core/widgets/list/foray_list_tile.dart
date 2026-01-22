import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Density options for [ForayListTile].
enum ForayListTileDensity {
  /// Compact density with minimal padding.
  compact,

  /// Normal density (default).
  normal,

  /// Comfortable density with extra padding.
  comfortable,
}

/// A standardized list tile component with consistent styling.
///
/// Use this for list items throughout the app to maintain visual consistency.
/// Supports leading/trailing widgets, title/subtitle, and various density options.
///
/// Example:
/// ```dart
/// ForayListTile(
///   leading: Icon(Icons.person),
///   title: 'John Doe',
///   subtitle: 'Collector',
///   trailing: Icon(Icons.chevron_right),
///   onTap: () => print('Tapped!'),
/// )
/// ```
class ForayListTile extends StatelessWidget {
  /// Creates a [ForayListTile].
  const ForayListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.density = ForayListTileDensity.normal,
    this.showDivider = false,
    this.enabled = true,
    this.selected = false,
    this.contentPadding,
  });

  /// Widget displayed before the title.
  final Widget? leading;

  /// Primary text content. Can be a String or Widget.
  final dynamic title;

  /// Secondary text content. Can be a String or Widget.
  final dynamic subtitle;

  /// Widget displayed after the title/subtitle.
  final Widget? trailing;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;

  /// Called when the tile is long-pressed.
  final VoidCallback? onLongPress;

  /// The visual density of the tile.
  final ForayListTileDensity density;

  /// Whether to show a divider below the tile.
  final bool showDivider;

  /// Whether the tile is enabled for interaction.
  final bool enabled;

  /// Whether the tile is in a selected state.
  final bool selected;

  /// Custom content padding.
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final verticalPadding = _getVerticalPadding();
    final effectivePadding = contentPadding ??
        EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: verticalPadding,
        );

    final backgroundColor = selected
        ? colorScheme.primary.withOpacity(0.1)
        : Colors.transparent;

    final textOpacity = enabled ? 1.0 : 0.5;

    Widget titleWidget;
    if (title is String) {
      titleWidget = Text(
        title as String,
        style: AppTypography.bodyLarge.copyWith(
          color: colorScheme.onSurface.withOpacity(textOpacity),
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      titleWidget = title as Widget;
    }

    Widget? subtitleWidget;
    if (subtitle != null) {
      if (subtitle is String) {
        subtitleWidget = Text(
          subtitle as String,
          style: AppTypography.bodySmall.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6 * textOpacity),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      } else {
        subtitleWidget = subtitle as Widget;
      }
    }

    Widget content = Container(
      color: backgroundColor,
      padding: effectivePadding,
      child: Row(
        children: [
          if (leading != null) ...[
            Opacity(
              opacity: textOpacity,
              child: leading!,
            ),
            SizedBox(width: _getLeadingSpacing()),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                titleWidget,
                if (subtitleWidget != null) ...[
                  const SizedBox(height: 2),
                  subtitleWidget,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Opacity(
              opacity: textOpacity,
              child: trailing!,
            ),
          ],
        ],
      ),
    );

    if (onTap != null || onLongPress != null) {
      content = InkWell(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        child: content,
      );
    }

    if (showDivider) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          Divider(
            height: 1,
            indent: leading != null ? AppSpacing.md + 40 + _getLeadingSpacing() : AppSpacing.md,
            endIndent: AppSpacing.md,
          ),
        ],
      );
    }

    return content;
  }

  double _getVerticalPadding() {
    switch (density) {
      case ForayListTileDensity.compact:
        return AppSpacing.sm;
      case ForayListTileDensity.normal:
        return AppSpacing.md;
      case ForayListTileDensity.comfortable:
        return AppSpacing.lg;
    }
  }

  double _getLeadingSpacing() {
    switch (density) {
      case ForayListTileDensity.compact:
        return AppSpacing.sm;
      case ForayListTileDensity.normal:
        return AppSpacing.md;
      case ForayListTileDensity.comfortable:
        return AppSpacing.md;
    }
  }
}

/// A grouped list section with an optional header.
///
/// Wraps multiple [ForayListTile] widgets with an optional section header.
class ForayListSection extends StatelessWidget {
  /// Creates a [ForayListSection].
  const ForayListSection({
    super.key,
    this.header,
    required this.children,
    this.showDividers = true,
  });

  /// Optional section header text.
  final String? header;

  /// List tile children.
  final List<Widget> children;

  /// Whether to show dividers between children.
  final bool showDividers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text(
              header!.toUpperCase(),
              style: AppTypography.labelSmall.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                letterSpacing: 1.2,
              ),
            ),
          ),
        if (showDividers)
          ...children.asMap().entries.map((entry) {
            final isLast = entry.key == children.length - 1;
            final child = entry.value;
            if (isLast || child is! ForayListTile) return child;
            // Clone the ForayListTile with showDivider = true
            final tile = child;
            return ForayListTile(
              key: tile.key,
              leading: tile.leading,
              title: tile.title,
              subtitle: tile.subtitle,
              trailing: tile.trailing,
              onTap: tile.onTap,
              onLongPress: tile.onLongPress,
              density: tile.density,
              showDivider: true,
              enabled: tile.enabled,
              selected: tile.selected,
              contentPadding: tile.contentPadding,
            );
          })
        else
          ...children,
      ],
    );
  }
}
