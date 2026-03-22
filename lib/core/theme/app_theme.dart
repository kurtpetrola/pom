import 'package:flutter/material.dart';

class AppTheme {
  // Palette base colors
  static const Color charcoalDark = Color(0xFF0F0F0F);
  static const Color charcoalLight = Color(0xFF1E1E1E);
  static const Color textDark = Color(0xFF111111);
  static const Color textLight = Color(0xFFF0F0F0);
  static const Color errorRed = Color(0xFFE53935);

  // Theme Color Options
  static const Color green = Color(0xFF71A986);
  static const Color yellow = Color(0xFFD4A373);
  static const Color red = Color(0xFFBD5D5D);
  static const Color violet = Color(0xFF8E7AB5);
  static const Color blue = Color(0xFF7EA1C4);

  static Color getColorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'yellow':
        return yellow;
      case 'red':
        return red;
      case 'violet':
        return violet;
      case 'blue':
        return blue;
      case 'green':
      default:
        return green;
    }
  }

  static ThemeData getTheme(Color primaryColor) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryColor,
      primaryColor: primaryColor,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 120,
          fontWeight: FontWeight.w600,
          color: textDark,
          letterSpacing: -2,
          fontFamily: 'Inter',
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
          letterSpacing: 1.5,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textLight,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),
      iconTheme: const IconThemeData(
        color: textDark,
        size: 24,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Keep for backward compatibility if needed, but deprecated
  static Color get brandGreen => green;
  static ThemeData get theme => getTheme(green);
}
