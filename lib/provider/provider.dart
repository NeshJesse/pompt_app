// ======================================================
// P.O.M.T. — RIVERPOD PROVIDERS (Codegen)
// Requires:
// flutter_riverpod + riverpod_generator + build_runner
// ======================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/models.dart';
import '../tables/tables.dart';
import '../db/app_database.dart';

part 'provider.g.dart';

// ======================================================
// DATABASE PROVIDER
// ======================================================

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  final db = AppDatabase();

  ref.onDispose(() {
    db.close();
  });

  return db;
}

// ======================================================
// DAO PROVIDERS
// ======================================================

@riverpod
ProjectDao projectDao(ProjectDaoRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProjectDao(db);
}

@riverpod
TaskDao taskDao(TaskDaoRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return TaskDao(db);
}

// ======================================================
// PROJECT STREAMS
// ======================================================

@riverpod
Stream<List<Project>> allProjects(AllProjectsRef ref) {
  final dao = ref.watch(projectDaoProvider);
  return dao.watchAllProjects();
}

@riverpod
Stream<Project?> projectById(ProjectByIdRef ref, int id) {
  final dao = ref.watch(projectDaoProvider);

  return dao.watchAllProjects().map((projects) {
    try {
      return projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  });
}

// ======================================================
// TASK STREAMS
// ======================================================

@riverpod
Stream<List<Task>> tasksByProject(TasksByProjectRef ref, int projectId) {
  final dao = ref.watch(taskDaoProvider);
  return dao.watchTasksByProject(projectId);
}

// ======================================================
// PROJECT PROGRESS
// ======================================================

@riverpod
Stream<ProjectProgress> projectProgress(ProjectProgressRef ref, int projectId) {
  final dao = ref.watch(projectDaoProvider);
  return dao.watchProjectProgress(projectId);
}

// ======================================================
// DERIVED / COMPUTED PROVIDERS
// ======================================================

@riverpod
int completedTaskCount(CompletedTaskCountRef ref, int projectId) {
  final tasksAsync = ref.watch(tasksByProjectProvider(projectId));

  return tasksAsync.maybeWhen(
    data:
        (tasks) =>
            tasks.where((t) => t.status == TaskStatus.completed.name).length,
    orElse: () => 0,
  );
}

@riverpod
double projectCompletionRate(ProjectCompletionRateRef ref, int projectId) {
  final progressAsync = ref.watch(projectProgressProvider(projectId));

  return progressAsync.maybeWhen(
    data: (p) {
      if (p == null || p.totalTasks == 0) return 0;
      return p.completedTasks / p.totalTasks;
    },
    orElse: () => 0,
  );
}

// ======================================================
// NOTES
// ======================================================

/*

1. Codegen required:
   flutter pub run build_runner build --delete-conflicting-outputs

2. KeepAlive used for DB to avoid reopening connections

3. Providers are split into:
   - Source (DAO streams)
   - Derived (computed values)

4. UI will ONLY consume providers, never DAOs directly

*/
