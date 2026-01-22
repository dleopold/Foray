import 'package:flutter/material.dart';

import '../../constants/privacy_levels.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

enum PrivacyBadgeSize { small, medium, large }

class PrivacyBadge extends StatelessWidget {
  const PrivacyBadge({
    super.key,
    required this.level,
    this.showLabel = true,
    this.size = PrivacyBadgeSize.medium,
  });

  final PrivacyLevel level;
  final bool showLabel;
  final PrivacyBadgeSize size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? AppSpacing.sm : AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: _getIconSize(),
            color: _getColor(),
          ),
          if (showLabel) ...[
            const SizedBox(width: AppSpacing.xs),
            Text(
              level.label,
              style: TextStyle(
                fontSize: _getFontSize(),
                fontWeight: FontWeight.w500,
                color: _getColor(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (level) {
      case PrivacyLevel.private:
        return Icons.lock;
      case PrivacyLevel.foray:
        return Icons.group;
      case PrivacyLevel.publicExact:
        return Icons.public;
      case PrivacyLevel.publicObscured:
        return Icons.blur_on;
    }
  }

  Color _getColor() {
    switch (level) {
      case PrivacyLevel.private:
        return AppColors.privacyPrivate;
      case PrivacyLevel.foray:
        return AppColors.privacyForay;
      case PrivacyLevel.publicExact:
        return AppColors.privacyPublic;
      case PrivacyLevel.publicObscured:
        return AppColors.privacyObscured;
    }
  }

  double _getIconSize() {
    switch (size) {
      case PrivacyBadgeSize.small:
        return 12;
      case PrivacyBadgeSize.medium:
        return 16;
      case PrivacyBadgeSize.large:
        return 20;
    }
  }

  double _getFontSize() {
    switch (size) {
      case PrivacyBadgeSize.small:
        return 10;
      case PrivacyBadgeSize.medium:
        return 12;
      case PrivacyBadgeSize.large:
        return 14;
    }
  }
}
