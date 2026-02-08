import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../database/database.dart';
import '../../../../routing/routes.dart';
import '../../../../services/location/location_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/map_config.dart';
import '../widgets/foray_map.dart';
import '../widgets/observation_marker.dart';

/// Provider for the current user's observations across all forays.
final personalObservationsProvider =
    FutureProvider<List<Observation>>((ref) async {
  final db = ref.watch(databaseProvider);
  final authState = ref.watch(authControllerProvider);
  final user = authState.user;

  if (user == null) return [];

  return db.observationsDao.getObservationsForUser(user.id);
});

/// Screen showing all of the user's observations across all forays on a map.
class PersonalMapScreen extends ConsumerStatefulWidget {
  const PersonalMapScreen({super.key});

  @override
  ConsumerState<PersonalMapScreen> createState() => _PersonalMapScreenState();
}

class _PersonalMapScreenState extends ConsumerState<PersonalMapScreen> {
  final _mapController = MapController();
  String? _selectedObservationId;

  // Filters
  DateTimeRange? _dateFilter;
  String? _speciesFilter;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final observationsAsync = ref.watch(personalObservationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Observations'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _dateFilter != null || _speciesFilter != null,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilters,
            tooltip: 'Filter observations',
          ),
        ],
      ),
      body: observationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Error: $err'),
              ],
            ),
          ),
        ),
        data: (observations) {
          final filtered = _applyFilters(observations);

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    observations.isEmpty
                        ? 'No observations yet'
                        : 'No observations match filters',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (_dateFilter != null || _speciesFilter != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear Filters'),
                    ),
                  ],
                ],
              ),
            );
          }

          final markers = filtered.map((obs) {
            return ObservationMarkerBuilder.build(
              observation: obs,
              isSelected: obs.id == _selectedObservationId,
              onTap: () => setState(() => _selectedObservationId = obs.id),
            );
          }).toList();

          return Stack(
            children: [
              ForayMap(
                controller: _mapController,
                center: _calculateCenter(filtered),
                markers: markers,
                onTap: (_, __) =>
                    setState(() => _selectedObservationId = null),
              ),

              // Fit all button
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'fit_all',
                      onPressed: () => _fitAllMarkers(filtered),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      child: const Icon(Icons.fit_screen),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FloatingActionButton.small(
                      heroTag: 'my_location',
                      onPressed: _goToMyLocation,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      child: const Icon(Icons.my_location),
                    ),
                  ],
                ),
              ),

              // Selection panel
              if (_selectedObservationId != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildSelectionPanel(filtered),
                ),
            ],
          );
        },
      ),
    );
  }

  LatLng _calculateCenter(List<Observation> observations) {
    if (observations.isEmpty) return MapConfig.defaultCenter;

    var sumLat = 0.0;
    var sumLon = 0.0;
    for (final obs in observations) {
      sumLat += obs.latitude;
      sumLon += obs.longitude;
    }
    return LatLng(
      sumLat / observations.length,
      sumLon / observations.length,
    );
  }

  List<Observation> _applyFilters(List<Observation> observations) {
    var filtered = observations;

    if (_dateFilter != null) {
      filtered = filtered.where((o) {
        return o.observedAt.isAfter(_dateFilter!.start) &&
            o.observedAt
                .isBefore(_dateFilter!.end.add(const Duration(days: 1)));
      }).toList();
    }

    if (_speciesFilter != null && _speciesFilter!.isNotEmpty) {
      filtered = filtered.where((o) {
        return o.preliminaryId
                ?.toLowerCase()
                .contains(_speciesFilter!.toLowerCase()) ??
            false;
      }).toList();
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _dateFilter = null;
      _speciesFilter = null;
    });
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _FilterSheet(
          dateFilter: _dateFilter,
          speciesFilter: _speciesFilter,
          onApply: (date, species) {
            setState(() {
              _dateFilter = date;
              _speciesFilter = species;
            });
            Navigator.pop(context);
          },
          onClear: () {
            _clearFilters();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    final locationService = ref.read(locationServiceProvider);
    final position = await locationService.getCurrentPosition();
    if (position != null) {
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        15,
      );
    }
  }

  void _fitAllMarkers(List<Observation> observations) {
    if (observations.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(
      observations.map((o) => LatLng(o.latitude, o.longitude)).toList(),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(MapConfig.boundsPadding),
      ),
    );
  }

  Widget _buildSelectionPanel(List<Observation> observations) {
    final selected = observations.firstWhere(
      (o) => o.id == _selectedObservationId,
    );

    return Card(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: InkWell(
        onTap: () => context.push(
          AppRoutes.observationDetail.replaceFirst(':id', selected.id),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: const Icon(Icons.eco),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selected.preliminaryId ?? 'Unknown species',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      Formatters.date(selected.observedAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.navigation),
                onPressed: () => context.push(
                  AppRoutes.navigate.replaceFirst(':observationId', selected.id),
                ),
                tooltip: 'Navigate',
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    this.dateFilter,
    this.speciesFilter,
    required this.onApply,
    required this.onClear,
  });

  final DateTimeRange? dateFilter;
  final String? speciesFilter;
  final void Function(DateTimeRange?, String?) onApply;
  final VoidCallback onClear;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  DateTimeRange? _dateFilter;
  final _speciesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateFilter = widget.dateFilter;
    _speciesController.text = widget.speciesFilter ?? '';
  }

  @override
  void dispose() {
    _speciesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Observations',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: widget.onClear,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Date filter
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date Range'),
            subtitle: Text(_dateFilter == null
                ? 'All time'
                : '${Formatters.date(_dateFilter!.start)} - ${Formatters.date(_dateFilter!.end)}',),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_dateFilter != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _dateFilter = null),
                  ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: _dateFilter,
                    );
                    if (picked != null) {
                      setState(() => _dateFilter = picked);
                    }
                  },
                ),
              ],
            ),
          ),

          // Species filter
          TextField(
            controller: _speciesController,
            decoration: const InputDecoration(
              labelText: 'Species',
              hintText: 'Filter by species name',
              prefixIcon: Icon(Icons.search),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onApply(
                _dateFilter,
                _speciesController.text.trim().isEmpty
                    ? null
                    : _speciesController.text.trim(),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
