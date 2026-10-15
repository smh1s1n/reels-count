import 'package:flutter/material.dart';
import 'neumorphic.dart';

class AppTheme {
  static const Color darkBg = NeuTheme.baseColor;
  static const Color darkSurface = NeuTheme.baseColor;
  static const Color darkCard = NeuTheme.baseColor;
  static const Color darkBorder = Color(0xFF262C38);

  static const Color primaryTeal = NeuTheme.accentTeal;
  static const Color primaryPurple = NeuTheme.accentPurple;
  static const Color accentGreen = NeuTheme.accentGreen;
  static const Color accentAmber = NeuTheme.accentAmber;
  static const Color accentRed = NeuTheme.accentRed;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primaryTeal,
        secondary: primaryPurple,
        surface: darkSurface,
        error: accentRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryTeal,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 14, color: Colors.white70),
        bodyMedium: TextStyle(fontSize: 13, color: Colors.white60),
      ),
    );
  }
}
