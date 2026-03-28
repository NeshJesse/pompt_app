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
