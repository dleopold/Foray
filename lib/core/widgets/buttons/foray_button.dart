import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

enum ForayButtonVariant { primary, secondary, text, icon }

enum ForayButtonSize { small, medium, large }

class ForayButton extends StatelessWidget {
  const ForayButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.variant = ForayButtonVariant.primary,
    this.size = ForayButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final ForayButtonVariant variant;
  final ForayButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isLoading || isDisabled) ? null : onPressed;

    final Widget child = isLoading
        ? SizedBox(
            width: _getLoadingSize(),
            height: _getLoadingSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _getLoadingColor(context),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: _getIconSize()),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label),
            ],
          );

    Widget button;
    switch (variant) {
      case ForayButtonVariant.primary:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: _getPrimaryStyle(),
          child: child,
        );
      case ForayButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: _getSecondaryStyle(),
          child: child,
        );
      case ForayButtonVariant.text:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: _getTextStyle(),
          child: child,
        );
      case ForayButtonVariant.icon:
        button = IconButton(
          onPressed: effectiveOnPressed,
          icon: icon != null ? Icon(icon) : child,
        );
    }

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    return button;
  }

  double _getLoadingSize() {
    switch (size) {
      case ForayButtonSize.small:
        return 16;
      case ForayButtonSize.medium:
        return 20;
      case ForayButtonSize.large:
        return 24;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ForayButtonSize.small:
        return 16;
      case ForayButtonSize.medium:
        return 20;
      case ForayButtonSize.large:
        return 24;
    }
  }

  Color _getLoadingColor(BuildContext context) {
    switch (variant) {
      case ForayButtonVariant.primary:
        return Colors.white;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  ButtonStyle _getPrimaryStyle() {
    return ElevatedButton.styleFrom(
      padding: _getPadding(),
    );
  }

  ButtonStyle _getSecondaryStyle() {
    return OutlinedButton.styleFrom(
      padding: _getPadding(),
    );
  }

  ButtonStyle _getTextStyle() {
    return TextButton.styleFrom(
      padding: _getPadding(),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ForayButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ForayButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case ForayButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
    }
  }
}
