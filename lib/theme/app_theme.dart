import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color background = Color(0xFF050505); // Near black
  static const Color surface = Color(0xFF121212);
  static const Color surfaceGlass = Color(0x1AFFFFFF); // 10% white

  // Neon Colors - Adjusted for NLPL (Teal/Green focus)
  static const Color neonCyan = Color(0xFF26A69A); // Teal-ish
  static const Color neonGreen = Color(0xFF76FF03); // Brighter Green
  static const Color neonPurple = Color(0xFFAB47BC); // Softer Purple
  static const Color neonAmber = Color(0xFFFFD740);
  static const Color neonRed = Color(0xFFFF5252);

  static const Color textPrimary = Color(0xFFEEEEEE);
  static const Color textSecondary = Color(0xFFAAAAAA);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonPurple,
        surface: surface,
        background: background,
        error: neonRed,
      ),
      fontFamily: 'Roboto', // Default, but good for dashboard
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
      ),
    );
  }

  // Custom Formatter
  static String formatNumber(num value) {
    // Simple implementation for comma separation (1,000,000)
    // No intl package allowed.
    String s = value.toString();
    if (value is double) {
      s = value.toStringAsFixed(1);
    }

    // Split integer and decimal parts
    List<String> parts = s.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    Function mathFunc = (Match match) => '${match[1]},';

    // Iterate until no more matches
    String result = integerPart.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return '$result$decimalPart';
  }

  static String formatCompact(int value) {
    if (value >= 10000000) return '${(value / 10000000).toStringAsFixed(1)} Cr';
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)} L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)} K';
    return value.toString();
  }
}
