import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/inputs/foray_text_field.dart';
import '../../../../database/database.dart';
import '../../../../routing/routes.dart';

/// Bottom sheet for looking up specimens by ID or barcode/QR scan.
class SpecimenLookupSheet extends ConsumerStatefulWidget {
  const SpecimenLookupSheet({super.key, required this.forayId});

  final String forayId;

  @override
  ConsumerState<SpecimenLookupSheet> createState() =>
      _SpecimenLookupSheetState();
}

class _SpecimenLookupSheetState extends ConsumerState<SpecimenLookupSheet> {
  final _controller = TextEditingController();
  bool _showScanner = false;
  bool _isSearching = false;
  bool _hasScanned = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Find Specimen',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: Icon(
                        _showScanner ? Icons.keyboard : Icons.qr_code_scanner,
                      ),
                      onPressed: () => setState(() {
                        _showScanner = !_showScanner;
                        _hasScanned = false;
                        _error = null;
                      }),
                      tooltip: _showScanner ? 'Enter manually' : 'Scan QR code',
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _showScanner ? _buildScanner() : _buildSearchInput(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          ForayTextField(
            controller: _controller,
            hint: 'Enter specimen ID',
            prefixIcon: Icons.search,
            error: _error,
            onSubmitted: (_) => _search(),
            suffixIcon: Icons.arrow_forward,
            onSuffixTap: _search,
          ),
          const SizedBox(height: AppSpacing.md),
          if (_isSearching)
            const CircularProgressIndicator()
          else
            Text(
              'Enter the specimen ID or scan the QR code on the specimen tag',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    return Column(
      children: [
        // QR Scanner
        Expanded(
          child: Stack(
            children: [
              MobileScanner(
                onDetect: _onDetectBarcode,
              ),
              // Scan area frame
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom controls
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Point camera at specimen QR code',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => setState(() {
                  _showScanner = false;
                  _hasScanned = false;
                }),
                child: const Text('Enter Manually'),
              ),
            ],
          ),
        ),
        if (_isSearching)
          Container(
            color: Colors.black54,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  void _onDetectBarcode(BarcodeCapture capture) {
    // Prevent multiple scans from being processed
    if (_hasScanned || _isSearching) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final String? rawValue = barcode.rawValue;

    if (rawValue != null && rawValue.isNotEmpty) {
      setState(() {
        _hasScanned = true;
        _controller.text = rawValue;
      });
      _search();
    }
  }

  Future<void> _search() async {
    final specimenId = _controller.text.trim();
    if (specimenId.isEmpty) {
      setState(() => _error = 'Please enter a specimen ID');
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final db = ref.read(databaseProvider);
      final observation = await db.observationsDao.getObservationBySpecimenId(
        widget.forayId,
        specimenId,
      );

      if (observation == null) {
        setState(() => _error = 'Specimen not found in this foray');
        return;
      }

      if (mounted) {
        Navigator.pop(context);
        context.push(
          AppRoutes.observationDetail.replaceFirst(':id', observation.id),
        );
      }
    } catch (e) {
      setState(() => _error = 'Error searching: $e');
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }
}
