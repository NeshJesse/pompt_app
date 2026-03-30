import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:pompt_app/provider/provider.dart';
import 'package:pompt_app/db/app_database.dart';
import 'package:pompt_app/models/models.dart';

import 'package:pompt_app/screens/projects/widgets/duration.dart';
import 'package:pompt_app/screens/projects/widgets/category_chip.dart';
import 'package:pompt_app/screens/projects/widgets/confirm_dialog.dart';
import 'kanban_board.dart';

class TaskDetailSheet extends ConsumerStatefulWidget {
  final Task task;
  final Color projectColor;

  const TaskDetailSheet({
    super.key,
    required this.task,
    required this.projectColor,
  });

  @override
  ConsumerState<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends ConsumerState<TaskDetailSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  late TaskCategory _category;
  late int _plannedMinutes;
  int? _actualMinutes;
  late DateTime _date;
  TimeOfDay? _startTime;

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleController = TextEditingController(text: t.title);
    _descController = TextEditingController(text: t.description ?? '');
    _category = TaskCategoryX.fromString(t.category);
    _plannedMinutes = t.plannedDurationMinutes;
    _actualMinutes = t.actualDurationMinutes;
    _date = t.date;
    _startTime = t.startTime == null ? null : _parseTime(t.startTime!);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final task = widget.task;
    final isCompleted = task.status == TaskStatus.completed.name;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Header ──
              Row(
                children: [
                  Expanded(
                    child:
                        _isEditing
                            ? TextFormField(
                              controller: _titleController,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                              ),
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            )
                            : Text(
                              task.title,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                                decoration:
                                    isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                color:
                                    isCompleted
                                        ? colorScheme.onSurfaceVariant
                                        : null,
                              ),
                            ),
                  ),
                  const SizedBox(width: 8),
                  // Edit / Save toggle
                  IconButton(
                    icon: Icon(
                      _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                    ),
                    onPressed:
                        _isEditing
                            ? _save
                            : () => setState(() => _isEditing = true),
                    tooltip: _isEditing ? 'Save' : 'Edit',
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainerHigh,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Delete
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: colorScheme.error,
                    ),
                    onPressed: _confirmDelete,
                    tooltip: 'Delete task',
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.errorContainer.withOpacity(
                        0.2,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Status row ──
              _StatusRow(
                task: task,
                onStatusChanged: (newStatus) {
                  ref
                      .read(taskDaoProvider)
                      .updateTask(
                        task.copyWith(
                          status: newStatus,
                          updatedAt: DateTime.now(),
                        ),
                      );
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 20),
              Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
              const SizedBox(height: 16),

              // ── Details ──
              if (_isEditing) ...[
                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),

                // Category
                Text(
                  'Category',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                CategoryChipSelector(
                  selected: _category,
                  onSelected: (c) => setState(() => _category = c),
                ),
                const SizedBox(height: 16),

                // Date + time
                Row(
                  children: [
                    Expanded(
                      child: _PickerTile(
                        icon: Icons.calendar_today_rounded,
                        label: _formatDate(_date),
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PickerTile(
                        icon: Icons.access_time_rounded,
                        label: _startTime?.format(context) ?? 'No start time',
                        onTap: _pickTime,
                        muted: _startTime == null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                DurationSliderField(
                  label: 'Planned Duration',
                  valueMinutes: _plannedMinutes,
                  onChanged: (v) => setState(() => _plannedMinutes = v),
                ),
                const SizedBox(height: 16),

                // Actual duration (only relevant when task has started)
                DurationSliderField(
                  label: 'Actual Duration (optional)',
                  valueMinutes: _actualMinutes ?? _plannedMinutes,
                  onChanged: (v) => setState(() => _actualMinutes = v),
                ),
              ] else ...[
                _ReadonlyDetail(
                  icon: Icons.notes_rounded,
                  label: 'Description',
                  value:
                      task.description?.isNotEmpty == true
                          ? task.description!
                          : 'No description',
                  muted: task.description?.isEmpty != false,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ReadonlyDetail(
                        icon: Icons.calendar_today_rounded,
                        label: 'Date',
                        value: _formatDate(task.date),
                      ),
                    ),
                    if (task.startTime != null)
                      Expanded(
                        child: _ReadonlyDetail(
                          icon: Icons.access_time_rounded,
                          label: 'Start Time',
                          value: task.startTime!,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ReadonlyDetail(
                        icon: Icons.schedule_rounded,
                        label: 'Planned',
                        value: _formatDuration(task.plannedDurationMinutes),
                      ),
                    ),
                    if (task.actualDurationMinutes != null)
                      Expanded(
                        child: _ReadonlyDetail(
                          icon: Icons.timer_rounded,
                          label: 'Actual',
                          value: _formatDuration(task.actualDurationMinutes!),
                        ),
                      ),
                  ],
                ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // ACTIONS
  // ──────────────────────────────────────────────

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    try {
      final dao = ref.read(taskDaoProvider);
      await dao.updateTask(
        widget.task.copyWith(
          title: _titleController.text.trim(),
          description: Value(
            _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
          ),
          category: _category.name,
          plannedDurationMinutes: _plannedMinutes,
          actualDurationMinutes: Value(_actualMinutes),
          date: _date,
          startTime: Value(
            _startTime == null
                ? null
                : '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
          ),
          updatedAt: DateTime.now(),
        ),
      );
      if (mounted) setState(() => _isEditing = false);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDialog(
            title: 'Delete Task?',
            message: 'This will permanently delete "${widget.task.title}".',
            confirmLabel: 'Delete',
            isDestructive: true,
            onConfirm: () {
              ref.read(taskDaoProvider).deleteTask(widget.task.id);
              Navigator.pop(context);
            },
          ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today';
    }
    return '${d.day}/${d.month}/${d.year}';
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

// ──────────────────────────────────────────────
// STATUS ROW — quick status switcher chips
// ──────────────────────────────────────────────

class _StatusRow extends StatelessWidget {
  final Task task;
  final ValueChanged<String> onStatusChanged;

  const _StatusRow({required this.task, required this.onStatusChanged});

  static const _statuses = [
    ('pending', 'Pending', Color(0xFFF59E0B)),
    ('inProgress', 'In Progress', Color(0xFF3B82F6)),
    ('completed', 'Completed', Color(0xFF22C55E)),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          _statuses.map((entry) {
            final (status, label, color) = entry;
            final isSelected = task.status == status;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: isSelected ? null : () => onStatusChanged(status),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: isSelected ? color : color.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}

// ──────────────────────────────────────────────
// READONLY DETAIL ROW
// ──────────────────────────────────────────────

class _ReadonlyDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool muted;

  const _ReadonlyDetail({
    required this.icon,
    required this.label,
    required this.value,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodySmall?.copyWith(
                  color:
                      muted
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                  fontStyle: muted ? FontStyle.italic : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// PICKER TILE
// ──────────────────────────────────────────────

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool muted;

  const _PickerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: muted ? colorScheme.onSurfaceVariant : colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      muted
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
