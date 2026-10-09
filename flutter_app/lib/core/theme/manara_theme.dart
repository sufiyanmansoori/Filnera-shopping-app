import 'package:flutter/material.dart';

class ManaraBrandColors {
  static const Color primary = Color(0xFF2F6BFF);
  static const Color primaryDark = Color(0xFF1C3F8C);
  static const Color accent = Color(0xFFFF6B35);
  static const Color surfaceWarm = Color(0xFFFFF7F2);
  static const Color success = Color(0xFF0E9F6E);
  static const Color danger = Color(0xFFE11D48);
  static const Color lightText = Color(0xFFF8FAFC);
  static const Color darkText = Color(0xFF162033);
}

class ManaraTheme {
  static ThemeData lightTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ManaraBrandColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: ManaraBrandColors.primary,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: ManaraBrandColors.primary,
          width: 2,
        ),
      ),
    ),
    textTheme: Typography.blackCupertino.copyWith(
      bodyMedium: const TextStyle(color: ManaraBrandColors.darkText),
      titleMedium: const TextStyle(color: ManaraBrandColors.darkText),
      labelMedium: const TextStyle(color: ManaraBrandColors.darkText),
    ),
  );

  static ThemeData darkTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ManaraBrandColors.primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF101624),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Color(0xFF1A2232),
      foregroundColor: Color(0xFFF8FAFC),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF202940),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF151B2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF344057)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF344057)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF93C5FD), width: 2),
      ),
    ),
    textTheme: Typography.whiteCupertino.copyWith(
      bodyMedium: const TextStyle(color: Color(0xFFEAF0F8)),
      titleMedium: const TextStyle(color: Color(0xFFEAF0F8)),
      labelMedium: const TextStyle(color: Color(0xFFEAF0F8)),
    ),
  );
}

extension ManaraThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;
}
