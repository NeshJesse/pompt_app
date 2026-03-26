import 'package:flutter/material.dart';
import 'package:pompt_app/core/theme/sidebar_const.dart';

class CollapseButton extends StatefulWidget {
  const CollapseButton({
    super.key,
    required this.expanded,
    required this.onToggle,
  });
  final bool expanded;
  final VoidCallback onToggle;

  @override
  State<CollapseButton> createState() => _CollapseButtonState();
}

class _CollapseButtonState extends State<CollapseButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 40,
            decoration: BoxDecoration(
              color:
                  _hovered
                      ? colorScheme.surfaceContainerHigh
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  child: Center(
                    child: AnimatedRotation(
                      duration: kAnimDuration,
                      turns: widget.expanded ? 0 : 0.5,
                      child: Icon(
                        Icons.keyboard_double_arrow_left_rounded,
                        size: 20,
                        color: colorScheme.onSurface.withOpacity(0.45),
                      ),
                    ),
                  ),
                ),
                ClipRect(
                  child: AnimatedAlign(
                    duration: kAnimDuration,
                    curve: kAnimCurve,
                    alignment: Alignment.centerLeft,
                    widthFactor: widget.expanded ? 1.0 : 0.0,
                    child: AnimatedOpacity(
                      duration: kAnimDuration,
                      opacity: widget.expanded ? 1.0 : 0.0,
                      child: Text(
                        'Collapse',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface.withOpacity(0.45),
                        ),
                      ),
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
}
