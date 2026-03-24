import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palette base colors
  static const Color charcoalDark = Color(0xFF121212);
  static const Color charcoalLight = Color(0xFF1E1E1E);
  static const Color textDark = Color(0xFF111111);
  static const Color textLight = Color(0xFFF0F0F0);
  static const Color errorRed = Color(0xFFE53935);

  // Theme Color Options - Muted/Premium versions
  static const Color green = Color(0xFF8BA888);
  static const Color yellow = Color(0xFFD4B483);
  static const Color red = Color(0xFFC17C7C);
  static const Color violet = Color(0xFF9B8BB9);
  static const Color blue = Color(0xFF8FAECB);

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
    final baseTheme = ThemeData(brightness: Brightness.dark);
    
    return baseTheme.copyWith(
      scaffoldBackgroundColor: primaryColor,
      primaryColor: primaryColor,
      textTheme: GoogleFonts.lexendDecaTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.lexendDeca(
          fontSize: 100,
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: -4,
        ),
        headlineSmall: GoogleFonts.lexendDeca(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
          letterSpacing: 0.5,
        ),
        titleMedium: GoogleFonts.lexendDeca(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        bodyMedium: GoogleFonts.lexendDeca(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textLight,
        ),
        labelLarge: GoogleFonts.lexendDeca(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),
      iconTheme: const IconThemeData(
        color: textDark,
        size: 24,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textDark),
        titleTextStyle: GoogleFonts.lexendDeca(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: 1.0,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: textDark.withValues(alpha: 0.1),
        thickness: 1,
        space: 32,
      ),
    );
  }

  static Color get brandGreen => green;
  static ThemeData get theme => getTheme(green);
}
