import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        // Separator lines between steps
        if (index.isOdd) {
          return Expanded(
            child: Container(height: 2, color: colorScheme.outlineVariant),
          );
        }

        final step = index ~/ 2 + 1;
        final isCompleted = step < currentStep;
        final isActive = step == currentStep;

        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isActive || isCompleted
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHigh,
                border: Border.all(
                  color:
                      isActive
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: Center(
                child:
                    isCompleted
                        ? Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: colorScheme.onPrimary,
                        )
                        : Text(
                          '$step',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color:
                                isActive
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                          ),
                        ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _stepLabel(step),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color:
                    isActive
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }

  String _stepLabel(int step) {
    return switch (step) {
      1 => 'Project',
      2 => 'First Task',
      _ => 'Step $step',
    };
  }
}
