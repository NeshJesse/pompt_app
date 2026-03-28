
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


MODELS
// ======================================================
// P.O.M.T. — Data Layer (Improved Version)
// Focus:
// - Clear separation between Planned vs Actual time
// - Scalable enums
// - Ready for Drift
// ======================================================

import 'package:drift/drift.dart';

// ======================================================
// ENUMS
// ======================================================

enum ProjectStatus { active, completed, archived }

enum TaskStatus { pending, inProgress, completed }

enum TaskCategory { development, debugging, other }

// ======================================================
// EXTENSIONS (for DB storage)
// ======================================================

extension ProjectStatusX on ProjectStatus {
  String get value => name;

  static ProjectStatus fromString(String value) {
    return ProjectStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProjectStatus.active,
    );
  }
}

extension TaskStatusX on TaskStatus {
  String get value => name;

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskStatus.pending,
    );
  }
}

extension TaskCategoryX on TaskCategory {
  String get value => name;

  static TaskCategory fromString(String value) {
    return TaskCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskCategory.other,
    );
  }
}

// ======================================================
// DOMAIN MODELS (CLEAN MODELS FOR UI)
// ======================================================

class ProjectModel {
  final int id;
  final String name;
  final String? description;
  final int estimatedDurationMinutes;
  final ProjectStatus status;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    required this.estimatedDurationMinutes,
    required this.status,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
  });
}

class TaskModel {
  final int id;
  final int projectId;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskCategory category;

  final int plannedDurationMinutes;
  final int? actualDurationMinutes;

  final DateTime date;
  final String? startTime;

  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.status,
    required this.category,
    required this.plannedDurationMinutes,
    this.actualDurationMinutes,
    required this.date,
    this.startTime,
    required this.createdAt,
    required this.updatedAt,
  });

  // =========================================
  // DERIVED HELPERS (VERY IMPORTANT)
  // =========================================

  int get effectiveDuration {
    return actualDurationMinutes ?? plannedDurationMinutes;
  }

  bool get isCompleted => status == TaskStatus.completed;
}

// ======================================================
// PROJECT PROGRESS (COMPUTED MODEL)
// ======================================================

class ProjectProgress {
  final int totalTasks;
  final int completedTasks;

  final int totalPlannedMinutes;
  final int totalActualMinutes;

  final int estimatedMinutes;

  ProjectProgress({
    required this.totalTasks,
    required this.completedTasks,
    required this.totalPlannedMinutes,
    required this.totalActualMinutes,
    required this.estimatedMinutes,
  });
  factory ProjectProgress.empty() {
    return ProjectProgress(
      totalTasks: 0,
      completedTasks: 0,
      totalPlannedMinutes: 0,
      totalActualMinutes: 0,
      estimatedMinutes: 0,
    );
  }
  double get completionRate {
    if (totalTasks == 0) return 0;
    return completedTasks / totalTasks;
  }

  double get plannedVsEstimate {
    if (estimatedMinutes == 0) return 0;
    return totalPlannedMinutes / estimatedMinutes;
  }

  bool get isOverBudget => totalPlannedMinutes > estimatedMinutes;
}

TABLES

// ======================================================
// DRIFT TABLES
// ======================================================
import 'package:drift/drift.dart';
import '../models/models.dart';

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  TextColumn get description => text().nullable()();

  // TOTAL PLANNED TIME FOR PROJECT
  IntColumn get estimatedDurationMinutes =>
      integer().withDefault(const Constant(60))();

  TextColumn get status =>
      text().withDefault(Constant(ProjectStatus.active.name))();

  IntColumn get colorValue =>
      integer().withDefault(const Constant(0xFF6366F1))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.cascade)();

  TextColumn get title => text().withLength(min: 1, max: 120)();

  TextColumn get description => text().nullable()();

  TextColumn get status =>
      text().withDefault(Constant(TaskStatus.pending.name))();

  TextColumn get category =>
      text().withDefault(Constant(TaskCategory.development.name))();

  // ================================
  // TIME MODEL (IMPORTANT CHANGE)
  // ================================

  // Planned time (what user intends)
  IntColumn get plannedDurationMinutes =>
      integer().withDefault(const Constant(30))();

  // Actual time (what user really spent)
  IntColumn get actualDurationMinutes => integer().nullable()();

  DateTimeColumn get date => dateTime()();

  TextColumn get startTime => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}


PROVIDERS

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

MAIN.DART
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: PomtApp()));
}

APP.DART
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'layout/app_layout.dart';

class PomtApp extends StatelessWidget {
  const PomtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P.O.M.T.',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const AppLayout(),
    );
  }
}
