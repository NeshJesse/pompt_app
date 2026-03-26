import 'package:flutter/material.dart';
import 'package:pompt_app/widgets/placehold.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      label: 'Insights',
      icon: Icons.pie_chart_rounded,
    );
  }
}
