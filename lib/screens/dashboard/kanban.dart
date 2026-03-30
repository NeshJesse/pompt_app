import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pompt_app/provider/provider.dart';
import 'package:pompt_app/models/models.dart';
import 'package:pompt_app/db/app_database.dart';
import 'widgets/kanban_board.dart';
import 'widgets/task_detail.dart';
import 'package:pompt_app/screens/projects/widgets/create_task.dart';
import 'package:pompt_app/screens/projects/widgets/project_progress.dart';

class KanbanScreen extends ConsumerWidget {
  final int projectId;

  const KanbanScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectByIdProvider(projectId));
    final progressAsync = ref.watch(projectProgressProvider(projectId));
    final colorScheme = Theme.of(context).colorScheme;

    return projectAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (project) {
        if (project == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Project not found.')),
          );
        }

        final projectColor = Color(project.colorValue);

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: _KanbanAppBar(project: project, projectColor: projectColor),
          body: Column(
            children: [
              // Persistent progress bar
              progressAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data:
                    (progress) => _ProgressHeader(
                      progress: progress,
                      projectColor: projectColor,
                    ),
              ),

              // Board fills remaining space
              Expanded(
                child: KanbanBoard(
                  projectId: projectId,
                  projectColor: projectColor,
                  onTaskTap: (task) => _openTaskDetail(context, task, project),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openAddTask(context, project, projectColor),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Task'),
            backgroundColor: projectColor,
            foregroundColor: _contrastColor(projectColor),
          ),
        );
      },
    );
  }

  void _openTaskDetail(BuildContext context, Task task, Project project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => TaskDetailSheet(
            task: task,
            projectColor: Color(project.colorValue),
          ),
    );
  }

  void _openAddTask(BuildContext context, Project project, Color projectColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => CreateTaskSheet(
            projectId: project.id,
            projectName: project.name,
            projectColor: projectColor,
          ),
    );
  }

  Color _contrastColor(Color bg) =>
      bg.computeLuminance() > 0.4 ? Colors.black : Colors.white;
}

// ──────────────────────────────────────────────
// APP BAR
// ──────────────────────────────────────────────

class _KanbanAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Project project;
  final Color projectColor;

  const _KanbanAppBar({required this.project, required this.projectColor});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.go('/'),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: projectColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              project.name,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// PROGRESS HEADER
// ──────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  final ProjectProgress progress;
  final Color projectColor;

  const _ProgressHeader({required this.progress, required this.projectColor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
      ),
      child: ProjectProgressBar(progress: progress, color: projectColor),
    );
  }
}
