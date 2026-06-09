import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(
    brightness: Brightness.light,
    bg: Colors.white,
    primary: Colors.black,
    secondary: Colors.black,
    appBarBg: Colors.white,
    appBarFg: Colors.black,
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    bg: const Color(0xFF1A1A1A),
    primary: Colors.white,
    secondary: Colors.white,
    appBarBg: const Color(0xFF121212),
    appBarFg: Colors.white,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color primary,
    required Color secondary,
    required Color appBarBg,
    required Color appBarFg,
  }) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      brightness: brightness,
      surface: bg,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: colorScheme.outline,
        ),
        border: InputBorder.none,
      ),
      cardColor: brightness == Brightness.light
          ? Colors.white
          : const Color(0xFF2C2C2C),
      cardTheme: CardThemeData(
        color: brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF2C2C2C),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
    );
  }
}
