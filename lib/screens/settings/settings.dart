import 'package:flutter/material.dart';
import 'package:pompt_app/widgets/placehold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      label: 'Settings',
      icon: Icons.settings_rounded,
    );
  }
}
