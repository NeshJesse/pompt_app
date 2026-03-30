import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pompt_app/provider/provider.dart';
import 'package:pompt_app/db/app_database.dart';
import 'package:pompt_app/models/models.dart';
import 'create_task.dart';
import 'color_picker.dart';
import 'duration.dart';
import 'steps.dart';

class CreateProjectDialog extends ConsumerStatefulWidget {
  const CreateProjectDialog({super.key});

  @override
  ConsumerState<CreateProjectDialog> createState() =>
      _CreateProjectDialogState();
}

class _CreateProjectDialogState extends ConsumerState<CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  int _estimatedMinutes = 120;
  Color _selectedColor = const Color(0xFF6366F1);
  bool _isSaving = false;

  static const _presetColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFEAB308), // Yellow
    Color(0xFF22C55E), // Green
    Color(0xFF14B8A6), // Teal
    Color(0xFF3B82F6), // Blue
    Color(0xFF06B6D4), // Cyan
  ];

  @override
  void dispose() {
    _nameController.dispose();
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

                // Step indicator
                const StepIndicator(currentStep: 1, totalSteps: 2),
                const SizedBox(height: 20),

                Text(
                  'New Project',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Define the scope before adding tasks.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Project Name
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    hintText: 'e.g. P.O.M.T. Flutter MVP',
                    prefixIcon: Icon(Icons.folder_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Project name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What is this project about? (optional)',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 48),
                      child: Icon(Icons.notes_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Duration slider
                DurationSliderField(
                  label: 'Estimated Duration',
                  valueMinutes: _estimatedMinutes,
                  onChanged: (v) => setState(() => _estimatedMinutes = v),
                ),
                const SizedBox(height: 20),

                // Color picker
                Text(
                  'Project Color',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ColorPickerRow(
                  colors: _presetColors,
                  selected: _selectedColor,
                  onSelected: (c) => setState(() => _selectedColor = c),
                ),
                const SizedBox(height: 28),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveAndContinue,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isSaving
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Next — Add a Task'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final dao = ref.read(projectDaoProvider);
      final now = DateTime.now();

      final id = await dao.insertProject(
        ProjectsCompanion.insert(
          name: _nameController.text.trim(),
          description: Value(
            _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
          ),
          estimatedDurationMinutes: Value(_estimatedMinutes),
          colorValue: Value(_selectedColor.value),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      if (!mounted) return;

      // Transition to step 2 — replace current sheet
      Navigator.pop(context);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder:
            (_) => CreateTaskSheet(
              projectId: id,
              projectName: _nameController.text.trim(),
              projectColor: _selectedColor,
            ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
