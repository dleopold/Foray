import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../database/tables/forays_table.dart';

/// A selector widget for choosing observation privacy level.
///
/// Displays all privacy options as selectable cards with icons and descriptions.
class PrivacySelector extends StatelessWidget {
  const PrivacySelector({
    super.key,
    required this.selectedLevel,
    required this.onChanged,
    this.minimumLevel,
  });

  final PrivacyLevel selectedLevel;
  final ValueChanged<PrivacyLevel> onChanged;
  
  /// Minimum allowed privacy level (set by foray default).
  final PrivacyLevel? minimumLevel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: PrivacyLevel.values.map((level) {
        final isSelected = level == selectedLevel;
        final isDisabled = _isLevelDisabled(level);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _PrivacyOption(
            level: level,
            isSelected: isSelected,
            isDisabled: isDisabled,
            onTap: isDisabled ? null : () => onChanged(level),
          ),
        );
      }).toList(),
    );
  }

  bool _isLevelDisabled(PrivacyLevel level) {
    if (minimumLevel == null) return false;
    
    // Privacy levels are ordered from most private to most public
    // Users can only select same or more private than minimum
    final levelIndex = PrivacyLevel.values.indexOf(level);
    final minIndex = PrivacyLevel.values.indexOf(minimumLevel!);
    
    return levelIndex > minIndex;
  }
}

class _PrivacyOption extends StatelessWidget {
  const _PrivacyOption({
    required this.level,
    required this.isSelected,
    required this.isDisabled,
    this.onTap,
  });

  final PrivacyLevel level;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? _getLevelColor(level).withOpacity(0.1)
            : colorScheme.surfaceContainerHighest.withOpacity(isDisabled ? 0.3 : 1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isSelected
              ? _getLevelColor(level)
              : colorScheme.outline.withOpacity(isDisabled ? 0.3 : 1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  _getLevelIcon(level),
                  color: isDisabled
                      ? colorScheme.onSurface.withOpacity(0.3)
                      : _getLevelColor(level),
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLevelLabel(level),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: isDisabled
                                  ? colorScheme.onSurface.withOpacity(0.3)
                                  : null,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getLevelDescription(level),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDisabled
                                  ? colorScheme.onSurface.withOpacity(0.3)
                                  : colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: _getLevelColor(level),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLevelLabel(PrivacyLevel level) {
    return switch (level) {
      PrivacyLevel.private => 'Private',
      PrivacyLevel.foray => 'Foray Only',
      PrivacyLevel.publicExact => 'Public (Exact)',
      PrivacyLevel.publicObscured => 'Public (Obscured)',
    };
  }

  String _getLevelDescription(PrivacyLevel level) {
    return switch (level) {
      PrivacyLevel.private => 'Only you can see this observation',
      PrivacyLevel.foray => 'Visible to foray participants',
      PrivacyLevel.publicExact => 'Everyone can see with exact location',
      PrivacyLevel.publicObscured => 'Everyone can see, location hidden within ~10km',
    };
  }

  IconData _getLevelIcon(PrivacyLevel level) {
    return switch (level) {
      PrivacyLevel.private => Icons.lock,
      PrivacyLevel.foray => Icons.group,
      PrivacyLevel.publicExact => Icons.public,
      PrivacyLevel.publicObscured => Icons.blur_on,
    };
  }

  Color _getLevelColor(PrivacyLevel level) {
    return switch (level) {
      PrivacyLevel.private => AppColors.privacyPrivate,
      PrivacyLevel.foray => AppColors.privacyForay,
      PrivacyLevel.publicExact => AppColors.privacyPublic,
      PrivacyLevel.publicObscured => AppColors.privacyObscured,
    };
  }
}
