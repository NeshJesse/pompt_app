import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pompt_app/provider/provider.dart';
import 'package:pompt_app/models/models.dart';
import 'package:pompt_app/db/app_database.dart';
import 'kanban_col.dart';

// Column definitions — order matters for display
const _kColumns = [
  KanbanColumnDef(
    status: 'pending',
    label: 'Pending',
    icon: Icons.radio_button_unchecked_rounded,
    color: Color(0xFFF59E0B), // Amber
  ),
  KanbanColumnDef(
    status: 'inProgress',
    label: 'In Progress',
    icon: Icons.pending_rounded,
    color: Color(0xFF3B82F6), // Blue
  ),
  KanbanColumnDef(
    status: 'completed',
    label: 'Completed',
    icon: Icons.check_circle_rounded,
    color: Color(0xFF22C55E), // Green
  ),
];

class KanbanBoard extends ConsumerWidget {
  final int projectId;
  final Color projectColor;
  final void Function(Task task) onTaskTap;

  const KanbanBoard({
    super.key,
    required this.projectId,
    required this.projectColor,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksByProjectProvider(projectId));

    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (tasks) {
        // Bucket tasks into columns
        final bucketed = {
          for (final col in _kColumns)
            col.status: tasks.where((t) => t.status == col.status).toList(),
        };

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              _kColumns.map((col) {
                return Expanded(
                  child: KanbanColumn(
                    def: col,
                    tasks: bucketed[col.status] ?? [],
                    projectId: projectId,
                    allColumns: _kColumns,
                    onTaskTap: onTaskTap,
                    onStatusChange:
                        (task, newStatus) =>
                            _updateStatus(ref, task, newStatus),
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  Future<void> _updateStatus(WidgetRef ref, Task task, String newStatus) async {
    final dao = ref.read(taskDaoProvider);
    await dao.updateTask(
      task.copyWith(status: newStatus, updatedAt: DateTime.now()),
    );
  }
}

// ──────────────────────────────────────────────
// COLUMN DEFINITION (data only)
// ──────────────────────────────────────────────

class KanbanColumnDef {
  final String status;
  final String label;
  final IconData icon;
  final Color color;

  const KanbanColumnDef({
    required this.status,
    required this.label,
    required this.icon,
    required this.color,
  });
}
