import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    const Color seed = Color(0xFFE6D8C3); // warm beige
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF8FB7C9), // soft blue
      secondary: const Color(0xFFB6C9A5), // olive green
      tertiary: const Color(0xFFF1B7C2), // rosy
      surface: const Color(0xFFFFFBF6), // near-white warm
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      useMaterial3: true,
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 12,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      textTheme: Typography.blackMountainView.copyWith(
        titleLarge: const TextStyle(fontWeight: FontWeight.w700),
        bodyMedium: const TextStyle(height: 1.35),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.primary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: scheme.tertiary.withValues(alpha: 0.12),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}


