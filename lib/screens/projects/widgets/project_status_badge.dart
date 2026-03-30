import 'package:flutter/material.dart';
import 'package:pompt_app/models/models.dart';

class ProjectStatusBadge extends StatelessWidget {
  final String status;

  const ProjectStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _resolve(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  (String, Color) _resolve(BuildContext context, String status) {
    final cs = Theme.of(context).colorScheme;
    return switch (status) {
      'active' => ('Active', cs.primary),
      'completed' => ('Done', Colors.green),
      'archived' => ('Archived', cs.onSurfaceVariant),
      _ => ('Active', cs.primary),
    };
  }
}
