import 'package:flutter/material.dart';
import '../core/routes/app_tab.dart';
import 'package:pompt_app/screens/projects/projects.dart';
import 'package:pompt_app/screens/insights/insights.dart';
import 'package:pompt_app/screens/history/history.dart';
import 'package:pompt_app/screens/settings/settings.dart';
import 'package:pompt_app/widgets/sidebar/app_sidebar.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  AppTab _activeTab = AppTab.projects;
  bool _sidebarExpanded = true;

  static const List<Widget> _screens = [
    ProjectsScreen(),
    InsightsScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  void _switchTab(AppTab tab) {
    if (_activeTab != tab) {
      setState(() => _activeTab = tab);
    }
  }

  void _toggleSidebar() {
    setState(() => _sidebarExpanded = !_sidebarExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          AppSidebar(
            expanded: _sidebarExpanded,
            activeTab: _activeTab,
            onTabSelected: _switchTab,
            onToggle: _toggleSidebar,
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withOpacity(0.4),
          ),
          Expanded(
            child: IndexedStack(index: _activeTab.index, children: _screens),
          ),
        ],
      ),
    );
  }
}
