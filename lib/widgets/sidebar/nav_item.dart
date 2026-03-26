import 'package:flutter/material.dart';
import 'package:pompt_app/core/routes/app_tab.dart';
import 'package:pompt_app/core/theme/sidebar_const.dart';

class NavItem extends StatefulWidget {
  const NavItem({
    super.key,
    required this.tab,
    required this.isActive,
    required this.expanded,
    required this.onTap,
  });

  final AppTab tab;
  final bool isActive;
  final bool expanded;
  final VoidCallback onTap;

  @override
  State<NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bgColor =
        widget.isActive
            ? colorScheme.primaryContainer
            : _hovered
            ? colorScheme.surfaceContainerHigh
            : Colors.transparent;

    final iconColor =
        widget.isActive
            ? colorScheme.primary
            : colorScheme.onSurface.withOpacity(0.65);

    final labelColor =
        widget.isActive
            ? colorScheme.primary
            : colorScheme.onSurface.withOpacity(0.75);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  child: Center(
                    child: Icon(
                      widget.isActive ? widget.tab.activeIcon : widget.tab.icon,
                      size: 22,
                      color: iconColor,
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
                        widget.tab.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              widget.isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                          color: labelColor,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
