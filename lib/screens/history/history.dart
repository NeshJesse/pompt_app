import 'package:flutter/material.dart';
import 'package:pompt_app/widgets/placehold.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      label: 'History',
      icon: Icons.calendar_month_rounded,
    );
  }
}
