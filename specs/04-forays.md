# Specification: Foray Management

**Phase:** 4  
**Estimated Duration:** 5-6 days  
**Dependencies:** Phase 3 complete

---

## 1. Foray List Screen

### 1.1 Foray List Provider

```dart
// lib/features/forays/presentation/controllers/foray_list_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foray/database/database.dart';
import 'package:foray/features/auth/presentation/controllers/auth_controller.dart';

final forayListProvider = StreamProvider<List<ForayWithRole>>((ref) {
  final db = ref.watch(databaseProvider);
  final authState = ref.watch(authControllerProvider);
  
  if (authState.user == null) {
    return Stream.value([]);
  }
  
  return db.foraysDao.watchForaysForUser(authState.user!.id);
});

final activeForaysProvider = Provider<List<ForayWithRole>>((ref) {
  final forays = ref.watch(forayListProvider).valueOrNull ?? [];
  return forays.where((f) => f.foray.status == ForayStatus.active).toList();
});

final completedForaysProvider = Provider<List<ForayWithRole>>((ref) {
  final forays = ref.watch(forayListProvider).valueOrNull ?? [];
  return forays.where((f) => f.foray.status == ForayStatus.completed).toList();
});
```

### 1.2 Foray List Screen UI

```dart
// lib/features/forays/presentation/screens/foray_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/features/forays/presentation/controllers/foray_list_controller.dart';
import 'package:foray/features/forays/presentation/widgets/foray_card.dart';
import 'package:foray/features/auth/presentation/controllers/auth_controller.dart';
import 'package:foray/features/auth/domain/feature_gate.dart';
import 'package:foray/routing/routes.dart';

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
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: ForayCard(
                            forayWithRole: activeForays[index],
                            onTap: () => context.push(
                              AppRoutes.forayDetail.replaceFirst(':id', activeForays[index].foray.id),
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
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: ForayCard(
                            forayWithRole: completedForays[index],
                            onTap: () => context.push(
                              AppRoutes.forayDetail.replaceFirst(':id', completedForays[index].foray.id),
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
    ));
    
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
```

### 1.3 Foray Card Widget

```dart
// lib/features/forays/presentation/widgets/foray_card.dart
import 'package:flutter/material.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/core/theme/app_colors.dart';
import 'package:foray/core/extensions/datetime_extensions.dart';
import 'package:foray/database/database.dart';

class ForayCard extends StatelessWidget {
  const ForayCard({
    super.key,
    required this.forayWithRole,
    required this.onTap,
  });

  final ForayWithRole forayWithRole;
  final VoidCallback onTap;

  Foray get foray => forayWithRole.foray;
  ParticipantRole get role => forayWithRole.role;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Solo/Group icon
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: foray.isSolo
                          ? AppColors.secondary.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(
                      foray.isSolo ? Icons.person : Icons.group,
                      size: 20,
                      color: foray.isSolo ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  
                  // Name and date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          foray.name,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          foray.date.formatted,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  
                  // Status chip
                  if (foray.status == ForayStatus.completed)
                    Chip(
                      label: const Text('Completed'),
                      labelStyle: Theme.of(context).textTheme.labelSmall,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  
                  // Role badge for non-solo forays
                  if (!foray.isSolo && role == ParticipantRole.organizer)
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: Chip(
                        label: const Text('Organizer'),
                        labelStyle: Theme.of(context).textTheme.labelSmall,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                ],
              ),
              
              if (foray.locationName != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        foray.locationName!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              
              // TODO: Add observation count when available
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 2. Solo Foray Creation

Solo forays are created with a single tap via the "Quick Start" option. The implementation is in the foray list screen above.

### 2.1 Solo Foray Defaults

- Name: "Personal Foray - [Date]"
- Privacy: Private
- No join code
- `isSolo: true`
- Auto-add creator as organizer

---

## 3. Group Foray Creation

### 3.1 Create Foray Screen

```dart
// lib/features/forays/presentation/screens/create_foray_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/core/widgets/buttons/foray_button.dart';
import 'package:foray/core/widgets/inputs/foray_text_field.dart';
import 'package:foray/core/constants/privacy_levels.dart';
import 'package:foray/database/database.dart';
import 'package:foray/features/auth/presentation/controllers/auth_controller.dart';
import 'package:foray/routing/routes.dart';

class CreateForayScreen extends ConsumerStatefulWidget {
  const CreateForayScreen({super.key});

  @override
  ConsumerState<CreateForayScreen> createState() => _CreateForayScreenState();
}

class _CreateForayScreenState extends ConsumerState<CreateForayScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _date = DateTime.now();
  PrivacyLevel _defaultPrivacy = PrivacyLevel.foray;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Foray'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            // Name
            ForayTextField(
              controller: _nameController,
              label: 'Foray Name',
              hint: 'e.g., Fall Mushroom Walk',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Description
            ForayTextField(
              controller: _descriptionController,
              label: 'Description (optional)',
              hint: 'What will you be looking for?',
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(_date.toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => _date = picked);
                }
              },
            ),
            const Divider(),
            
            // Location name
            ForayTextField(
              controller: _locationController,
              label: 'Location (optional)',
              hint: 'e.g., Mount Rainier National Park',
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Default privacy
            Text(
              'Default Privacy for Observations',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Participants can always increase privacy but cannot decrease it below this level.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            
            ...PrivacyLevel.values.map((level) => RadioListTile<PrivacyLevel>(
              title: Text(level.label),
              subtitle: Text(level.description),
              value: level,
              groupValue: _defaultPrivacy,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _defaultPrivacy = value);
                }
              },
            )),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Create button
            ForayButton(
              onPressed: _submit,
              label: 'Create Foray',
              isLoading: _isLoading,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final db = ref.read(databaseProvider);
      final authState = ref.read(authControllerProvider);
      final user = authState.user;
      
      if (user == null) throw Exception('Not authenticated');
      
      final forayId = const Uuid().v4();
      final joinCode = _generateJoinCode();
      
      await db.foraysDao.createForay(ForaysCompanion.insert(
        id: forayId,
        creatorId: user.id,
        name: _nameController.text.trim(),
        description: Value(_descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim()),
        date: _date,
        locationName: Value(_locationController.text.trim().isEmpty 
            ? null 
            : _locationController.text.trim()),
        defaultPrivacy: Value(_defaultPrivacy),
        joinCode: Value(joinCode),
        isSolo: const Value(false),
      ));
      
      await db.foraysDao.addParticipant(
        forayId: forayId,
        userId: user.id,
        role: ParticipantRole.organizer,
      );
      
      // Queue for sync
      await db.syncDao.enqueue(
        entityType: 'foray',
        entityId: forayId,
        operation: SyncOperation.create,
      );
      
      if (mounted) {
        context.go(AppRoutes.forayDetail.replaceFirst(':id', forayId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating foray: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
```

---

## 4. Join Foray Flow

### 4.1 Join Foray Screen

```dart
// lib/features/forays/presentation/screens/join_foray_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/core/widgets/buttons/foray_button.dart';
import 'package:foray/core/widgets/inputs/foray_text_field.dart';
import 'package:foray/database/database.dart';
import 'package:foray/features/auth/presentation/controllers/auth_controller.dart';
import 'package:foray/routing/routes.dart';

class JoinForayScreen extends ConsumerStatefulWidget {
  const JoinForayScreen({super.key});

  @override
  ConsumerState<JoinForayScreen> createState() => _JoinForayScreenState();
}

class _JoinForayScreenState extends ConsumerState<JoinForayScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _showScanner = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Foray'),
        actions: [
          IconButton(
            icon: Icon(_showScanner ? Icons.keyboard : Icons.qr_code_scanner),
            onPressed: () => setState(() => _showScanner = !_showScanner),
            tooltip: _showScanner ? 'Enter code' : 'Scan QR code',
          ),
        ],
      ),
      body: _showScanner ? _buildScanner() : _buildCodeEntry(),
    );
  }

  Widget _buildCodeEntry() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          
          Icon(
            Icons.group_add,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          
          Text(
            'Enter Join Code',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ask the foray organizer for the 6-character code',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          ForayTextField(
            controller: _codeController,
            hint: 'ABC123',
            error: _error,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _joinWithCode(),
            // Style for large code entry
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          ForayButton(
            onPressed: _joinWithCode,
            label: 'Join Foray',
            isLoading: _isLoading,
            fullWidth: true,
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          TextButton.icon(
            onPressed: () => setState(() => _showScanner = true),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR Code Instead'),
          ),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            final barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              final value = barcode.rawValue;
              if (value != null) {
                _handleScannedCode(value);
                return;
              }
            }
          },
        ),
        Positioned(
          bottom: AppSpacing.xl,
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Point camera at QR code',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => setState(() => _showScanner = false),
                    child: const Text('Enter code manually'),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  void _handleScannedCode(String value) {
    // Parse join code from URL or direct code
    String code = value;
    
    // Check if it's a URL (foray://join/XXXXXX or https://foray.app/join/XXXXXX)
    final uri = Uri.tryParse(value);
    if (uri != null && uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'join') {
      code = uri.pathSegments[1];
    }
    
    _codeController.text = code.toUpperCase();
    setState(() => _showScanner = false);
    _joinWithCode();
  }

  Future<void> _joinWithCode() async {
    final code = _codeController.text.trim().toUpperCase();
    
    if (code.length != 6) {
      setState(() => _error = 'Code must be 6 characters');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final db = ref.read(databaseProvider);
      final authState = ref.read(authControllerProvider);
      final user = authState.user;
      
      if (user == null) throw Exception('Not authenticated');
      
      // Look up foray by code
      final foray = await db.foraysDao.getForayByJoinCode(code);
      
      if (foray == null) {
        setState(() => _error = 'Invalid code. Please check and try again.');
        return;
      }
      
      // Check if already a participant
      final participants = await db.foraysDao.getParticipants(foray.id);
      if (participants.any((p) => p.user.id == user.id)) {
        // Already joined, just navigate
        if (mounted) {
          context.go(AppRoutes.forayDetail.replaceFirst(':id', foray.id));
        }
        return;
      }
      
      // Check if foray is still active
      if (foray.status == ForayStatus.completed) {
        setState(() => _error = 'This foray has been completed and is no longer accepting participants.');
        return;
      }
      
      // Add as participant
      await db.foraysDao.addParticipant(
        forayId: foray.id,
        userId: user.id,
        role: ParticipantRole.participant,
      );
      
      // Queue for sync
      await db.syncDao.enqueue(
        entityType: 'foray_participant',
        entityId: '${foray.id}_${user.id}',
        operation: SyncOperation.create,
      );
      
      if (mounted) {
        context.go(AppRoutes.forayDetail.replaceFirst(':id', foray.id));
      }
    } catch (e) {
      setState(() => _error = 'Failed to join foray: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
```

---

## 5. Foray Detail Screen

### 5.1 Foray Detail with Tabs

```dart
// lib/features/forays/presentation/screens/foray_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/database/database.dart';
import 'package:foray/features/forays/presentation/controllers/foray_detail_controller.dart';
import 'package:foray/features/forays/presentation/widgets/foray_feed_tab.dart';
import 'package:foray/features/forays/presentation/widgets/foray_map_tab.dart';
import 'package:foray/features/forays/presentation/widgets/foray_participants_tab.dart';
import 'package:foray/features/forays/presentation/widgets/foray_settings_tab.dart';
import 'package:foray/routing/routes.dart';

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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forayAsync = ref.watch(forayDetailProvider(widget.forayId));
    final isOrganizer = ref.watch(isOrganizerProvider(widget.forayId));

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
        
        return Scaffold(
          appBar: AppBar(
            title: Text(foray.name),
            actions: [
              if (!foray.isSolo)
                IconButton(
                  icon: const Icon(Icons.qr_code),
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
              tabs: [
                const Tab(icon: Icon(Icons.list), text: 'Feed'),
                const Tab(icon: Icon(Icons.map), text: 'Map'),
                if (!foray.isSolo) 
                  const Tab(icon: Icon(Icons.people), text: 'People'),
                if (isOrganizer)
                  const Tab(icon: Icon(Icons.settings), text: 'Settings'),
              ].take(foray.isSolo ? 2 : (isOrganizer ? 4 : 3)).toList(),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              ForayFeedTab(forayId: widget.forayId),
              ForayMapTab(forayId: widget.forayId),
              if (!foray.isSolo)
                ForayParticipantsTab(forayId: widget.forayId),
              if (isOrganizer)
                ForaySettingsTab(forayId: widget.forayId),
            ].take(foray.isSolo ? 2 : (isOrganizer ? 4 : 3)).toList(),
          ),
          floatingActionButton: foray.status == ForayStatus.active
              ? FloatingActionButton.extended(
                  onPressed: () => context.push(
                    AppRoutes.createObservation.replaceFirst(':forayId', widget.forayId),
                  ),
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Add Observation'),
                )
              : null,
        );
      },
    );
  }

  void _showShareSheet(BuildContext context, Foray foray) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ShareForaySheet(foray: foray),
    );
  }

  void _showSpecimenLookup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SpecimenLookupSheet(forayId: widget.forayId),
    );
  }
}
```

---

## 6. Foray State Management

### 6.1 Foray Settings Tab (Organizer Only)

```dart
// lib/features/forays/presentation/widgets/foray_settings_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/database/database.dart';
import 'package:foray/features/forays/presentation/controllers/foray_detail_controller.dart';

class ForaySettingsTab extends ConsumerWidget {
  const ForaySettingsTab({super.key, required this.forayId});

  final String forayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forayAsync = ref.watch(forayDetailProvider(forayId));

    return forayAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (foray) {
        if (foray == null) return const SizedBox.shrink();

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            // Status section
            Text(
              'Foray Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      foray.status == ForayStatus.active
                          ? Icons.play_circle
                          : Icons.check_circle,
                      color: foray.status == ForayStatus.active
                          ? Colors.green
                          : Colors.grey,
                    ),
                    title: Text(
                      foray.status == ForayStatus.active ? 'Active' : 'Completed',
                    ),
                    subtitle: Text(
                      foray.status == ForayStatus.active
                          ? 'Participants can add observations'
                          : 'No new observations can be added',
                    ),
                    trailing: foray.status == ForayStatus.active
                        ? TextButton(
                            onPressed: () => _completeForay(context, ref),
                            child: const Text('Complete'),
                          )
                        : TextButton(
                            onPressed: () => _reopenForay(context, ref),
                            child: const Text('Reopen'),
                          ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Lock observations
            Text(
              'Observations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            
            Card(
              child: SwitchListTile(
                title: const Text('Lock All Observations'),
                subtitle: const Text(
                  'When locked, no one can add IDs, votes, or comments',
                ),
                value: foray.observationsLocked,
                onChanged: (value) => _setObservationsLocked(context, ref, value),
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Danger zone
            Text(
              'Danger Zone',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            
            Card(
              color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
              child: ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: const Text('Delete Foray'),
                subtitle: const Text('This cannot be undone'),
                onTap: () => _confirmDeleteForay(context, ref),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeForay(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Foray?'),
        content: const Text(
          'No new observations can be added after completing. You can reopen later if needed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = ref.read(databaseProvider);
      await db.foraysDao.updateForayStatus(forayId, ForayStatus.completed);
    }
  }

  Future<void> _reopenForay(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    await db.foraysDao.updateForayStatus(forayId, ForayStatus.active);
  }

  Future<void> _setObservationsLocked(BuildContext context, WidgetRef ref, bool locked) async {
    final db = ref.read(databaseProvider);
    await db.foraysDao.setObservationsLocked(forayId, locked);
  }

  Future<void> _confirmDeleteForay(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Foray?'),
        content: const Text(
          'All observations and data will be permanently deleted. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final db = ref.read(databaseProvider);
      await db.foraysDao.deleteForay(forayId);
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }
}
```

---

## 7. Share Foray

### 7.1 Share Sheet

```dart
// lib/features/forays/presentation/widgets/share_foray_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/database/database.dart';

class ShareForaySheet extends StatelessWidget {
  const ShareForaySheet({super.key, required this.foray});

  final Foray foray;

  String get shareUrl => 'https://foray.app/join/${foray.joinCode}';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Foray',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // QR Code
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: QrImageView(
                data: shareUrl,
                version: QrVersions.auto,
                size: 200,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Join code
            Text(
              'Join Code',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: foray.joinCode ?? ''));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Code copied to clipboard')),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      foray.joinCode ?? '',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        letterSpacing: 4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(Icons.copy, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Share buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(
                  icon: Icons.share,
                  label: 'Share Link',
                  onTap: () {
                    Share.share(
                      'Join my foray "${foray.name}" on Foray!\n\n$shareUrl\n\nOr use code: ${foray.joinCode}',
                    );
                  },
                ),
                _ShareOption(
                  icon: Icons.copy,
                  label: 'Copy Link',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: shareUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied to clipboard')),
                    );
                  },
                ),
                _ShareOption(
                  icon: Icons.picture_as_pdf,
                  label: 'Export QR',
                  onTap: () => _exportQRCodes(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportQRCodes(BuildContext context) async {
    // TODO: Generate PDF with QR codes for printing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR export coming soon')),
    );
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
```

---

## Acceptance Criteria

Phase 4 is complete when:

1. [ ] Foray list displays user's forays grouped by status
2. [ ] Solo foray creation works with one tap
3. [ ] Group foray creation with all fields works
4. [ ] Join code entry works
5. [ ] QR code scanning works
6. [ ] Foray detail shows tabs (Feed, Map, Participants, Settings)
7. [ ] Organizer can complete/reopen foray
8. [ ] Organizer can lock observations
9. [ ] Share sheet shows QR code and copy options
10. [ ] Participants can leave foray
11. [ ] Organizer can remove participants
