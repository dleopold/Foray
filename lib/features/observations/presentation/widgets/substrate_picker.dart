import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Common substrate types for mushroom observations.
const _substrates = [
  'Wood (deciduous)',
  'Wood (coniferous)',
  'Wood (unknown)',
  'Soil',
  'Leaf litter',
  'Moss',
  'Dung',
  'Grass',
  'Bark',
  'Other',
];

/// A picker widget for selecting the substrate where a mushroom was found.
class SubstratePicker extends StatelessWidget {
  const SubstratePicker({
    super.key,
    required this.selectedSubstrate,
    required this.onChanged,
  });

  final String? selectedSubstrate;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Substrate',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _substrates.map((substrate) {
            final isSelected = substrate == selectedSubstrate;
            return FilterChip(
              label: Text(substrate),
              selected: isSelected,
              onSelected: (selected) {
                onChanged(selected ? substrate : null);
              },
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }
}
