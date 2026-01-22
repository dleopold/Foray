import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/foray_button.dart';
import '../../../../core/widgets/inputs/foray_text_field.dart';
import '../../../../database/database.dart';
import '../../../../database/tables/forays_table.dart';
import '../../../../routing/routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Screen for joining an existing foray via code or QR.
///
/// Users can either enter a 6-character join code or scan a QR code
/// to join a group foray created by someone else.
class JoinForayScreen extends ConsumerStatefulWidget {
  const JoinForayScreen({super.key});

  @override
  ConsumerState<JoinForayScreen> createState() => _JoinForayScreenState();
}

class _JoinForayScreenState extends ConsumerState<JoinForayScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _showScanner = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Foray'),
        actions: [
          IconButton(
            icon: Icon(_showScanner ? Icons.keyboard : Icons.qr_code_scanner),
            onPressed: () => setState(() => _showScanner = !_showScanner),
            tooltip: _showScanner ? 'Enter code' : 'Scan QR code',
          ),
        ],
      ),
      body: _showScanner ? _buildScanner() : _buildCodeEntry(),
    );
  }

  Widget _buildCodeEntry() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),

          Icon(
            Icons.group_add,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(
            'Enter Join Code',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ask the foray organizer for the 6-character code',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xl),

          ForayTextField(
            controller: _codeController,
            hint: 'ABC123',
            error: _error,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _joinWithCode(),
          ),

          const SizedBox(height: AppSpacing.lg),

          ForayButton(
            onPressed: _joinWithCode,
            label: 'Join Foray',
            isLoading: _isLoading,
            fullWidth: true,
          ),

          const SizedBox(height: AppSpacing.xl),

          TextButton.icon(
            onPressed: () => setState(() => _showScanner = true),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR Code Instead'),
          ),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    // TODO: Implement QR scanner with mobile_scanner package
    return Stack(
      children: [
        // Placeholder for scanner
        Container(
          color: Colors.black87,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 64,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'QR Scanner Coming Soon',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'For now, please enter the code manually',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: AppSpacing.xl,
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Point camera at QR code',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => setState(() => _showScanner = false),
                    child: const Text('Enter code manually'),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  void _handleScannedCode(String value) {
    // Parse join code from URL or direct code
    String code = value;

    // Check if it's a URL (foray://join/XXXXXX or https://foray.app/join/XXXXXX)
    final uri = Uri.tryParse(value);
    if (uri != null &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == 'join') {
      code = uri.pathSegments[1];
    }

    _codeController.text = code.toUpperCase();
    setState(() => _showScanner = false);
    _joinWithCode();
  }

  Future<void> _joinWithCode() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.length != 6) {
      setState(() => _error = 'Code must be 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final db = ref.read(databaseProvider);
      final authState = ref.read(authControllerProvider);
      final user = authState.user;

      if (user == null) throw Exception('Not authenticated');

      // Look up foray by code
      final foray = await db.foraysDao.getForayByJoinCode(code);

      if (foray == null) {
        setState(() => _error = 'Invalid code. Please check and try again.');
        return;
      }

      // Check if already a participant
      final participants = await db.foraysDao.getParticipants(foray.id);
      if (participants.any((p) => p.user.id == user.id)) {
        // Already joined, just navigate
        if (mounted) {
          context.go(AppRoutes.forayDetail.replaceFirst(':id', foray.id));
        }
        return;
      }

      // Check if foray is still active
      if (foray.status == ForayStatus.completed) {
        setState(() => _error =
            'This foray has been completed and is no longer accepting participants.');
        return;
      }

      // Add as participant
      await db.foraysDao.addParticipant(
        forayId: foray.id,
        userId: user.id,
        role: ParticipantRole.participant,
      );

      // TODO: Queue for sync when sync is implemented
      // await db.syncDao.enqueue(
      //   entityType: 'foray_participant',
      //   entityId: '${foray.id}_${user.id}',
      //   operation: SyncOperation.create,
      // );

      if (mounted) {
        context.go(AppRoutes.forayDetail.replaceFirst(':id', foray.id));
      }
    } catch (e) {
      setState(() => _error = 'Failed to join foray: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
