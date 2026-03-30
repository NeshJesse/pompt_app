import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pompt_app/provider/provider.dart';
import 'package:pompt_app/models/models.dart';
import 'widgets/project_card.dart';
import 'widgets/empty_state.dart';
import 'widgets/create_project.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(allProjectsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _ProjectsSliverAppBar(),
          projectsAsync.when(
            loading:
                () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
            error:
                (e, _) => SliverFillRemaining(
                  child: Center(child: Text('Something went wrong: $e')),
                ),
            data: (projects) {
              if (projects.isEmpty) {
                return const SliverFillRemaining(child: ProjectsEmptyState());
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProjectCard(project: projects[index]),
                    ),
                    childCount: projects.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _NewProjectFAB(),
    );
  }
}

// ──────────────────────────────────────────────
// SLIVER APP BAR
// ──────────────────────────────────────────────

class _ProjectsSliverAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      snap: true,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Text(
          'My Projects',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        collapseMode: CollapseMode.pin,
        background: Container(color: colorScheme.surface),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// FAB
// ──────────────────────────────────────────────

class _NewProjectFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _openCreateProject(context),
      icon: const Icon(Icons.add_rounded),
      label: const Text('New Project'),
      elevation: 2,
    );
  }

  void _openCreateProject(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateProjectDialog(),
    );
  }
}
