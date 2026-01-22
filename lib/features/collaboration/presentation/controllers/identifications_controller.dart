import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../database/database.dart';
import '../../../../database/daos/collaboration_dao.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Provides a stream of identifications for an observation.
final identificationsProvider =
    StreamProvider.family<List<IdentificationWithDetails>, String>(
        (ref, observationId) {
  final db = ref.watch(databaseProvider);
  return db.collaborationDao.watchIdentificationsForObservation(observationId);
});

/// Provides the ID the current user has voted for.
final userVoteProvider = FutureProvider.family<String?, String>(
  (ref, observationId) async {
    final db = ref.watch(databaseProvider);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    if (user == null) return null;

    return db.collaborationDao.getUserVoteForObservation(observationId, user.id);
  },
);

/// Provides identification count for an observation.
final identificationCountProvider =
    Provider.family<int, String>((ref, observationId) {
  final identifications = ref.watch(identificationsProvider(observationId));
  return identifications.valueOrNull?.length ?? 0;
});
