import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Variants for [ForaySnackbar] styling.
enum ForaySnackbarVariant {
  /// Success message (green).
  success,

  /// Error message (red).
  error,

  /// Warning message (yellow/amber).
  warning,

  /// Informational message (blue).
  info,

  /// Neutral/default message.
  neutral,
}

/// Custom snackbar styling matching the app theme.
///
/// Provides static methods for easy display of snackbars with different
/// variants (success, error, warning, info).
///
/// Example:
/// ```dart
/// ForaySnackbar.showSuccess(context, 'Saved successfully!');
/// ForaySnackbar.showError(context, 'Failed to save', action: SnackBarAction(...));
/// ```
abstract class ForaySnackbar {
  /// Shows a success snackbar.
  static void showSuccess(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      variant: ForaySnackbarVariant.success,
      action: action,
      duration: duration,
    );
  }

  /// Shows an error snackbar.
  static void showError(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message: message,
      variant: ForaySnackbarVariant.error,
      action: action,
      duration: duration,
    );
  }

  /// Shows a warning snackbar.
  static void showWarning(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      variant: ForaySnackbarVariant.warning,
      action: action,
      duration: duration,
    );
  }

  /// Shows an info snackbar.
  static void showInfo(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      variant: ForaySnackbarVariant.info,
      action: action,
      duration: duration,
    );
  }

  /// Shows a neutral snackbar.
  static void show(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      variant: ForaySnackbarVariant.neutral,
      action: action,
      duration: duration,
    );
  }

  /// Shows a snackbar with undo action.
  static void showWithUndo(
    BuildContext context,
    String message, {
    required VoidCallback onUndo,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message: message,
      variant: ForaySnackbarVariant.neutral,
      action: SnackBarAction(
        label: 'Undo',
        onPressed: onUndo,
      ),
      duration: duration,
    );
  }

  /// Hides the current snackbar.
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  static void _show(
    BuildContext context, {
    required String message,
    required ForaySnackbarVariant variant,
    SnackBarAction? action,
    required Duration duration,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    
    // Hide any existing snackbar
    messenger.hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: _ForaySnackbarContent(
        message: message,
        variant: variant,
      ),
      backgroundColor: _getBackgroundColor(variant),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.zero,
      duration: duration,
      action: action != null
          ? SnackBarAction(
              label: action.label,
              textColor: _getActionColor(variant),
              onPressed: action.onPressed,
            )
          : null,
    );

    messenger.showSnackBar(snackBar);
  }

  static Color _getBackgroundColor(ForaySnackbarVariant variant) {
    switch (variant) {
      case ForaySnackbarVariant.success:
        return AppColors.success;
      case ForaySnackbarVariant.error:
        return AppColors.error;
      case ForaySnackbarVariant.warning:
        return AppColors.warning;
      case ForaySnackbarVariant.info:
        return AppColors.info;
      case ForaySnackbarVariant.neutral:
        return AppColors.surfaceDark;
    }
  }

  static Color _getActionColor(ForaySnackbarVariant variant) {
    switch (variant) {
      case ForaySnackbarVariant.warning:
        return AppColors.textPrimaryLight;
      default:
        return Colors.white;
    }
  }
}

class _ForaySnackbarContent extends StatelessWidget {
  const _ForaySnackbarContent({
    required this.message,
    required this.variant,
  });

  final String message;
  final ForaySnackbarVariant variant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: _getContentColor(),
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: _getContentColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (variant) {
      case ForaySnackbarVariant.success:
        return Icons.check_circle_outline;
      case ForaySnackbarVariant.error:
        return Icons.error_outline;
      case ForaySnackbarVariant.warning:
        return Icons.warning_amber_outlined;
      case ForaySnackbarVariant.info:
        return Icons.info_outline;
      case ForaySnackbarVariant.neutral:
        return Icons.notifications_none;
    }
  }

  Color _getContentColor() {
    switch (variant) {
      case ForaySnackbarVariant.warning:
        return AppColors.textPrimaryLight;
      default:
        return Colors.white;
    }
  }
}
