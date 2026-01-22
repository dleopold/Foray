import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../database/database.dart';
import '../../../../database/daos/forays_dao.dart';
import '../../../../database/tables/forays_table.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Provides a stream of foray details by ID.
final forayDetailProvider =
    StreamProvider.family<Foray?, String>((ref, forayId) {
  final db = ref.watch(databaseProvider);

  // Watch the foray by selecting it from the database
  return db
      .select(db.forays)
      .watch()
      .map((forays) => forays.where((f) => f.id == forayId).firstOrNull);
});

/// Provides whether the current user is an organizer of the foray.
final isOrganizerProvider = FutureProvider.family<bool, String>((ref, forayId) async {
  final db = ref.watch(databaseProvider);
  final authState = ref.watch(authControllerProvider);

  if (authState.user == null) return false;

  final role = await db.foraysDao.getUserRole(forayId, authState.user!.id);
  return role == ParticipantRole.organizer;
});

/// Provides the participants of a foray.
final forayParticipantsProvider =
    StreamProvider.family<List<ParticipantWithUser>, String>((ref, forayId) {
  final db = ref.watch(databaseProvider);
  return db.foraysDao.watchParticipants(forayId);
});

/// Provides the current user's role in a foray.
final currentUserRoleProvider =
    FutureProvider.family<ParticipantRole?, String>((ref, forayId) async {
  final db = ref.watch(databaseProvider);
  final authState = ref.watch(authControllerProvider);

  if (authState.user == null) return null;

  return db.foraysDao.getUserRole(forayId, authState.user!.id);
});
