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
