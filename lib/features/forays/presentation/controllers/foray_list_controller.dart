import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../database/database.dart';
import '../../../../database/daos/forays_dao.dart';
import '../../../../database/tables/forays_table.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Provides a stream of all forays for the current user.
final forayListProvider = StreamProvider<List<ForayWithRole>>((ref) {
  final db = ref.watch(databaseProvider);
  final authState = ref.watch(authControllerProvider);

  if (authState.user == null) {
    return Stream.value([]);
  }

  return db.foraysDao.watchForaysForUser(authState.user!.id);
});

/// Provides active forays (filtering from forayListProvider).
final activeForaysProvider = Provider<List<ForayWithRole>>((ref) {
  final forays = ref.watch(forayListProvider).valueOrNull ?? [];
  return forays.where((f) => f.foray.status == ForayStatus.active).toList();
});

/// Provides completed forays (filtering from forayListProvider).
final completedForaysProvider = Provider<List<ForayWithRole>>((ref) {
  final forays = ref.watch(forayListProvider).valueOrNull ?? [];
  return forays.where((f) => f.foray.status == ForayStatus.completed).toList();
});
