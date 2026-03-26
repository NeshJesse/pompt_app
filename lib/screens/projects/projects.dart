import 'package:flutter/material.dart';
import 'package:pompt_app/widgets/placehold.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      label: 'Projects',
      icon: Icons.folder_rounded,
    );
  }
}
