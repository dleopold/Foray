import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/feedback/foray_snackbar.dart';
import '../../../../database/database.dart';

/// Bottom sheet for sharing a foray via QR code or join code.
///
/// Displays the QR code for scanning and the text join code for
/// manual entry. Provides options to copy link and share.
class ShareForaySheet extends StatelessWidget {
  const ShareForaySheet({super.key, required this.foray});

  final Foray foray;

  String get shareUrl => 'https://foray.app/join/${foray.joinCode}';

  @override
  Widget build(BuildContext context) {
    if (foray.joinCode == null) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Solo Foray',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Solo forays cannot be shared. Create a group foray to invite others.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Foray',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),

            // QR Code placeholder
            // TODO: Add qr_flutter package and generate QR code
            Container(
              width: 200,
              height: 200,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_2,
                    size: 100,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'QR Code',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Join code
            Text(
              'Join Code',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: foray.joinCode ?? ''));
                ForaySnackbar.showSuccess(context, 'Code copied to clipboard');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      foray.joinCode ?? '',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                letterSpacing: 4,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(Icons.copy, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Share buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(
                  icon: Icons.share,
                  label: 'Share Link',
                  onTap: () {
                    // TODO: Add share_plus package
                    Clipboard.setData(ClipboardData(text: shareUrl));
                    ForaySnackbar.showSuccess(context, 'Link copied to clipboard');
                  },
                ),
                _ShareOption(
                  icon: Icons.copy,
                  label: 'Copy Link',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: shareUrl));
                    ForaySnackbar.showSuccess(context, 'Link copied to clipboard');
                  },
                ),
                _ShareOption(
                  icon: Icons.picture_as_pdf,
                  label: 'Export QR',
                  onTap: () {
                    // TODO: Generate PDF with QR codes for printing
                    ForaySnackbar.showInfo(context, 'QR export coming soon');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
