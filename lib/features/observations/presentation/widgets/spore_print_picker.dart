import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Common spore print colors.
const _sporePrintColors = [
  ('White', Color(0xFFF5F5F5)),
  ('Cream', Color(0xFFFFFDD0)),
  ('Yellow', Color(0xFFFFEB3B)),
  ('Pink', Color(0xFFE91E63)),
  ('Salmon', Color(0xFFFF8A80)),
  ('Ochre', Color(0xFFCC7722)),
  ('Rust', Color(0xFFB7410E)),
  ('Brown', Color(0xFF795548)),
  ('Purple-brown', Color(0xFF4A148C)),
  ('Black', Color(0xFF212121)),
  ('Olive', Color(0xFF808000)),
  ('Green', Color(0xFF4CAF50)),
];

/// A picker widget for selecting spore print color.
class SporePrintPicker extends StatelessWidget {
  const SporePrintPicker({
    super.key,
    required this.selectedColor,
    required this.onChanged,
  });

  final String? selectedColor;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Spore Print Color',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '(optional)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            // Clear selection chip
            if (selectedColor != null)
              ActionChip(
                avatar: const Icon(Icons.clear, size: 18),
                label: const Text('Clear'),
                onPressed: () => onChanged(null),
              ),
            ..._sporePrintColors.map((colorData) {
              final (name, color) = colorData;
              final isSelected = name == selectedColor;
              final isDark = color.computeLuminance() < 0.5;
              
              return ChoiceChip(
                label: Text(name),
                selected: isSelected,
                onSelected: (selected) {
                  onChanged(selected ? name : null);
                },
                avatar: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.black12,
                      width: 1,
                    ),
                  ),
                ),
                showCheckmark: false,
              );
            }),
          ],
        ),
      ],
    );
  }
}
