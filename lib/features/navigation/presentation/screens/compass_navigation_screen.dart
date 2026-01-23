import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/gps_utils.dart';
import '../../../../core/widgets/compass/bearing_indicator.dart';
import '../../../../core/widgets/compass/compass_rose.dart';
import '../../../../core/widgets/compass/distance_display.dart';
import '../../../../core/widgets/indicators/gps_accuracy_indicator.dart';
import '../../../../database/database.dart';
import '../../../../routing/routes.dart';
import '../../../../services/compass/compass_service.dart';
import '../../../../services/location/location_service.dart';
import '../widgets/arrival_celebration.dart';
import '../widgets/compass_calibration_prompt.dart';

/// Screen for compass-based navigation to an observation location.
class CompassNavigationScreen extends ConsumerStatefulWidget {
  const CompassNavigationScreen({
    super.key,
    required this.observationId,
  });

  final String observationId;

  @override
  ConsumerState<CompassNavigationScreen> createState() =>
      _CompassNavigationScreenState();
}

class _CompassNavigationScreenState
    extends ConsumerState<CompassNavigationScreen> {
  Observation? _targetObservation;
  Position? _currentPosition;
  double? _previousDistance;
  double? _currentDistance;
  double? _targetBearing;
  double? _currentHeading;
  bool _hasArrived = false;
  bool _isLoading = true;
  String? _error;
  bool _needsCalibration = false;
  bool _dismissedCalibration = false;
  bool _dismissedPoorGps = false;

  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<double?>? _headingSubscription;

  @override
  void initState() {
    super.initState();
    _loadObservation();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _headingSubscription?.cancel();
    ref.read(compassServiceProvider).stopListening();
    super.dispose();
  }

  Future<void> _loadObservation() async {
    try {
      final db = ref.read(databaseProvider);
      final observation =
          await db.observationsDao.getObservationById(widget.observationId);

      if (observation == null) {
        setState(() {
          _error = 'Observation not found';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _targetObservation = observation;
        _isLoading = false;
      });

      _startTracking();
    } catch (e) {
      setState(() {
        _error = 'Failed to load observation: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _startTracking() async {
    // Check compass availability
    final compassService = ref.read(compassServiceProvider);
    await compassService.checkAvailability();

    // Start compass
    compassService.startListening();
    _headingSubscription = compassService.headingStream.listen((heading) {
      setState(() {
        _currentHeading = heading;
        _needsCalibration = compassService.needsCalibration;
      });
    });

    // Start GPS tracking
    final locationService = ref.read(locationServiceProvider);
    final hasPermission = await locationService.checkPermission();

    if (!hasPermission) {
      setState(() => _error = 'Location permission denied');
      return;
    }

    _positionSubscription = locationService.getPositionStream().listen(
      (position) => _updatePosition(position),
      onError: (e) {
        setState(() => _error = 'GPS error: $e');
      },
    );
  }

  void _updatePosition(Position position) {
    if (_targetObservation == null) return;

    final distance = GpsUtils.calculateDistance(
      position.latitude,
      position.longitude,
      _targetObservation!.latitude,
      _targetObservation!.longitude,
    );

    final bearing = GpsUtils.calculateBearing(
      position.latitude,
      position.longitude,
      _targetObservation!.latitude,
      _targetObservation!.longitude,
    );

    setState(() {
      _previousDistance = _currentDistance;
      _currentDistance = distance;
      _targetBearing = bearing;
      _currentPosition = position;

      // Check for arrival
      if (distance <= AppConstants.arrivalThresholdMeters && !_hasArrived) {
        _triggerArrival();
      }
    });
  }

  void _triggerArrival() {
    setState(() => _hasArrived = true);
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ArrivalCelebration(
        observation: _targetObservation!,
        onDismiss: () {
          Navigator.pop(context);
          setState(() => _hasArrived = false);
        },
        onViewObservation: () {
          context.push(
            AppRoutes.observationDetail
                .replaceFirst(':id', widget.observationId),
          );
        },
      ),
    );
  }

  bool get _showPoorGpsWarning {
    return _currentPosition != null &&
        _currentPosition!.accuracy > 30 &&
        !_dismissedPoorGps;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Navigate')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Navigate')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                    });
                    _loadObservation();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Navigate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: _openInMaps,
            tooltip: 'Open in Maps',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              // Warnings
              if (_needsCalibration && !_dismissedCalibration) ...[
                CompassCalibrationPrompt(
                  onDismiss: () =>
                      setState(() => _dismissedCalibration = true),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (_showPoorGpsWarning) ...[
                PoorGpsPrompt(
                  accuracyMeters: _currentPosition!.accuracy,
                  onDismiss: () => setState(() => _dismissedPoorGps = true),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // GPS accuracy indicator
              if (_currentPosition != null)
                GPSAccuracyIndicator(
                    accuracyMeters: _currentPosition!.accuracy),

              const Spacer(),

              // Compass and bearing indicator
              if (_currentHeading != null && _targetBearing != null)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CompassRose(
                      heading: _currentHeading!,
                      size: 280,
                    ),
                    BearingIndicator(
                      currentHeading: _currentHeading!,
                      targetBearing: _targetBearing!,
                      size: 80,
                    ),
                  ],
                )
              else if (_currentHeading == null)
                _buildLoadingCompass()
              else
                _buildWaitingForGps(),

              const SizedBox(height: AppSpacing.xl),

              // Distance display
              if (_currentDistance != null)
                DistanceDisplay(
                  distanceMeters: _currentDistance!,
                  useMetric: true, // TODO: Get from user preferences
                  previousDistance: _previousDistance,
                ),

              const SizedBox(height: AppSpacing.md),

              // Bearing text
              if (_targetBearing != null)
                Text(
                  GpsUtils.formatBearing(_targetBearing!),
                  style: Theme.of(context).textTheme.titleMedium,
                ),

              const Spacer(),

              // Target observation info
              _buildTargetInfo(),

              const SizedBox(height: AppSpacing.lg),

              // Open in maps button for far distances
              if (_currentDistance != null &&
                  _currentDistance! > AppConstants.farDistanceThresholdKm * 1000)
                OutlinedButton.icon(
                  onPressed: _openInMaps,
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCompass() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 3,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.md),
            Text('Waiting for compass...'),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingForGps() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 3,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.gps_not_fixed, size: 48),
            SizedBox(height: AppSpacing.md),
            Text('Waiting for GPS...'),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(
                Icons.eco,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _targetObservation!.preliminaryId ?? 'Unknown species',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  Text(
                    'Collected ${Formatters.date(_targetObservation!.observedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                context.push(
                  AppRoutes.observationDetail
                      .replaceFirst(':id', widget.observationId),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInMaps() async {
    if (_targetObservation == null) return;

    final lat = _targetObservation!.latitude;
    final lon = _targetObservation!.longitude;

    // Try Google Maps first, fall back to Apple Maps
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon',
    );
    final appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?daddr=$lat,$lon',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(appleMapsUrl)) {
      await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps app')),
        );
      }
    }
  }
}
