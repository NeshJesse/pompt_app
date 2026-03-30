import 'package:flutter/material.dart';

class DurationSliderField extends StatelessWidget {
  final String label;
  final int valueMinutes;
  final ValueChanged<int> onChanged;

  /// Range: 15 min – 8 hours in 15-min steps
  static const int _minMinutes = 15;
  static const int _maxMinutes = 480;
  static const int _step = 15;

  const DurationSliderField({
    super.key,
    required this.label,
    required this.valueMinutes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final divisions = (_maxMinutes - _minMinutes) ~/ _step;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _format(valueMinutes),
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: valueMinutes.toDouble().clamp(
            _minMinutes.toDouble(),
            _maxMinutes.toDouble(),
          ),
          min: _minMinutes.toDouble(),
          max: _maxMinutes.toDouble(),
          divisions: divisions,
          onChanged: (v) => onChanged(v.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '15 min',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '8 hrs',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _format(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}
