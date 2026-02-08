import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../database/database.dart';
import '../../../../database/tables/forays_table.dart';
import '../../../../routing/routes.dart';
import '../../../auth/domain/feature_gate.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/foray_list_controller.dart';
import '../widgets/foray_card.dart';

/// Main screen displaying the user's forays.
///
/// Shows active and completed forays grouped by status, with options
/// to create solo/group forays or join existing group forays.
class ForayListScreen extends ConsumerWidget {
  const ForayListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foraysAsync = ref.watch(forayListProvider);
    final activeForays = ref.watch(activeForaysProvider);
    final completedForays = ref.watch(completedForaysProvider);
    final featureGate = ref.watch(featureGateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Forays'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () => context.push(AppRoutes.personalMap),
            tooltip: 'My Map',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: foraysAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (forays) {
          if (forays.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(forayListProvider);
            },
            child: CustomScrollView(
              slivers: [
                // Active forays section
                if (activeForays.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Active Forays',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding,),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: ForayCard(
                            forayWithRole: activeForays[index],
                            onTap: () => context.push(
                              AppRoutes.forayDetail.replaceFirst(
                                  ':id', activeForays[index].foray.id,),
                            ),
                          ),
                        ),
                        childCount: activeForays.length,
                      ),
                    ),
                  ),
                ],

                // Completed forays section
                if (completedForays.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Completed',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding,),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: ForayCard(
                            forayWithRole: completedForays[index],
                            onTap: () => context.push(
                              AppRoutes.forayDetail.replaceFirst(
                                  ':id', completedForays[index].foray.id,),
                            ),
                          ),
                        ),
                        childCount: completedForays.length,
                      ),
                    ),
                  ),
                ],

                // Bottom padding
                const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Join foray button (authenticated only)
          if (featureGate.canJoinForay)
            FloatingActionButton.small(
              heroTag: 'join',
              onPressed: () => context.push(AppRoutes.joinForay),
              child: const Icon(Icons.group_add),
            ),
          const SizedBox(height: AppSpacing.sm),
          // Quick start solo foray
          FloatingActionButton.extended(
            heroTag: 'create',
            onPressed: () => _showCreateOptions(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('New Foray'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No forays yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start a solo foray to begin documenting your finds, or join a group foray.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateOptions(BuildContext context, WidgetRef ref) {
    final featureGate = ref.read(featureGateProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Solo Foray'),
              subtitle: const Text('Just me, personal collection'),
              onTap: () {
                Navigator.pop(context);
                _createSoloForay(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Group Foray'),
              subtitle: const Text('Invite others to join'),
              enabled: featureGate.canCreateGroupForay,
              onTap: featureGate.canCreateGroupForay
                  ? () {
                      Navigator.pop(context);
                      context.push(AppRoutes.createForay);
                    }
                  : null,
            ),
            if (!featureGate.canCreateGroupForay)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Sign in to create group forays',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSoloForay(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final authState = ref.read(authControllerProvider);
    final user = authState.user;

    if (user == null) return;

    final forayId = const Uuid().v4();
    await db.foraysDao.createForay(ForaysCompanion.insert(
      id: forayId,
      creatorId: user.id,
      name: 'Personal Foray - ${DateTime.now().toString().split(' ')[0]}',
      date: DateTime.now(),
      defaultPrivacy: const Value(PrivacyLevel.private),
      isSolo: const Value(true),
    ),);

    await db.foraysDao.addParticipant(
      forayId: forayId,
      userId: user.id,
      role: ParticipantRole.organizer,
    );

    if (context.mounted) {
      context.push(AppRoutes.forayDetail.replaceFirst(':id', forayId));
    }
  }
}
