import 'package:flutter/material.dart';
import 'package:pompt_app/db/app_database.dart';
import 'package:pompt_app/models/models.dart';
import 'kanban_board.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Color columnColor;
  final VoidCallback onTap;
  final void Function(Task task, String newStatus) onStatusChanged;
  final List<KanbanColumnDef> allColumns;
  final bool isDragging;

  const TaskCard({
    super.key,
    required this.task,
    required this.columnColor,
    required this.onTap,
    required this.onStatusChanged,
    required this.allColumns,
    this.isDragging = false,
  });

  bool get _isCompleted => task.status == TaskStatus.completed.name;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isDragging
                    ? columnColor.withOpacity(0.6)
                    : colorScheme.outlineVariant.withOpacity(0.5),
            width: isDragging ? 1.5 : 1,
          ),
          boxShadow:
              isDragging
                  ? [
                    BoxShadow(
                      color: columnColor.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title row ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration:
                            _isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: colorScheme.onSurfaceVariant,
                        color:
                            _isCompleted
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Quick-advance button
                  if (!_isCompleted)
                    _QuickAdvanceButton(
                      task: task,
                      allColumns: allColumns,
                      onStatusChanged: onStatusChanged,
                    ),
                ],
              ),

              // ── Description snippet ──
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 10),

              // ── Footer row: category chip + duration + time ──
              Row(
                children: [
                  _CategoryChip(category: task.category),
                  const Spacer(),
                  if (task.startTime != null) ...[
                    Icon(
                      Icons.access_time_rounded,
                      size: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      task.startTime!,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  _DurationBadge(
                    minutes: task.plannedDurationMinutes,
                    color: columnColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// QUICK ADVANCE BUTTON
// Tapping moves task to the next status inline
// ──────────────────────────────────────────────

class _QuickAdvanceButton extends StatelessWidget {
  final Task task;
  final List<KanbanColumnDef> allColumns;
  final void Function(Task task, String newStatus) onStatusChanged;

  const _QuickAdvanceButton({
    required this.task,
    required this.allColumns,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = allColumns.indexWhere((c) => c.status == task.status);
    final hasNext = currentIndex < allColumns.length - 1;
    if (!hasNext) return const SizedBox.shrink();

    final nextCol = allColumns[currentIndex + 1];

    return Tooltip(
      message: 'Move to ${nextCol.label}',
      child: GestureDetector(
        onTap: () => onStatusChanged(task, nextCol.status),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: nextCol.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 14,
            color: nextCol.color,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// CATEGORY CHIP
// ──────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  (String, Color, IconData) get _meta => switch (category) {
    'development' => ('Dev', const Color(0xFF3B82F6), Icons.code_rounded),
    'debugging' => ('Debug', const Color(0xFFEF4444), Icons.bug_report_rounded),
    _ => ('Other', const Color(0xFF8B5CF6), Icons.more_horiz_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _meta;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// DURATION BADGE
// ──────────────────────────────────────────────

class _DurationBadge extends StatelessWidget {
  final int minutes;
  final Color color;

  const _DurationBadge({required this.minutes, required this.color});

  String get _label {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            _label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
