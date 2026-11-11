import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color background = Color(0xFF0A0E17);
  static const Color surface = Color(0xFF131B2A);
  static const Color surfaceCard = Color(0xFF1A2338);
  static const Color surfaceElevated = Color(0xFF222F48);

  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color primaryBlue = Color(0xFF2979FF);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentAmber = Color(0xFFFFB300);
  static const Color accentRed = Color(0xFFFF3D57);
  static const Color accentPurple = Color(0xFF7C4DFF);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF90A4AE);
  static const Color textTertiary = Color(0xFF546E7A);

  static const Color dividerColor = Color(0xFF24324D);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primaryCyan,
        secondary: primaryBlue,
        surface: surface,
        error: accentRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF25334E), width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryCyan,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
    );
  }
}

