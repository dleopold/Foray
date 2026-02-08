import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Position of the label relative to the switch.
enum ForaySwitchLabelPosition {
  /// Label on the left, switch on the right.
  left,

  /// Label on the right, switch on the left.
  right,
}

/// A styled toggle switch with optional label.
///
/// Uses the theme primary color when active and supports disabled state.
///
/// Example:
/// ```dart
/// ForaySwitch(
///   value: isEnabled,
///   onChanged: (value) => setState(() => isEnabled = value),
///   label: 'Enable notifications',
/// )
/// ```
class ForaySwitch extends StatelessWidget {
  /// Creates a [ForaySwitch].
  const ForaySwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.subtitle,
    this.labelPosition = ForaySwitchLabelPosition.left,
    this.enabled = true,
    this.activeColor,
  });

  /// Whether the switch is on.
  final bool value;

  /// Called when the user toggles the switch.
  final ValueChanged<bool>? onChanged;

  /// Label text for the switch.
  final String? label;

  /// Optional subtitle/description text.
  final String? subtitle;

  /// Position of the label relative to the switch.
  final ForaySwitchLabelPosition labelPosition;

  /// Whether the switch is enabled.
  final bool enabled;

  /// Custom active color. Defaults to theme primary.
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveActiveColor = activeColor ?? AppColors.primary;

    final thumbColor = WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.disabled)) {
        return isDark ? Colors.grey[700]! : Colors.grey[400]!;
      }
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return isDark ? Colors.grey[400]! : Colors.grey[50]!;
    });

    final trackColor = WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.disabled)) {
        return isDark ? Colors.grey[800]! : Colors.grey[300]!;
      }
      if (states.contains(WidgetState.selected)) {
        return effectiveActiveColor;
      }
      return isDark ? Colors.grey[700]! : Colors.grey[300]!;
    });

    final trackOutlineColor = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.transparent;
      }
      return isDark ? Colors.grey[600] : Colors.grey[400];
    });

    final switchWidget = Switch(
      value: value,
      onChanged: enabled ? onChanged : null,
      thumbColor: thumbColor,
      trackColor: trackColor,
      trackOutlineColor: trackOutlineColor,
      splashRadius: 20,
    );

    if (label == null && subtitle == null) {
      return switchWidget;
    }

    final textOpacity = enabled ? 1.0 : 0.5;

    final labelWidget = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null)
            Text(
              label!,
              style: AppTypography.bodyLarge.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(textOpacity),
              ),
            ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6 * textOpacity),
              ),
            ),
          ],
        ],
      ),
    );

    final content = Row(
      children: labelPosition == ForaySwitchLabelPosition.left
          ? [
              labelWidget,
              const SizedBox(width: AppSpacing.sm),
              switchWidget,
            ]
          : [
              switchWidget,
              const SizedBox(width: AppSpacing.sm),
              labelWidget,
            ],
    );

    // Make the entire row tappable
    return GestureDetector(
      onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: content,
      ),
    );
  }
}

/// A group of switches with a section header.
class ForaySwitchGroup extends StatelessWidget {
  /// Creates a [ForaySwitchGroup].
  const ForaySwitchGroup({
    super.key,
    this.header,
    required this.children,
  });

  /// Optional section header.
  final String? header;

  /// Switch widgets in the group.
  final List<ForaySwitch> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              header!.toUpperCase(),
              style: AppTypography.labelSmall.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
        ...children.map((child) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: child,
            ),),
      ],
    );
  }
}
