import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Skeleton loading placeholder with shimmer effect.
///
/// Provides preset shapes for common loading states and supports
/// custom compositions for complex layouts.
///
/// Example:
/// ```dart
/// LoadingShimmer.listItem()
/// LoadingShimmer.card()
/// LoadingShimmer(child: MyCustomPlaceholder())
/// ```
class LoadingShimmer extends StatelessWidget {
  /// Creates a [LoadingShimmer] with a custom child.
  const LoadingShimmer({
    super.key,
    required this.child,
  });

  /// Creates a shimmer placeholder for a single line of text.
  factory LoadingShimmer.textLine({
    Key? key,
    double width = double.infinity,
    double height = 16,
    double borderRadius = 4,
  }) {
    return LoadingShimmer(
      key: key,
      child: _ShimmerBox(
        width: width,
        height: height,
        borderRadius: borderRadius,
      ),
    );
  }

  /// Creates a shimmer placeholder for a paragraph (multiple lines).
  factory LoadingShimmer.paragraph({
    Key? key,
    int lines = 3,
    double lineHeight = 14,
    double spacing = 8,
  }) {
    return LoadingShimmer(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(lines, (index) {
          // Last line is shorter
          final width = index == lines - 1 ? 0.6 : 1.0;
          return Padding(
            padding: EdgeInsets.only(bottom: index < lines - 1 ? spacing : 0),
            child: FractionallySizedBox(
              widthFactor: width,
              child: _ShimmerBox(
                height: lineHeight,
                borderRadius: 4,
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Creates a shimmer placeholder for a circular avatar.
  factory LoadingShimmer.avatar({
    Key? key,
    double size = 40,
  }) {
    return LoadingShimmer(
      key: key,
      child: _ShimmerBox(
        width: size,
        height: size,
        borderRadius: size / 2,
      ),
    );
  }

  /// Creates a shimmer placeholder for a card.
  factory LoadingShimmer.card({
    Key? key,
    double? height,
    double? width,
  }) {
    return LoadingShimmer(
      key: key,
      child: _ShimmerBox(
        width: width ?? double.infinity,
        height: height ?? 120,
        borderRadius: AppSpacing.radiusLg,
      ),
    );
  }

  /// Creates a shimmer placeholder for a list item.
  factory LoadingShimmer.listItem({
    Key? key,
    bool showAvatar = true,
    bool showSubtitle = true,
    bool showTrailing = false,
  }) {
    return LoadingShimmer(
      key: key,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            if (showAvatar) ...[
              const _ShimmerBox(
                width: 40,
                height: 40,
                borderRadius: 20,
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _ShimmerBox(
                    height: 16,
                    borderRadius: 4,
                  ),
                  if (showSubtitle) ...[
                    const SizedBox(height: 8),
                    const FractionallySizedBox(
                      widthFactor: 0.6,
                      child: _ShimmerBox(
                        height: 12,
                        borderRadius: 4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showTrailing) ...[
              const SizedBox(width: AppSpacing.md),
              const _ShimmerBox(
                width: 24,
                height: 24,
                borderRadius: 4,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Creates a shimmer placeholder for an observation card.
  factory LoadingShimmer.observationCard({Key? key}) {
    return LoadingShimmer(
      key: key,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            _ShimmerBox(
              height: 180,
              borderRadius: AppSpacing.radiusMd,
            ),
            SizedBox(height: AppSpacing.md),
            // Title
            FractionallySizedBox(
              widthFactor: 0.7,
              child: _ShimmerBox(
                height: 18,
                borderRadius: 4,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            // Subtitle
            FractionallySizedBox(
              widthFactor: 0.4,
              child: _ShimmerBox(
                height: 14,
                borderRadius: 4,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            // Footer row
            Row(
              children: [
                _ShimmerBox(
                  width: 60,
                  height: 24,
                  borderRadius: 12,
                ),
                SizedBox(width: AppSpacing.sm),
                _ShimmerBox(
                  width: 80,
                  height: 24,
                  borderRadius: 12,
                ),
                Spacer(),
                _ShimmerBox(
                  width: 24,
                  height: 24,
                  borderRadius: 4,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a shimmer placeholder for a foray card.
  factory LoadingShimmer.forayCard({Key? key}) {
    return LoadingShimmer(
      key: key,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ShimmerBox(
                  width: 48,
                  height: 48,
                  borderRadius: 24,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(
                        height: 18,
                        borderRadius: 4,
                      ),
                      SizedBox(height: 8),
                      FractionallySizedBox(
                        widthFactor: 0.5,
                        child: _ShimmerBox(
                          height: 14,
                          borderRadius: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _ShimmerBox(
                  width: 80,
                  height: 28,
                  borderRadius: 14,
                ),
                SizedBox(width: AppSpacing.sm),
                _ShimmerBox(
                  width: 100,
                  height: 28,
                  borderRadius: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// The placeholder content to animate with shimmer.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark
        ? AppColors.surfaceDark
        : Colors.grey[300]!;

    final highlightColor = isDark
        ? AppColors.dividerDark
        : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}

/// A simple box shape for shimmer placeholders.
class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    this.width,
    required this.height,
    this.borderRadius = 4,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// A list of shimmer items for loading lists.
class LoadingShimmerList extends StatelessWidget {
  /// Creates a [LoadingShimmerList].
  const LoadingShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemBuilder,
    this.separatorHeight = 0,
    this.padding,
  });

  /// Number of shimmer items to display.
  final int itemCount;

  /// Custom builder for each shimmer item.
  final Widget Function(BuildContext, int)? itemBuilder;

  /// Height of separator between items.
  final double separatorHeight;

  /// Padding around the list.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: separatorHeight),
      itemBuilder: (context, index) =>
          itemBuilder?.call(context, index) ?? LoadingShimmer.listItem(),
    );
  }
}
