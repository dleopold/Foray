import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../database/tables/forays_table.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/avatars/foray_avatar.dart';
import '../../core/widgets/badges/foray_badge.dart';
import '../../core/widgets/buttons/foray_button.dart';
import '../../core/widgets/cards/foray_card.dart';
import '../../core/widgets/feedback/empty_state.dart';
import '../../core/widgets/feedback/foray_snackbar.dart';
import '../../core/widgets/feedback/loading_shimmer.dart';
import '../../core/widgets/indicators/gps_accuracy_indicator.dart';
import '../../core/widgets/indicators/privacy_badge.dart';
import '../../core/widgets/indicators/sync_status_indicator.dart';
import '../../core/widgets/inputs/foray_checkbox.dart';
import '../../core/widgets/inputs/foray_dropdown.dart';
import '../../core/widgets/inputs/foray_switch.dart';
import '../../core/widgets/inputs/foray_text_field.dart';
import '../../core/widgets/list/foray_list_tile.dart';

/// Development screen showcasing all UI components.
///
/// Organized by category for easy reference and testing.
/// Accessible via /dev/components route.
class ComponentShowcaseScreen extends ConsumerStatefulWidget {
  const ComponentShowcaseScreen({super.key});

  @override
  ConsumerState<ComponentShowcaseScreen> createState() =>
      _ComponentShowcaseScreenState();
}

class _ComponentShowcaseScreenState
    extends ConsumerState<ComponentShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Demo state
  bool _switchValue = false;
  bool _checkboxValue = false;
  String? _selectedDropdown;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Showcase'),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
            },
            tooltip: 'Toggle theme',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Buttons'),
            Tab(text: 'Inputs'),
            Tab(text: 'Display'),
            Tab(text: 'Feedback'),
            Tab(text: 'Indicators'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildButtonsTab(context),
          _buildInputsTab(context),
          _buildDisplayTab(context),
          _buildFeedbackTab(context),
          _buildIndicatorsTab(context),
        ],
      ),
    );
  }

  Widget _buildButtonsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _SectionHeader('Primary Buttons'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ForayButton(
              onPressed: () {},
              label: 'Primary',
            ),
            ForayButton(
              onPressed: () {},
              label: 'With Icon',
              icon: Icons.add,
            ),
            const ForayButton(
              onPressed: null,
              label: 'Disabled',
            ),
            ForayButton(
              onPressed: () {},
              label: 'Loading',
              isLoading: true,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader('Secondary Buttons'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ForayButton(
              onPressed: () {},
              label: 'Secondary',
              variant: ForayButtonVariant.secondary,
            ),
            ForayButton(
              onPressed: () {},
              label: 'With Icon',
              variant: ForayButtonVariant.secondary,
              icon: Icons.edit,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader('Text Buttons'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ForayButton(
              onPressed: () {},
              label: 'Text Button',
              variant: ForayButtonVariant.text,
            ),
            ForayButton(
              onPressed: () {},
              label: 'With Icon',
              variant: ForayButtonVariant.text,
              icon: Icons.info,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader('Button Sizes'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ForayButton(
              onPressed: () {},
              label: 'Small',
              size: ForayButtonSize.small,
            ),
            ForayButton(
              onPressed: () {},
              label: 'Medium',
              size: ForayButtonSize.medium,
            ),
            ForayButton(
              onPressed: () {},
              label: 'Large',
              size: ForayButtonSize.large,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader('Full Width'),
        const SizedBox(height: AppSpacing.sm),
        ForayButton(
          onPressed: () {},
          label: 'Full Width Button',
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildInputsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _SectionHeader('Text Fields'),
        const SizedBox(height: AppSpacing.sm),
        ForayTextField(
          controller: _textController,
          label: 'Email',
          hint: 'Enter your email',
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppSpacing.md),
        const ForayTextField(
          label: 'Password',
          hint: 'Enter your password',
          obscureText: true,
          prefixIcon: Icons.lock,
          suffixIcon: Icons.visibility,
        ),
        const SizedBox(height: AppSpacing.md),
        const ForayTextField(
          label: 'With Error',
          hint: 'This field has an error',
          error: 'This field is required',
        ),
        const SizedBox(height: AppSpacing.md),
        const ForayTextField(
          label: 'Multiline',
          hint: 'Enter your notes...',
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader('Dropdown'),
        const SizedBox(height: AppSpacing.sm),
        ForayDropdown<String>(
          label: 'Substrate',
          hint: 'Select substrate type',
          value: _selectedDropdown,
          items: const ['Wood', 'Soil', 'Leaf Litter', 'Dung', 'Other'],
          onChanged: (value) => setState(() => _selectedDropdown = value),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader('Switch'),
        const SizedBox(height: AppSpacing.sm),
        ForaySwitch(
          value: _switchValue,
          onChanged: (value) => setState(() => _switchValue = value),
          label: 'Enable notifications',
          subtitle: 'Receive updates about new identifications',
        ),
        const SizedBox(height: AppSpacing.md),
        ForaySwitch(
          value: true,
          onChanged: null,
          label: 'Disabled switch',
          enabled: false,
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader('Checkbox'),
        const SizedBox(height: AppSpacing.sm),
        ForayCheckbox(
          value: _checkboxValue,
          onChanged: (value) =>
              setState(() => _checkboxValue = value ?? false),
          label: 'I accept the terms and conditions',
          subtitle: 'Please read our privacy policy',
        ),
        const SizedBox(height: AppSpacing.md),
        const ForayCheckbox(
          value: true,
          onChanged: null,
          label: 'Disabled checkbox',
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildDisplayTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _SectionHeader('Cards'),
        const SizedBox(height: AppSpacing.sm),
        ForayCard(
          variant: ForayCardVariant.flat,
          child: const Text('Flat card'),
        ),
        const SizedBox(height: AppSpacing.md),
        ForayCard(
          variant: ForayCardVariant.raised,
          child: const Text('Raised card with shadow'),
        ),
        const SizedBox(height: AppSpacing.md),
        ForayCard(
          variant: ForayCardVariant.outlined,
          child: const Text('Outlined card'),
        ),
        const SizedBox(height: AppSpacing.md),
        ForayCard(
          variant: ForayCardVariant.raised,
          onTap: () => ForaySnackbar.showInfo(context, 'Card tapped!'),
          child: const Text('Tappable card'),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader('Structured Card'),
        const SizedBox(height: AppSpacing.sm),
        ForayCardStructured(
          variant: ForayCardVariant.outlined,
          header: const Text('Card Header',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('This is the main content area of the card.'),
          footer: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ForayButton(
                onPressed: () {},
                label: 'Action',
                variant: ForayButtonVariant.text,
                size: ForayButtonSize.small,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader('List Tiles'),
        const SizedBox(height: AppSpacing.sm),
        ForayCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ForayListTile(
                leading: const ForayAvatar(initials: 'JD'),
                title: 'John Doe',
                subtitle: 'Collector • 5 observations',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
                showDivider: true,
              ),
              ForayListTile(
                leading: const ForayAvatar(initials: 'AS'),
                title: 'Alice Smith',
                subtitle: 'Organizer',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
                showDivider: true,
              ),
              ForayListTile(
                leading: const ForayAvatar(initials: 'BJ'),
                title: 'Bob Johnson',
                subtitle: 'Participant',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader('Avatars'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            ForayAvatar(initials: 'XS', size: ForayAvatarSize.xs),
            ForayAvatar(initials: 'SM', size: ForayAvatarSize.small),
            ForayAvatar(initials: 'MD', size: ForayAvatarSize.medium),
            ForayAvatar(initials: 'LG', size: ForayAvatarSize.large),
            ForayAvatar(initials: 'XL', size: ForayAvatarSize.xlarge),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ForayAvatarStack(
          avatars: const [
            (imageUrl: null, initials: 'AB'),
            (imageUrl: null, initials: 'CD'),
            (imageUrl: null, initials: 'EF'),
            (imageUrl: null, initials: 'GH'),
            (imageUrl: null, initials: 'IJ'),
            (imageUrl: null, initials: 'KL'),
          ],
          maxVisible: 4,
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader('Badges'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            const ForayBadge(label: 'Primary', variant: ForayBadgeVariant.primary),
            const ForayBadge(label: 'Secondary', variant: ForayBadgeVariant.secondary),
            const ForayBadge(label: 'Success', variant: ForayBadgeVariant.success),
            const ForayBadge(label: 'Warning', variant: ForayBadgeVariant.warning),
            const ForayBadge(label: 'Error', variant: ForayBadgeVariant.error),
            const ForayBadge(label: 'Info', variant: ForayBadgeVariant.info),
            const ForayBadge(label: 'Neutral', variant: ForayBadgeVariant.neutral),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            const ForayBadge(
              label: 'With Icon',
              variant: ForayBadgeVariant.success,
              icon: Icons.check,
            ),
            ForayBadge(
              label: 'Dismissible',
              variant: ForayBadgeVariant.info,
              onDismiss: () {},
            ),
            const ForayBadge(
              label: 'Outlined',
              variant: ForayBadgeVariant.primary,
              outlined: true,
            ),
            ForayBadge.count(count: 5),
            ForayBadge.count(count: 150),
          ],
        ),
      ],
    );
  }

  Widget _buildFeedbackTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _SectionHeader('Snackbars'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ForayButton(
              onPressed: () =>
                  ForaySnackbar.showSuccess(context, 'Operation successful!'),
              label: 'Success',
              size: ForayButtonSize.small,
            ),
            ForayButton(
              onPressed: () =>
                  ForaySnackbar.showError(context, 'Something went wrong'),
              label: 'Error',
              size: ForayButtonSize.small,
            ),
            ForayButton(
              onPressed: () =>
                  ForaySnackbar.showWarning(context, 'Please review your input'),
              label: 'Warning',
              size: ForayButtonSize.small,
            ),
            ForayButton(
              onPressed: () =>
                  ForaySnackbar.showInfo(context, 'New updates available'),
              label: 'Info',
              size: ForayButtonSize.small,
            ),
            ForayButton(
              onPressed: () => ForaySnackbar.showWithUndo(
                context,
                'Item deleted',
                onUndo: () =>
                    ForaySnackbar.showSuccess(context, 'Deletion undone'),
              ),
              label: 'With Undo',
              size: ForayButtonSize.small,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader('Empty States'),
        const SizedBox(height: AppSpacing.sm),
        ForayCard(
          child: EmptyState.noObservations(
            onAction: () {},
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ForayCard(
          child: EmptyState.noResults(searchTerm: 'chanterelle'),
        ),
        const SizedBox(height: AppSpacing.md),
        ForayCard(
          child: EmptyState.offline(),
        ),
        const SizedBox(height: AppSpacing.md),
        ForayCard(
          child: EmptyState.noComments(),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader('Loading Shimmers'),
        const SizedBox(height: AppSpacing.sm),
        const Text('Text Line'),
        const SizedBox(height: AppSpacing.xs),
        LoadingShimmer.textLine(),
        const SizedBox(height: AppSpacing.md),
        const Text('Paragraph'),
        const SizedBox(height: AppSpacing.xs),
        LoadingShimmer.paragraph(),
        const SizedBox(height: AppSpacing.md),
        const Text('List Item'),
        const SizedBox(height: AppSpacing.xs),
        LoadingShimmer.listItem(),
        const SizedBox(height: AppSpacing.md),
        const Text('Foray Card'),
        const SizedBox(height: AppSpacing.xs),
        ForayCard(
          padding: EdgeInsets.zero,
          child: LoadingShimmer.forayCard(),
        ),
      ],
    );
  }

  Widget _buildIndicatorsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _SectionHeader('Privacy Badges'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            PrivacyBadge(level: PrivacyLevel.private),
            PrivacyBadge(level: PrivacyLevel.foray),
            PrivacyBadge(level: PrivacyLevel.publicExact),
            PrivacyBadge(level: PrivacyLevel.publicObscured),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            PrivacyBadge(level: PrivacyLevel.private, showLabel: false),
            PrivacyBadge(level: PrivacyLevel.foray, showLabel: false),
            PrivacyBadge(level: PrivacyLevel.publicExact, showLabel: false),
            PrivacyBadge(level: PrivacyLevel.publicObscured, showLabel: false),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader('Sync Status'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            SyncStatusIndicator(status: SyncStatus.local, showLabel: true),
            SyncStatusIndicator(status: SyncStatus.pending, showLabel: true),
            SyncStatusIndicator(status: SyncStatus.synced, showLabel: true),
            SyncStatusIndicator(status: SyncStatus.failed, showLabel: true),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader('GPS Accuracy'),
        const SizedBox(height: AppSpacing.sm),
        const Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            GpsAccuracyIndicator(accuracyMeters: 3),
            GpsAccuracyIndicator(accuracyMeters: 10),
            GpsAccuracyIndicator(accuracyMeters: 25),
            GpsAccuracyIndicator(accuracyMeters: 50),
            GpsAccuracyIndicator(accuracyMeters: null),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader('Typography'),
        const SizedBox(height: AppSpacing.sm),
        Text('Headline Large', style: AppTypography.headlineLarge),
        Text('Headline Medium', style: AppTypography.headlineMedium),
        Text('Headline Small', style: AppTypography.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text('Title Large', style: AppTypography.titleLarge),
        Text('Title Medium', style: AppTypography.titleMedium),
        Text('Title Small', style: AppTypography.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Text('Body Large', style: AppTypography.bodyLarge),
        Text('Body Medium', style: AppTypography.bodyMedium),
        Text('Body Small', style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.sm),
        Text('Label Large', style: AppTypography.labelLarge),
        Text('Label Medium', style: AppTypography.labelMedium),
        Text('Label Small', style: AppTypography.labelSmall),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader('Colors'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _ColorSwatch('Primary', AppColors.primary),
            _ColorSwatch('Primary Light', AppColors.primaryLight),
            _ColorSwatch('Primary Dark', AppColors.primaryDark),
            _ColorSwatch('Secondary', AppColors.secondary),
            _ColorSwatch('Accent', AppColors.accent),
            _ColorSwatch('Success', AppColors.success),
            _ColorSwatch('Warning', AppColors.warning),
            _ColorSwatch('Error', AppColors.error),
            _ColorSwatch('Info', AppColors.info),
          ],
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTypography.labelSmall.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch(this.name, this.color);

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: AppTypography.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
