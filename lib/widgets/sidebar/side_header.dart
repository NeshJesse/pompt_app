import 'package:flutter/material.dart';
import 'package:pompt_app/core/theme/sidebar_const.dart';
import 'logo.dart';

class SidebarHeader extends StatelessWidget {
  const SidebarHeader({super.key, required this.expanded});
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: kAnimDuration,
      curve: kAnimCurve,
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          PomtLogo(size: 36, color: colorScheme.primary),
          ClipRect(
            child: AnimatedAlign(
              duration: kAnimDuration,
              curve: kAnimCurve,
              alignment: Alignment.centerLeft,
              widthFactor: expanded ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: AnimatedOpacity(
                  duration: kAnimDuration,
                  opacity: expanded ? 1.0 : 0.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'P.O.M.T.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Piece Of My Time',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurface.withOpacity(0.45),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
