# P.O.M.T. — Piece Of My Time
## Product Requirements Document (Flutter Edition)

> **Version:** 1.1 — MVP (Projects Update)
> **Platform:** Flutter (iOS, Android, Desktop)
> **Storage:** Drift (SQLite)
> **Philosophy:** Local-first. Offline-only. Ship the damn thing.

---

## 1. Project Overview

**P.O.M.T.** is a local-first productivity app for solo developers who struggle to finish projects. It fuses **Scrum-style time-boxing** with **Kanban visualization** and motivational progress tracking — all without a backend, login, or internet connection.

Tasks are now organized under **Projects** — giving each piece of work a home, an estimated scope, and a clear finish line. The creation flow is intentionally sequential: you define the project first, then immediately add tasks to it, keeping planning tight and purposeful.

The Flutter version targets **mobile-first** (Android/iOS) with optional desktop support, using **Drift** (type-safe SQLite ORM for Flutter/Dart) for all persistence.

### Goals
- Help solo devs move projects from idea → done, not idea → abandoned
- Organize tasks meaningfully under projects so nothing floats in a void
- Make time feel tangible via visual allocation (pie chart)
- Provide a streak-like "achievement" calendar to combat burnout
- Stay offline, stay fast, stay simple

### Non-Goals (MVP)
- No cloud sync
- No collaboration / multi-user
- No push notifications (v2)
- No recurring tasks (v2)
- No sub-tasks (v2)

---

## 2. Tech Stack

| Layer | Choice | Reason |
| :--- | :--- | :--- |
| Framework | Flutter 3.x | Cross-platform, single codebase |
| Language | Dart | Required by Flutter |
| Local DB | Drift (SQLite) | Type-safe, reactive, great Flutter support |
| State Management | Riverpod | Scalable, pairs cleanly with Drift streams |
| Charts | `fl_chart` | Lightweight pie & bar chart support |
| Calendar | `table_calendar` | Customizable monthly calendar widget |
| Drag & Drop | Built-in `ReorderableListView` | Kanban drag between columns |
| Theming | Flutter ThemeData | Light/Dark mode support |
| Routing | `go_router` | Declarative, deep-link friendly |
| Data Export | `path_provider` + `dart:convert` | JSON export/import |

---

## 3. Drift Database Schema

### 3.1 Tables

```dart
// projects table
class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  IntColumn get estimatedDurationMinutes => integer().withDefault(const Constant(60))();
  // Total estimated time budget for the whole project
  TextColumn get status => text().withDefault(const Constant('active'))();
  // 'active' | 'completed' | 'archived'
  IntColumn get colorValue => integer().withDefault(const Constant(0xFF6366F1))();
  // Stored as ARGB int — each project gets a distinct color
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// tasks table
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().references(Projects, #id)();
  // FK → projects.id (cascade delete)
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get description => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  // 'pending' | 'in_progress' | 'completed'
  TextColumn get category => text().withDefault(const Constant('development'))();
  // 'development' | 'research' | 'debugging' | 'rest' | 'other'
  DateTimeColumn get date => dateTime()();
  TextColumn get startTime => text().nullable()();  // e.g. "09:00"
  IntColumn get durationMinutes => integer().withDefault(const Constant(30))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// settings table
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
```

### 3.2 Relationships

```
Projects (1) ──────< Tasks (many)
  - Deleting a project cascades to delete all its tasks
  - A task cannot exist without a parent project
```

### 3.3 DAOs

| DAO | Key Methods |
| :--- | :--- |
| `ProjectDao` | `watchAllProjects()`, `watchProjectById(id)`, `insertProject()`, `updateProject()`, `deleteProject()`, `watchProjectProgress(id)` — returns completed/total task count |
| `TaskDao` | `watchTasksByProject(projectId)`, `watchTasksByDate(date)`, `watchTasksByStatus(status)`, `insertTask()`, `updateTask()`, `deleteTask()` |
| `SettingsDao` | `getValue(key)`, `setValue(key, value)` |

---

## 4. App Architecture

```
lib/
├── main.dart
├── app.dart                        # MaterialApp, routing, theme
├── core/
│   ├── database/
│   │   ├── app_database.dart       # Drift DB definition (all tables)
│   │   ├── project_dao.dart
│   │   ├── task_dao.dart
│   │   └── settings_dao.dart
│   ├── models/
│   │   ├── project_model.dart
│   │   ├── task_model.dart
│   │   └── category.dart           # Enum for task categories
│   └── providers/
│       ├── project_provider.dart
│       ├── task_provider.dart
│       └── settings_provider.dart
├── features/
│   ├── projects/                   # Project list + project detail
│   ├── dashboard/                  # Kanban board (scoped to a project)
│   ├── insights/                   # Pie chart + daily summary
│   ├── history/                    # Achievement calendar
│   └── settings/                   # Export/import, theme
└── shared/
    ├── widgets/                    # Reusable widgets
    └── theme/                      # Colors, typography
```

---

## 5. Pages & Screens

### 5.1 Projects Screen (Home Tab)

**Purpose:** Top-level view of all projects. The home tab.

**Layout:**
- App bar: "My Projects" title + **"+ New Project"** FAB
- Body: Scrollable list of `ProjectCard` widgets
- Each card shows: project name, description snippet, color swatch, progress bar (tasks completed / total), estimated duration

**Behaviours:**
- Tapping a `ProjectCard` navigates to the **Project Detail / Kanban** screen for that project
- Long-pressing a card reveals edit/delete options
- Empty state shows an illustration prompting the user to create their first project
- Projects sorted by `updatedAt` descending (most recently active first)
- Pressing **"+ New Project"** launches the **Create Project → Create Task** multi-step flow (see Section 5.5)

---

### 5.2 Project Detail — Kanban Board

**Purpose:** The daily workspace for a single project. Tasks are organized in Kanban columns here.

**Layout:**
- App bar: Project name + project color accent + "Add Task" action button
- Body: Horizontal scrollable Kanban with 3 columns
- Bottom: Persistent project progress bar (X of Y tasks complete)

**Kanban Columns:**

| Column | Status Value | Color Accent |
| :--- | :--- | :--- |
| Pending | `pending` | Amber / Yellow |
| In Progress | `in_progress` | Blue |
| Completed | `completed` | Green |

**Behaviours:**
- Only tasks belonging to this project are shown
- Tasks can be dragged between columns OR tapped to open the Task Detail sheet
- Completed tasks show a strikethrough title
- Empty columns show a contextual empty state
- "Add Task" opens the standalone Task Creation sheet (project is pre-filled and locked)

---

### 5.3 Insights — Daily Pie Chart

**Purpose:** Visual breakdown of how today's time is allocated across all tasks and projects.

**Layout:**
- Top: Date selector (defaults to today) + optional project filter chip row
- Center: Animated pie chart (`fl_chart` `PieChart`)
- Bottom: Category legend + total hours allocated vs. remaining

**Pie Segments by Category:**

| Category | Color |
| :--- | :--- |
| Development | Deep Blue |
| Research | Purple |
| Debugging | Orange |
| Rest | Teal |
| Other | Grey |
| Unallocated | Light Grey (dashed) |

**Behaviours:**
- Chart is reactive — updates in real time as tasks are added/edited
- Tapping a pie segment highlights related tasks in a list below, grouped by project
- "Unallocated" slice represents `24h - sum(durationMinutes of today's tasks)`
- Project filter chips allow scoping the chart to one project's tasks for that day

---

### 5.4 History — Achievement Calendar

**Purpose:** Motivational month view showing completed work over time.

**Layout:**
- Top: Month/year header with prev/next navigation
- Center: `table_calendar` widget with custom day builders
- Bottom: Task list for the selected date, grouped by project (read-only)

**Day Cell Colour Logic:**

| Condition | Visual |
| :--- | :--- |
| No tasks | Default (plain) |
| Tasks exist, none completed | Amber dot indicator |
| Some completed | Blue fill |
| All tasks completed | Green fill + checkmark |

**Behaviours:**
- Tapping a date populates the bottom list showing tasks grouped under their project name
- Tasks in this view are read-only (tap to view detail, not edit)

---

### 5.5 Create Project → Create Task Flow (Multi-Step)

**Purpose:** A guided, two-step creation flow that prevents orphaned tasks and enforces the habit of planning before doing.

**Trigger:** Pressing "**+ New Project**" FAB on the Projects Screen.

---

#### Step 1 — Create Project Dialog

Presented as a **modal dialog** (not a full screen) to feel lightweight and quick.

**Fields:**

| Field | Widget | Validation |
| :--- | :--- | :--- |
| Project Name | `TextFormField` | Required, max 100 chars |
| Description | `TextFormField` (multiline) | Optional |
| Estimated Duration | `DurationSliderField` | 30min – 200h range, shown as "~4 hours" |
| Project Color | `ColorPickerRow` | Required, default auto-assigned from palette |

**Dialog Actions:**
- **Cancel** — dismisses the dialog, nothing is saved
- **Next →** — validates fields, saves the project to Drift, transitions to Step 2

The Step 1 → Step 2 transition uses a shared `PageController` or `AnimatedSwitcher` within the same dialog/sheet so the user feels they are progressing, not jumping to a new screen.

---

#### Step 2 — Create Task Sheet

After the project is saved, the dialog expands or transitions into the **Task Creation form**. The project name appears at the top as a non-editable context header (e.g. *"Adding task to: My App"*).

**Fields:**

| Field | Widget | Notes |
| :--- | :--- | :--- |
| Project | `ProjectContextHeader` (read-only) | Pre-filled, locked to the newly created project |
| Task Title | `TextFormField` | Required, max 120 chars |
| Description | `TextFormField` (multiline) | Optional |
| Category | `SegmentedButton` or `DropdownButtonFormField` | 5 options |
| Date | `showDatePicker` | Defaults to today |
| Start Time | `showTimePicker` | Optional |
| Duration | `DurationSliderField` | 15min–8h, 15min steps |

**Sheet Actions:**
- **← Back** — returns to the Project form (project is already saved; going back lets the user edit it)
- **Add Task** — saves the task, closes the flow, lands on the new project's Kanban view
- **Skip** — skips task creation, closes the flow, lands on the new project's empty Kanban view

---

### 5.6 Settings

**Purpose:** Preferences and data management.

**Sections:**

1. **Appearance**
   - Theme toggle: Light / Dark / System

2. **Data**
   - Export all data as JSON (projects + tasks)
   - Import from JSON (with confirmation dialog)
   - Clear all data (with double-confirmation)

3. **About**
   - App version
   - "Built with P.O.M.T. for P.O.M.T." tagline

---

## 6. Widgets Breakdown

### 6.1 Shared / Reusable Widgets

| Widget | Description |
| :--- | :--- |
| `AppScaffold` | Base scaffold with bottom nav bar |
| `ProjectCard` | Summary card — name, color swatch, description, progress bar, duration |
| `TaskCard` | Kanban card — title, duration badge, category chip, start time |
| `CategoryChip` | Colored chip for task category |
| `StatusBadge` | Pill badge for pending / in_progress / completed |
| `ProjectColorSwatch` | Small colored circle indicating parent project |
| `DurationSliderField` | Reusable slider + formatted label ("4 hrs 30 min") |
| `EmptyStateWidget` | Illustrated empty state with contextual message |
| `ConfirmDialog` | Reusable confirmation / destructive action dialog |
| `LoadingOverlay` | Full-screen loading indicator |

### 6.2 Projects Screen Widgets

| Widget | Description |
| :--- | :--- |
| `ProjectList` | Scrollable list of `ProjectCard` widgets |
| `ProjectProgressBar` | Linear indicator — completed tasks / total tasks |
| `ProjectStatusBadge` | `active` / `completed` / `archived` pill |

### 6.3 Create Project → Task Flow Widgets

| Widget | Description |
| :--- | :--- |
| `CreateProjectDialog` | Step 1 modal — name, description, duration, color |
| `ColorPickerRow` | Horizontal scrollable row of preset color swatches |
| `CreateTaskSheet` | Step 2 — task form with locked project context header |
| `ProjectContextHeader` | Non-editable banner: "Adding task to: [Project Name]" |
| `StepIndicator` | Visual 1 → 2 step progress indicator within the flow |

### 6.4 Project Kanban Widgets

| Widget | Description |
| :--- | :--- |
| `KanbanBoard` | Horizontal scroll container holding 3 `KanbanColumn` widgets |
| `KanbanColumn` | Vertical scrollable list of `TaskCard` within a styled column header |
| `TaskDetailSheet` | Bottom sheet for viewing/editing an existing task |
| `AddTaskFAB` | FAB that opens standalone task creation (project pre-filled and locked) |

### 6.5 Insights Widgets

| Widget | Description |
| :--- | :--- |
| `TimePieChart` | `fl_chart` PieChart with animated transitions |
| `CategoryLegend` | Row of colored dots with labels and hour counts |
| `DailySummaryCard` | Card showing total allocated hours vs. 24h |
| `ProjectFilterChips` | Horizontal chip row to scope insights to one project |
| `InsightTaskList` | Tasks filtered by tapped pie segment, grouped by project |

### 6.6 History Widgets

| Widget | Description |
| :--- | :--- |
| `AchievementCalendar` | `table_calendar` with custom `calendarBuilders` for day cells |
| `DayTaskList` | Tasks for selected date grouped by project name (read-only) |
| `CalendarLegend` | Explains the colour coding of day cells |

---

## 7. Navigation

Bottom `NavigationBar` with 4 tabs:

| Index | Label | Icon | Route |
| :--- | :--- | :--- | :--- |
| 0 | Projects | `folder_open` | `/projects` |
| 1 | Insights | `pie_chart` | `/insights` |
| 2 | History | `calendar_month` | `/history` |
| 3 | Settings | `settings` | `/settings` |

Additional routes (not in bottom nav):

| Route | Screen |
| :--- | :--- |
| `/projects/:id` | Project Detail — Kanban Board |

Use `go_router` for declarative routing and deep linking to a specific project.

---

## 8. State Management

Using **Riverpod**:

| Provider | Type | Purpose |
| :--- | :--- | :--- |
| `allProjectsProvider` | `StreamProvider` | Reactive list of all projects |
| `projectByIdProvider` | `StreamProvider(id)` | Single project with live progress |
| `tasksByProjectProvider` | `StreamProvider(projectId)` | All tasks for a given project |
| `tasksByDateProvider` | `StreamProvider` | Tasks for selected date (all projects) |
| `dailyInsightsProvider` | `Provider` | Computed pie chart data from today's tasks |
| `selectedDateProvider` | `StateProvider` | Currently selected date in calendar/insights |
| `selectedProjectFilterProvider` | `StateProvider<int?>` | Null = all projects; int = scoped project id |
| `themeProvider` | `StateProvider` | Light / Dark / System preference |
| `settingsProvider` | `FutureProvider` | All settings from Drift SettingsDao |
| `createProjectFlowProvider` | `StateNotifierProvider` | Transient state across the 2-step creation flow |

---

## 9. Technical Constraints & Performance

| Requirement | Target |
| :--- | :--- |
| Offline support | 100% — no network calls ever |
| Kanban status update | < 100ms UI response |
| App cold start | < 2 seconds |
| Database reads | Reactive streams via Drift (no manual polling) |
| Cascade deletes | Enforced at DB level — deleting a project removes all its tasks |
| Minimum Flutter version | 3.10+ |
| Minimum Android SDK | API 21 (Android 5.0) |
| Minimum iOS version | iOS 13 |

---

## 10. Development Roadmap — "The Pieces"

### Piece 1 — Foundation
- [ ] Init Flutter project with Riverpod, Drift, go_router
- [ ] Define Drift schema (Projects, Tasks, Settings + DAOs)
- [ ] Configure cascade delete on `tasks.projectId`
- [ ] Build `AppScaffold` with bottom nav
- [ ] Wire up basic routing including `/projects/:id`

### Piece 2 — Projects Screen
- [ ] `ProjectCard`, `ProjectList`, `ProjectProgressBar` widgets
- [ ] `allProjectsProvider` Drift stream
- [ ] Empty state for no projects
- [ ] Long-press edit/delete with `ConfirmDialog`

### Piece 3 — Create Project → Task Flow
- [ ] `CreateProjectDialog` (Step 1) with `ColorPickerRow`, `DurationSliderField`
- [ ] Save project to Drift on "Next →"
- [ ] `CreateTaskSheet` (Step 2) with `ProjectContextHeader` and `StepIndicator`
- [ ] Navigate to new project's Kanban on "Add Task" or "Skip"

### Piece 4 — Project Kanban Board
- [ ] `KanbanBoard`, `KanbanColumn`, `TaskCard` widgets
- [ ] `TaskDetailSheet` for editing & status change
- [ ] Drag-and-drop or tap-to-advance status
- [ ] Project progress bar in app bar area

### Piece 5 — Insights (Pie Chart)
- [ ] Integrate `fl_chart` PieChart
- [ ] `dailyInsightsProvider` computed from Drift stream
- [ ] `ProjectFilterChips` for scoping
- [ ] Category legend, daily summary card, reactive updates

### Piece 6 — History (Calendar)
- [ ] `table_calendar` with custom day builders
- [ ] Colour-coded day cells based on task completion
- [ ] `DayTaskList` grouped by project on date tap

### Piece 7 — Settings & Polish
- [ ] Theme toggle (Light / Dark / System)
- [ ] JSON export/import (includes projects + tasks)
- [ ] All empty states, loading states, error states
- [ ] App icon, splash screen

---

## 11. Success Metric

> **The MVP is complete when you use P.O.M.T. to ship P.O.M.T.**

Create a project called *"P.O.M.T. Flutter MVP"*, break it into tasks using the flow, and complete it within 30 days.