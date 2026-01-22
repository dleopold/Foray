import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../database/database.dart';
import '../../../../database/daos/forays_dao.dart';
import '../../../../database/tables/forays_table.dart';

/// A card widget displaying foray summary information.
///
/// Shows foray name, date, location, status, and the user's role.
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
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(
                      foray.isSolo ? Icons.person : Icons.group,
                      size: 20,
                      color:
                          foray.isSolo ? AppColors.secondary : AppColors.primary,
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
