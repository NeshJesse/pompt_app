import 'package:flutter/material.dart';
import 'package:pompt_app/db/app_database.dart';
import 'package:pompt_app/models/models.dart';
import 'kanban_board.dart'; // for KanbanColumnDef
import 'task_card.dart';

// Re-export so task_card.dart can use it without a circular dep
export 'kanban_board.dart' show KanbanColumnDef;

class KanbanColumn extends StatelessWidget {
  final KanbanColumnDef def;
  final List<Task> tasks;
  final int projectId;
  final List<KanbanColumnDef> allColumns;
  final void Function(Task) onTaskTap;
  final void Function(Task task, String newStatus) onStatusChange;

  const KanbanColumn({
    super.key,
    required this.def,
    required this.tasks,
    required this.projectId,
    required this.allColumns,
    required this.onTaskTap,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) => details.data.status != def.status,
      onAcceptWithDetails:
          (details) => onStatusChange(details.data, def.status),
      builder: (context, candidateData, rejectedData) {
        final isDragOver = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isDragOver
                    ? def.color.withOpacity(0.06)
                    : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isDragOver
                      ? def.color.withOpacity(0.4)
                      : colorScheme.outlineVariant.withOpacity(0.4),
              width: isDragOver ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Column header
              _ColumnHeader(def: def, count: tasks.length),

              // Task list
              Expanded(
                child:
                    tasks.isEmpty
                        ? _ColumnEmptyState(def: def)
                        : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: LongPressDraggable<Task>(
                                data: tasks[index],
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 3.2,
                                    child: TaskCard(
                                      task: tasks[index],
                                      columnColor: def.color,
                                      onTap: () {},
                                      onStatusChanged: onStatusChange,
                                      allColumns: allColumns,
                                      isDragging: true,
                                    ),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.35,
                                  child: TaskCard(
                                    task: tasks[index],
                                    columnColor: def.color,
                                    onTap: () => onTaskTap(tasks[index]),
                                    onStatusChanged: onStatusChange,
                                    allColumns: allColumns,
                                  ),
                                ),
                                child: TaskCard(
                                  task: tasks[index],
                                  columnColor: def.color,
                                  onTap: () => onTaskTap(tasks[index]),
                                  onStatusChanged: onStatusChange,
                                  allColumns: allColumns,
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────
// COLUMN HEADER
// ──────────────────────────────────────────────

class _ColumnHeader extends StatelessWidget {
  final KanbanColumnDef def;
  final int count;

  const _ColumnHeader({required this.def, required this.count});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(
        children: [
          Icon(def.icon, color: def.color, size: 16),
          const SizedBox(width: 8),
          Text(
            def.label,
            style: textTheme.labelLarge?.copyWith(
              color: def.color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
          const Spacer(),
          // Task count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: def.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '$count',
              style: textTheme.labelSmall?.copyWith(
                color: def.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// EMPTY STATE
// ──────────────────────────────────────────────

class _ColumnEmptyState extends StatelessWidget {
  final KanbanColumnDef def;

  const _ColumnEmptyState({required this.def});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final message = switch (def.status) {
      'pending' => 'No tasks queued yet',
      'inProgress' => 'Nothing in progress',
      'completed' => 'Nothing done yet —\nkeep going!',
      _ => 'No tasks',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(def.icon, size: 32, color: def.color.withOpacity(0.25)),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
