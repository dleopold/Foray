import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

/// Elevation variants for [ForayCard].
enum ForayCardVariant {
  /// No elevation, flat appearance with subtle border.
  flat,

  /// Slight elevation with shadow.
  raised,

  /// No elevation, visible border outline.
  outlined,
}

/// A themed card component with consistent styling.
///
/// Supports multiple elevation variants and optional tap interactions.
/// Use this as the base container for content throughout the app.
///
/// Example:
/// ```dart
/// ForayCard(
///   variant: ForayCardVariant.raised,
///   onTap: () => print('Tapped!'),
///   child: Text('Card content'),
/// )
/// ```
class ForayCard extends StatelessWidget {
  /// Creates a [ForayCard].
  const ForayCard({
    super.key,
    required this.child,
    this.variant = ForayCardVariant.flat,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.borderRadius,
  });

  /// The content of the card.
  final Widget child;

  /// The visual variant of the card.
  final ForayCardVariant variant;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Called when the card is long-pressed.
  final VoidCallback? onLongPress;

  /// Padding inside the card. Defaults to [AppSpacing.cardPadding].
  final EdgeInsetsGeometry? padding;

  /// Margin outside the card.
  final EdgeInsetsGeometry? margin;

  /// Fixed width for the card.
  final double? width;

  /// Fixed height for the card.
  final double? height;

  /// Background color override.
  final Color? color;

  /// Border radius override.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg);

    final effectiveColor =
        color ?? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

    final borderColor = isDark ? AppColors.dividerDark : AppColors.dividerLight;

    BoxDecoration decoration;
    switch (variant) {
      case ForayCardVariant.flat:
        decoration = BoxDecoration(
          color: effectiveColor,
          borderRadius: effectiveBorderRadius,
          border: Border.all(
            color: borderColor.withOpacity(0.5),
            width: 1,
          ),
        );
        break;
      case ForayCardVariant.raised:
        decoration = BoxDecoration(
          color: effectiveColor,
          borderRadius: effectiveBorderRadius,
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : AppShadows.medium,
        );
        break;
      case ForayCardVariant.outlined:
        decoration = BoxDecoration(
          color: effectiveColor,
          borderRadius: effectiveBorderRadius,
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
        );
        break;
    }

    Widget cardContent = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: decoration,
      child: Padding(
        padding:
            padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
        child: child,
      ),
    );

    if (onTap != null || onLongPress != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: effectiveBorderRadius,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// A [ForayCard] with structured header, content, and footer sections.
///
/// Provides a consistent layout for cards that need distinct sections.
class ForayCardStructured extends StatelessWidget {
  /// Creates a structured [ForayCard].
  const ForayCardStructured({
    super.key,
    this.header,
    required this.content,
    this.footer,
    this.variant = ForayCardVariant.flat,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
  });

  /// Optional header widget, displayed at the top with a divider below.
  final Widget? header;

  /// Main content of the card.
  final Widget content;

  /// Optional footer widget, displayed at the bottom with a divider above.
  final Widget? footer;

  /// The visual variant of the card.
  final ForayCardVariant variant;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Called when the card is long-pressed.
  final VoidCallback? onLongPress;

  /// Padding for the content section. Header and footer have their own padding.
  final EdgeInsetsGeometry? padding;

  /// Margin outside the card.
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.dividerColor;

    return ForayCard(
      variant: variant,
      onTap: onTap,
      onLongPress: onLongPress,
      margin: margin,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) ...[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: header!,
            ),
            Divider(height: 1, color: dividerColor),
          ],
          Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
            child: content,
          ),
          if (footer != null) ...[
            Divider(height: 1, color: dividerColor),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: footer!,
            ),
          ],
        ],
      ),
    );
  }
}
