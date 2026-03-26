import 'package:flutter/material.dart';

class PomtLogo extends StatelessWidget {
  const PomtLogo({super.key, required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }
}
