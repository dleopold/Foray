import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../database/database.dart';
import '../../../../database/daos/collaboration_dao.dart';

/// Provides a stream of comments for an observation.
final commentsProvider =
    StreamProvider.family<List<CommentWithAuthor>, String>((ref, observationId) {
  final db = ref.watch(databaseProvider);
  return db.collaborationDao.watchCommentsForObservation(observationId);
});

/// Provides comment count for an observation.
final commentCountProvider = Provider.family<int, String>((ref, observationId) {
  final comments = ref.watch(commentsProvider(observationId));
  return comments.valueOrNull?.length ?? 0;
});
