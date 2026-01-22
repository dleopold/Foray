import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../database/database.dart';
import '../../../../database/tables/forays_table.dart';
import '../../../../routing/routes.dart';
import '../controllers/foray_detail_controller.dart';
import '../widgets/foray_feed_tab.dart';
import '../widgets/foray_map_tab.dart';
import '../widgets/foray_participants_tab.dart';
import '../widgets/foray_settings_tab.dart';
import '../widgets/share_foray_sheet.dart';

/// Screen displaying foray details with tabbed navigation.
///
/// Shows Feed, Map, Participants (group only), and Settings (organizer only) tabs.
/// Active forays display a FAB for adding new observations.
class ForayDetailScreen extends ConsumerStatefulWidget {
  const ForayDetailScreen({
    super.key,
    required this.forayId,
  });

  final String forayId;

  @override
  ConsumerState<ForayDetailScreen> createState() => _ForayDetailScreenState();
}

class _ForayDetailScreenState extends ConsumerState<ForayDetailScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _initTabController(int tabCount) {
    if (_tabController?.length != tabCount) {
      _tabController?.dispose();
      _tabController = TabController(length: tabCount, vsync: this);
    }
  }

  @override
  Widget build(BuildContext context) {
    final forayAsync = ref.watch(forayDetailProvider(widget.forayId));
    final isOrganizerAsync = ref.watch(isOrganizerProvider(widget.forayId));

    return forayAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $err')),
      ),
      data: (foray) {
        if (foray == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Foray not found')),
          );
        }

        final isOrganizer = isOrganizerAsync.valueOrNull ?? false;

        // Calculate number of tabs
        int tabCount = 2; // Feed and Map always shown
        if (!foray.isSolo) tabCount++; // Participants tab
        if (isOrganizer) tabCount++; // Settings tab

        _initTabController(tabCount);

        return Scaffold(
          appBar: AppBar(
            title: Text(foray.name),
            actions: [
              if (!foray.isSolo)
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _showShareSheet(context, foray),
                  tooltip: 'Share',
                ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _showSpecimenLookup(context),
                tooltip: 'Find Specimen',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: _buildTabs(foray, isOrganizer),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: _buildTabViews(foray, isOrganizer),
          ),
          floatingActionButton: foray.status == ForayStatus.active
              ? FloatingActionButton.extended(
                  onPressed: () => context.push(
                    AppRoutes.createObservation
                        .replaceFirst(':forayId', widget.forayId),
                  ),
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Add Observation'),
                )
              : null,
        );
      },
    );
  }

  List<Widget> _buildTabs(Foray foray, bool isOrganizer) {
    final tabs = <Widget>[
      const Tab(icon: Icon(Icons.list), text: 'Feed'),
      const Tab(icon: Icon(Icons.map), text: 'Map'),
    ];

    if (!foray.isSolo) {
      tabs.add(const Tab(icon: Icon(Icons.people), text: 'People'));
    }

    if (isOrganizer) {
      tabs.add(const Tab(icon: Icon(Icons.settings), text: 'Settings'));
    }

    return tabs;
  }

  List<Widget> _buildTabViews(Foray foray, bool isOrganizer) {
    final views = <Widget>[
      ForayFeedTab(forayId: widget.forayId),
      ForayMapTab(forayId: widget.forayId),
    ];

    if (!foray.isSolo) {
      views.add(ForayParticipantsTab(forayId: widget.forayId));
    }

    if (isOrganizer) {
      views.add(ForaySettingsTab(forayId: widget.forayId));
    }

    return views;
  }

  void _showShareSheet(BuildContext context, Foray foray) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ShareForaySheet(foray: foray),
    );
  }

  void _showSpecimenLookup(BuildContext context) {
    // TODO: Implement specimen lookup in Phase 6
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Find Specimen',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text('Specimen lookup coming in Phase 6'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
