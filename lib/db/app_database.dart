// ======================================================
// P.O.M.T. — DATABASE LAYER (Drift)
// Includes:
// - Tables wiring
// - AppDatabase
// - DAOs (Project + Task)
// ======================================================

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../tables/tables.dart';
import '../models/models.dart';
part 'app_database.g.dart';

// ======================================================
// DATABASE
// ======================================================

@DriftDatabase(tables: [Projects, Tasks], daos: [ProjectDao, TaskDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'pomt.sqlite'));
    return NativeDatabase(file);
  });
}

// ======================================================
// PROJECT DAO
// ======================================================

@DriftAccessor(tables: [Projects, Tasks])
class ProjectDao extends DatabaseAccessor<AppDatabase> with _$ProjectDaoMixin {
  ProjectDao(AppDatabase db) : super(db);

  // WATCH ALL PROJECTS

  Stream<List<Project>> watchAllProjects() {
    final query = select(projects)
      ..orderBy([(p) => OrderingTerm.desc(p.updatedAt)]);

    return query.watch();
  }

  // INSERT PROJECT
  Future<int> insertProject(ProjectsCompanion entry) {
    return into(projects).insert(entry);
  }

  // UPDATE PROJECT
  Future<bool> updateProject(Project project) {
    return update(projects).replace(project);
  }

  // DELETE PROJECT
  Future<int> deleteProject(int id) {
    return (delete(projects)..where((p) => p.id.equals(id))).go();
  }

  // WATCH PROJECT PROGRESS (IMPORTANT)
  Stream<ProjectProgress> watchProjectProgress(int projectId) {
    final query = customSelect(
      '''
      SELECT 
        COUNT(t.id) as totalTasks,
        SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) as completedTasks,
        SUM(t.planned_duration_minutes) as totalPlanned,
        SUM(COALESCE(t.actual_duration_minutes, 0)) as totalActual,
        p.estimated_duration_minutes as estimated
      FROM projects p
      LEFT JOIN tasks t ON t.project_id = p.id
      WHERE p.id = ?
      GROUP BY p.id
      ''',
      variables: [Variable.withInt(projectId)],
      readsFrom: {projects, tasks},
    );

    return query.watch().map((rows) {
      if (rows.isEmpty) {
        return ProjectProgress.empty();
      }

      final row = rows.first;

      return ProjectProgress(
        totalTasks: row.read<int>('totalTasks') ?? 0,
        completedTasks: row.read<int>('completedTasks') ?? 0,
        totalPlannedMinutes: row.read<int>('totalPlanned') ?? 0,
        totalActualMinutes: row.read<int>('totalActual') ?? 0,
        estimatedMinutes: row.read<int>('estimated') ?? 0,
      );
    });
  }
}

// ======================================================
// TASK DAO
// ======================================================

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(AppDatabase db) : super(db);

  // WATCH TASKS BY PROJECT
  Stream<List<Task>> watchTasksByProject(int projectId) {
    return (select(tasks)..where((t) => t.projectId.equals(projectId))).watch();
  }

  // INSERT TASK
  Future<int> insertTask(TasksCompanion entry) {
    return into(tasks).insert(entry);
  }

  // UPDATE TASK
  Future<bool> updateTask(Task task) {
    return update(tasks).replace(task);
  }

  // DELETE TASK
  Future<int> deleteTask(int id) {
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }
}

// ======================================================
// NOTES
// ======================================================

/*

1. customSelect used for performance (single query aggregation)

2. LEFT JOIN ensures projects with 0 tasks still return data

3. COALESCE handles null actualDuration

4. This feeds directly into UI progress bars + insights

5. Later: map ProjectProgressData -> ProjectProgress (domain model)

*/
