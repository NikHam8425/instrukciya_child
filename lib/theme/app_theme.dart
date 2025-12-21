import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E81F4),
          brightness: Brightness.light,
          // background is deprecated in ColorScheme.fromSeed, it is calculated automatically or use specific overrides if needed
          // but 'background' argument is actually deprecated in ColorScheme.fromSeed in older flutter versions?
          // Actually background is deprecated property of ColorScheme, but fromSeed params might differ.
          // Let's check if 'background' param is valid. In recent Flutter it's deprecated.
          // surface: const Color(0xFFF7F8FC),
          // background: const Color(0xFFF3F5FA),
          surface: const Color(0xFFF7F8FC),
        ).copyWith(
          secondary: const Color(0xFF8FB8FF),
          tertiary: const Color(0xFF84E8C2),
        );
    return _buildTheme(scheme);
  }

  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E81F4),
          brightness: Brightness.dark,
          surface: const Color(0xFF151828),
        ).copyWith(
          secondary: const Color(0xFF7BA7FF),
          tertiary: const Color(0xFF5AD7A2),
        );
    return _buildTheme(scheme);
  }

  static ThemeData _buildTheme(ColorScheme scheme) {
    final textTheme =
        (scheme.brightness == Brightness.dark
                ? Typography.whiteMountainView
                : Typography.blackMountainView)
            .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface)
            .copyWith(
              titleLarge: const TextStyle(fontWeight: FontWeight.w600),
              bodyMedium: const TextStyle(height: 1.4),
            );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface.withValues(alpha: 0.9),
        indicatorColor: scheme.primary.withValues(alpha: 0.15),
        height: 70,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: scheme.onSurfaceVariant),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: scheme.secondaryContainer.withValues(alpha: 0.4),
        labelStyle: TextStyle(color: scheme.onSecondaryContainer),
      ),
      dividerColor: scheme.outlineVariant,
    );
  }
}
