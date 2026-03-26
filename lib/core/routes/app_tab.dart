import 'package:flutter/material.dart';

enum AppTab {
  projects,
  insights,
  history,
  settings;

  String get label {
    switch (this) {
      case AppTab.projects:
        return 'Projects';
      case AppTab.insights:
        return 'Insights';
      case AppTab.history:
        return 'History';
      case AppTab.settings:
        return 'Settings';
    }
  }

  IconData get icon {
    switch (this) {
      case AppTab.projects:
        return Icons.folder_open_rounded;
      case AppTab.insights:
        return Icons.pie_chart_rounded;
      case AppTab.history:
        return Icons.calendar_month_rounded;
      case AppTab.settings:
        return Icons.settings_rounded;
    }
  }

  IconData get activeIcon {
    switch (this) {
      case AppTab.projects:
        return Icons.folder_rounded;
      case AppTab.insights:
        return Icons.pie_chart_rounded;
      case AppTab.history:
        return Icons.calendar_month_rounded;
      case AppTab.settings:
        return Icons.settings_rounded;
    }
  }
}
