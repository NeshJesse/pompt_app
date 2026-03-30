import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:pompt_app/provider/provider.dart';
import 'package:pompt_app/db/app_database.dart';
import 'package:pompt_app/models/models.dart';
import 'steps.dart';
import 'duration.dart';
import 'category_chip.dart';
import 'create_project.dart';
import 'package:go_router/go_router.dart';

class CreateTaskSheet extends ConsumerStatefulWidget {
  final int projectId;
  final String projectName;
  final Color projectColor;

  const CreateTaskSheet({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.projectColor,
  });

  @override
  ConsumerState<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends ConsumerState<CreateTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  TaskCategory _category = TaskCategory.development;
  int _durationMinutes = 30;
  DateTime _date = DateTime.now();
  TimeOfDay? _startTime;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
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

                // Step indicator + back button
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: _goBack,
                      tooltip: 'Back to project',
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHigh,
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: StepIndicator(currentStep: 2, totalSteps: 2),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Project context header
                _ProjectContextHeader(
                  projectName: widget.projectName,
                  projectColor: widget.projectColor,
                ),
                const SizedBox(height: 20),

                Text(
                  'Add First Task',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Task Title
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  maxLength: 120,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    hintText: 'e.g. Set up Drift database',
                    prefixIcon: Icon(Icons.task_alt_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Task title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
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

                // Date & time row
                Row(
                  children: [
                    Expanded(
                      child: _PickerField(
                        icon: Icons.calendar_today_rounded,
                        label: _formatDate(_date),
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PickerField(
                        icon: Icons.access_time_rounded,
                        label:
                            _startTime == null
                                ? 'Start time'
                                : _startTime!.format(context),
                        onTap: _pickTime,
                        muted: _startTime == null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Duration
                DurationSliderField(
                  label: 'Planned Duration',
                  valueMinutes: _durationMinutes,
                  onChanged: (v) => setState(() => _durationMinutes = v),
                ),
                const SizedBox(height: 28),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _skip,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Skip'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _saveTask,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isSaving
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Add Task'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // ACTIONS
  // ──────────────────────────────────────────────

  void _goBack() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateProjectDialog(),
    );
  }

  void _skip() {
    Navigator.pop(context);
    // navigate to project kanban:
    // context.go('/projects/${widget.projectId}');
    context.go('/projects/${widget.projectId}');
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final dao = ref.read(taskDaoProvider);
      final now = DateTime.now();

      await dao.insertTask(
        TasksCompanion.insert(
          projectId: widget.projectId,
          title: _titleController.text.trim(),
          description: Value(
            _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
          ),
          category: Value(_category.name),
          plannedDurationMinutes: Value(_durationMinutes),
          date: _date,
          startTime: Value(
            _startTime == null
                ? null
                : '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
          ),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      if (!mounted) return;
      Navigator.pop(context);
      context.go('/projects/${widget.projectId}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
    final tomorrow = now.add(const Duration(days: 1));
    if (d.year == tomorrow.year &&
        d.month == tomorrow.month &&
        d.day == tomorrow.day) {
      return 'Tomorrow';
    }
    return '${d.day}/${d.month}/${d.year}';
  }
}

// ──────────────────────────────────────────────
// PROJECT CONTEXT HEADER
// ──────────────────────────────────────────────

class _ProjectContextHeader extends StatelessWidget {
  final String projectName;
  final Color projectColor;

  const _ProjectContextHeader({
    required this.projectName,
    required this.projectColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: projectColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: projectColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.folder_rounded, color: projectColor, size: 16),
          const SizedBox(width: 8),
          Text(
            'Adding task to: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: projectColor.withOpacity(0.8),
            ),
          ),
          Text(
            projectName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: projectColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// PICKER FIELD
// ──────────────────────────────────────────────

class _PickerField extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool muted;

  const _PickerField({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
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
