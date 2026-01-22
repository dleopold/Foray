import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// A styled checkbox with label support.
///
/// Supports optional tristate (null/true/false) and disabled state.
/// Uses theme primary color for the checked state.
///
/// Example:
/// ```dart
/// ForayCheckbox(
///   value: acceptTerms,
///   onChanged: (value) => setState(() => acceptTerms = value ?? false),
///   label: 'I accept the terms and conditions',
/// )
/// ```
class ForayCheckbox extends StatelessWidget {
  /// Creates a [ForayCheckbox].
  const ForayCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.subtitle,
    this.tristate = false,
    this.enabled = true,
    this.activeColor,
    this.error,
  });

  /// Whether the checkbox is checked. Null if tristate and indeterminate.
  final bool? value;

  /// Called when the user taps the checkbox.
  final ValueChanged<bool?>? onChanged;

  /// Label text for the checkbox.
  final String? label;

  /// Optional subtitle/description text.
  final String? subtitle;

  /// Whether null is a valid value (three states: true, false, null).
  final bool tristate;

  /// Whether the checkbox is enabled.
  final bool enabled;

  /// Custom active color. Defaults to theme primary.
  final Color? activeColor;

  /// Error message to display below the checkbox.
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveActiveColor = activeColor ?? AppColors.primary;

    final fillColor = WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.disabled)) {
        return isDark ? Colors.grey[700]! : Colors.grey[400]!;
      }
      if (states.contains(WidgetState.selected)) {
        return effectiveActiveColor;
      }
      return Colors.transparent;
    });

    const checkColor = Colors.white;

    final side = WidgetStateBorderSide.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return BorderSide(
          color: isDark ? Colors.grey[700]! : Colors.grey[400]!,
          width: 2,
        );
      }
      if (states.contains(WidgetState.selected)) {
        return BorderSide.none;
      }
      if (error != null) {
        return const BorderSide(color: AppColors.error, width: 2);
      }
      return BorderSide(
        color: isDark ? Colors.grey[500]! : Colors.grey[600]!,
        width: 2,
      );
    });

    final checkboxWidget = Checkbox(
      value: value,
      onChanged: enabled ? onChanged : null,
      tristate: tristate,
      fillColor: fillColor,
      checkColor: checkColor,
      side: side,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      splashRadius: 20,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );

    if (label == null && subtitle == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          checkboxWidget,
          if (error != null) ...[
            const SizedBox(height: 4),
            Text(
              error!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ],
      );
    }

    final textOpacity = enabled ? 1.0 : 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: enabled && onChanged != null
              ? () {
                  if (tristate) {
                    // Cycle through: false -> true -> null -> false
                    if (value == null) {
                      onChanged!(false);
                    } else if (value!) {
                      onChanged!(null);
                    } else {
                      onChanged!(true);
                    }
                  } else {
                    onChanged!(!(value ?? false));
                  }
                }
              : null,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: subtitle != null
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                checkboxWidget,
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (label != null)
                        Text(
                          label!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurface
                                .withOpacity(textOpacity),
                          ),
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTypography.bodySmall.copyWith(
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.6 * textOpacity),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (error != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              error!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// A group of checkboxes that allows multiple selections.
class ForayCheckboxGroup<T> extends StatelessWidget {
  /// Creates a [ForayCheckboxGroup].
  const ForayCheckboxGroup({
    super.key,
    required this.items,
    required this.selectedValues,
    required this.onChanged,
    this.label,
    this.itemLabelBuilder,
    this.enabled = true,
  });

  /// All available items.
  final List<T> items;

  /// Currently selected values.
  final Set<T> selectedValues;

  /// Called when selection changes.
  final ValueChanged<Set<T>> onChanged;

  /// Optional group label.
  final String? label;

  /// Converts item to display label.
  final String Function(T item)? itemLabelBuilder;

  /// Whether the group is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        ...items.map((item) {
          final isSelected = selectedValues.contains(item);
          final itemLabel = itemLabelBuilder?.call(item) ?? item.toString();

          return ForayCheckbox(
            value: isSelected,
            onChanged: enabled
                ? (checked) {
                    final newSelection = Set<T>.from(selectedValues);
                    if (checked ?? false) {
                      newSelection.add(item);
                    } else {
                      newSelection.remove(item);
                    }
                    onChanged(newSelection);
                  }
                : null,
            label: itemLabel,
            enabled: enabled,
          );
        }),
      ],
    );
  }
}
