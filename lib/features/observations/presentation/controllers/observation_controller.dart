import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../database/database.dart';
import '../../../../database/daos/observations_dao.dart';

/// Provides a stream of observations for a specific foray.
final forayObservationsProvider =
    StreamProvider.family<List<ObservationWithDetails>, String>(
        (ref, forayId) {
  final db = ref.watch(databaseProvider);
  return db.observationsDao.watchObservationsForForay(forayId);
});

/// Provides a single observation with details by ID.
final observationDetailProvider =
    FutureProvider.family<ObservationWithDetails?, String>(
        (ref, observationId) async {
  final db = ref.watch(databaseProvider);
  final observation =
      await db.observationsDao.getObservationById(observationId);
  if (observation == null) return null;

  final collector =
      await db.usersDao.getUserById(observation.collectorId);
  final photos =
      await db.observationsDao.getPhotosForObservation(observationId);

  return ObservationWithDetails(
    observation: observation,
    collector: collector,
    photos: photos,
  );
});

/// Provides observation count for a foray.
final forayObservationCountProvider =
    Provider.family<int, String>((ref, forayId) {
  final observations = ref.watch(forayObservationsProvider(forayId));
  return observations.valueOrNull?.length ?? 0;
});

/// Provides draft observations for a foray.
final forayDraftObservationsProvider =
    Provider.family<List<ObservationWithDetails>, String>((ref, forayId) {
  final observations = ref.watch(forayObservationsProvider(forayId));
  return observations.valueOrNull
          ?.where((o) => o.observation.isDraft)
          .toList() ??
      [];
});

/// Provides non-draft observations for a foray.
final forayPublishedObservationsProvider =
    Provider.family<List<ObservationWithDetails>, String>((ref, forayId) {
  final observations = ref.watch(forayObservationsProvider(forayId));
  return observations.valueOrNull
          ?.where((o) => !o.observation.isDraft)
          .toList() ??
      [];
});
