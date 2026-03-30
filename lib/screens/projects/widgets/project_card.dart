import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pompt_app/db/app_database.dart';
import 'package:pompt_app/provider/provider.dart';
import 'package:pompt_app/models/models.dart';
import 'project_progress.dart';
import 'project_status_badge.dart';
import 'edit_project.dart';
import 'confirm_dialog.dart';
import 'package:go_router/go_router.dart';

class ProjectCard extends ConsumerWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final projectColor = Color(project.colorValue);

    final progressAsync = ref.watch(projectProgressProvider(project.id));

    return GestureDetector(
      onTap: () => _navigateToKanban(context),
      onLongPress: () => _showOptions(context, ref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color accent strip
              Container(height: 4, color: projectColor),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Color swatch
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: projectColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.folder_rounded,
                            color: projectColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Name + description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.name,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (project.description != null &&
                                  project.description!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  project.description!,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ProjectStatusBadge(status: project.status),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Progress area
                    progressAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                      data:
                          (progress) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProjectProgressBar(
                                progress: progress,
                                color: projectColor,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 13,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${progress.completedTasks} / ${progress.totalTasks} tasks',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 13,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDuration(
                                      project.estimatedDurationMinutes,
                                    ),
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m estimated';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h estimated' : '${h}h ${m}m estimated';
  }

  void _navigateToKanban(BuildContext context) {
    // go_router: context.go('/projects/${project.id}');
    context.go('/projects/${project.id}');
    // For now, placeholder until routing is wired:
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${project.name}…'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProjectOptionsSheet(project: project, ref: ref),
    );
  }
}

// ──────────────────────────────────────────────
// OPTIONS SHEET (long-press)
// ──────────────────────────────────────────────

class _ProjectOptionsSheet extends StatelessWidget {
  final Project project;
  final WidgetRef ref;

  const _ProjectOptionsSheet({required this.project, required this.ref});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Project name header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                project.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Edit Project'),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (_) => EditProjectDialog(project: project),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.archive_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            title: Text(
              project.status == ProjectStatus.archived.name
                  ? 'Unarchive Project'
                  : 'Archive Project',
            ),
            onTap: () {
              Navigator.pop(context);
              _toggleArchive(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_rounded, color: colorScheme.error),
            title: Text(
              'Delete Project',
              style: TextStyle(color: colorScheme.error),
            ),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _toggleArchive(BuildContext context) {
    final dao = ref.read(projectDaoProvider);
    final newStatus =
        project.status == ProjectStatus.archived.name
            ? ProjectStatus.active.name
            : ProjectStatus.archived.name;
    dao.updateProject(
      project.copyWith(status: newStatus, updatedAt: DateTime.now()),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDialog(
            title: 'Delete Project?',
            message:
                'This will permanently delete "${project.name}" and all its tasks. This cannot be undone.',
            confirmLabel: 'Delete',
            isDestructive: true,
            onConfirm: () {
              ref.read(projectDaoProvider).deleteProject(project.id);
            },
          ),
    );
  }
}
