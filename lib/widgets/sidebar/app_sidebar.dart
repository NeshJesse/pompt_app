import 'dart:math';

import 'package:flutter/material.dart';
import '../../core/routes/app_tab.dart';
import 'package:pompt_app/core/theme/sidebar_const.dart';
import 'side_header.dart';
import 'nav_item.dart';
import 'collapse_btn.dart';
import 'create_btn.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.expanded,
    required this.activeTab,
    required this.onTabSelected,
    required this.onToggle,
  });

  final bool expanded;
  final AppTab activeTab;
  final ValueChanged<AppTab> onTabSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: kAnimDuration,
      curve: kAnimCurve,
      width: expanded ? kExpandedWidth : kCollapsedWidth,
      color: colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SidebarHeader(expanded: expanded),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_box_rounded),
                const SizedBox(height: 8),
                Text("Create Project"),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              children:
                  AppTab.values.map((tab) {
                    if (tab == AppTab.settings) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Divider(
                              color: colorScheme.outlineVariant.withOpacity(
                                0.5,
                              ),
                              thickness: 1,
                            ),
                          ),
                          NavItem(
                            tab: tab,
                            isActive: activeTab == tab,
                            expanded: expanded,
                            onTap: () => onTabSelected(tab),
                          ),
                        ],
                      );
                    }
                    return NavItem(
                      tab: tab,
                      isActive: activeTab == tab,
                      expanded: expanded,
                      onTap: () => onTabSelected(tab),
                    );
                  }).toList(),
            ),
          ),
          CollapseButton(expanded: expanded, onToggle: onToggle),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
