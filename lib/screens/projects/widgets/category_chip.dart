import 'package:flutter/material.dart';
import 'package:pompt_app/models/models.dart';

class CategoryChipSelector extends StatelessWidget {
  final TaskCategory selected;
  final ValueChanged<TaskCategory> onSelected;

  const CategoryChipSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const _categories = [
    (
      TaskCategory.development,
      'Development',
      Icons.code_rounded,
      Color(0xFF3B82F6),
    ),
    (
      TaskCategory.debugging,
      'Debugging',
      Icons.bug_report_rounded,
      Color(0xFFEF4444),
    ),
    (TaskCategory.other, 'Other', Icons.more_horiz_rounded, Color(0xFF8B5CF6)),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          _categories.map((entry) {
            final (category, label, icon, color) = entry;
            final isSelected = selected == category;

            return FilterChip(
              avatar: Icon(
                icon,
                size: 14,
                color: isSelected ? color : colorScheme.onSurfaceVariant,
              ),
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onSelected(category),
              selectedColor: color.withOpacity(0.15),
              checkmarkColor: color,
              side: BorderSide(
                color:
                    isSelected ? color.withOpacity(0.5) : colorScheme.outline,
              ),
              labelStyle: TextStyle(
                color: isSelected ? color : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            );
          }).toList(),
    );
  }
}
