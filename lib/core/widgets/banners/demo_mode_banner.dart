import 'package:flutter/material.dart';

import '../../config/platform_config.dart';
import '../../theme/app_spacing.dart';

/// Banner shown at the top of the app when running in demo mode (web).
///
/// Informs users that some features are simulated.
class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show on web
    if (!DemoConfig.showDemoBanner) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.science_outlined,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Demo Mode - GPS & Compass Simulated',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps content with a demo mode banner at the top.
class DemoModeWrapper extends StatelessWidget {
  const DemoModeWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!DemoConfig.showDemoBanner) {
      return child;
    }

    return Column(
      children: [
        const DemoModeBanner(),
        Expanded(child: child),
      ],
    );
  }
}
