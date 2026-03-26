import 'package:flutter/material.dart';

class AppTheme {
  static const _primary = Color(0xFF6366F1); // Indigo
  static const _primaryDark = Color(0xFF818CF8);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        brightness: Brightness.light,
      ),
      fontFamily: 'SF Pro Display',
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryDark,
        brightness: Brightness.dark,
      ),
      fontFamily: 'SF Pro Display',
    );
  }
}
