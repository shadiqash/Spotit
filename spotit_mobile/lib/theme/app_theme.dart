import 'package:flutter/material.dart';

class AppTheme {
  // Purple accent colors
  static const Color primaryPurple = Color(0xFF8B5CF6); // Vibrant purple
  static const Color darkPurple = Color(0xFF7C3AED);
  static const Color lightPurple = Color(0xFFA78BFA);
  static const Color purpleAccent = Color(0xFFC4B5FD);
  
  // Dark theme colors
  static const Color background = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceVariant = Color(0xFF2A2A2A);
  
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: lightPurple,
        surface: surface,
        background: background,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryPurple,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
