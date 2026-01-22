import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// A styled dropdown selector with consistent theming.
///
/// Generic over the value type [T]. Provides label, hint, error states,
/// and custom item builder support.
///
/// Example:
/// ```dart
/// ForayDropdown<String>(
///   label: 'Substrate',
///   hint: 'Select substrate type',
///   value: selectedSubstrate,
///   items: substrates,
///   itemBuilder: (substrate) => Text(substrate),
///   onChanged: (value) => setState(() => selectedSubstrate = value),
/// )
/// ```
class ForayDropdown<T> extends StatelessWidget {
  /// Creates a [ForayDropdown].
  const ForayDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.label,
    this.hint,
    this.error,
    this.helper,
    this.itemBuilder,
    this.itemLabelBuilder,
    this.enabled = true,
    this.isExpanded = true,
    this.prefixIcon,
  });

  /// The list of items to display in the dropdown.
  final List<T> items;

  /// Called when the user selects an item.
  final ValueChanged<T?>? onChanged;

  /// The currently selected value.
  final T? value;

  /// Label text displayed above the dropdown.
  final String? label;

  /// Hint text displayed when no value is selected.
  final String? hint;

  /// Error text displayed below the dropdown.
  final String? error;

  /// Helper text displayed below the dropdown.
  final String? helper;

  /// Custom builder for dropdown items. If not provided, uses [itemLabelBuilder] or toString().
  final Widget Function(T item)? itemBuilder;

  /// Converts an item to its display string. Used if [itemBuilder] is not provided.
  final String Function(T item)? itemLabelBuilder;

  /// Whether the dropdown is enabled.
  final bool enabled;

  /// Whether the dropdown should expand to fill available width.
  final bool isExpanded;

  /// Optional icon displayed at the start of the dropdown.
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = error != null
        ? AppColors.error
        : (isDark ? AppColors.dividerDark : AppColors.dividerLight);

    final fillColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: borderColor,
              width: error != null ? 1.5 : 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<T>(
                value: value,
                hint: hint != null
                    ? Text(
                        hint!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      )
                    : null,
                items: items.map((item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: _buildItem(item, context),
                  );
                }).toList(),
                onChanged: enabled ? onChanged : null,
                isExpanded: isExpanded,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: enabled
                      ? theme.colorScheme.onSurface
                      : theme.disabledColor,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                dropdownColor: fillColor,
                padding: EdgeInsets.only(
                  left: prefixIcon != null ? 0 : AppSpacing.md,
                  right: AppSpacing.sm,
                ),
                selectedItemBuilder: (context) {
                  return items.map((item) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (prefixIcon != null) ...[
                            Icon(
                              prefixIcon,
                              size: 20,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          Flexible(child: _buildItem(item, context)),
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.error,
            ),
          ),
        ] else if (helper != null) ...[
          const SizedBox(height: 6),
          Text(
            helper!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildItem(T item, BuildContext context) {
    if (itemBuilder != null) {
      return itemBuilder!(item);
    }
    
    final label = itemLabelBuilder?.call(item) ?? item.toString();
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// A variant of [ForayDropdown] for enum values with automatic label conversion.
class ForayEnumDropdown<T extends Enum> extends StatelessWidget {
  /// Creates a [ForayEnumDropdown].
  const ForayEnumDropdown({
    super.key,
    required this.values,
    required this.onChanged,
    this.value,
    this.label,
    this.hint,
    this.error,
    this.labelBuilder,
    this.enabled = true,
  });

  /// All enum values.
  final List<T> values;

  /// Called when the user selects a value.
  final ValueChanged<T?>? onChanged;

  /// The currently selected value.
  final T? value;

  /// Label text above the dropdown.
  final String? label;

  /// Hint text when no value selected.
  final String? hint;

  /// Error text below the dropdown.
  final String? error;

  /// Custom label builder. Defaults to capitalizing enum name.
  final String Function(T value)? labelBuilder;

  /// Whether the dropdown is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ForayDropdown<T>(
      items: values,
      value: value,
      onChanged: onChanged,
      label: label,
      hint: hint,
      error: error,
      enabled: enabled,
      itemLabelBuilder: labelBuilder ?? _defaultLabelBuilder,
    );
  }

  String _defaultLabelBuilder(T value) {
    final name = value.name;
    // Convert camelCase to Title Case
    return name
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        )
        .trim()
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}
