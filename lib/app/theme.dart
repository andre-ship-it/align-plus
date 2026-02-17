import 'package:flutter/material.dart';

class AppPalette {
  static const Color deepTeal = Color(0xFF008080);
  static const Color warmSand = Color(0xFFF9F7F2);
  static const Color terracotta = Color(0xFFD47C5E);
  static const Color cloudWhite = Color(0xFFFDFCF9);
  static const Color ink = Color(0xFF1A2B2B);
}

ThemeData buildPremiumTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPalette.deepTeal,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppPalette.deepTeal,
      secondary: AppPalette.terracotta,
      surface: AppPalette.warmSand,
      onSurface: AppPalette.ink,
    ),
    scaffoldBackgroundColor: AppPalette.warmSand,
  );

  final textTheme = base.textTheme.copyWith(
    headlineLarge: base.textTheme.headlineLarge?.copyWith(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.w700,
      color: AppPalette.ink,
      letterSpacing: 0.2,
    ),
    headlineMedium: base.textTheme.headlineMedium?.copyWith(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.w700,
      color: AppPalette.ink,
      letterSpacing: 0.2,
    ),
    titleLarge: base.textTheme.titleLarge?.copyWith(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.w600,
      color: AppPalette.ink,
    ),
    bodyLarge: base.textTheme.bodyLarge?.copyWith(
      fontFamily: 'Inter',
      color: AppPalette.ink,
      height: 1.35,
    ),
    bodyMedium: base.textTheme.bodyMedium?.copyWith(
      fontFamily: 'Inter',
      color: AppPalette.ink,
      height: 1.35,
    ),
    labelLarge: base.textTheme.labelLarge?.copyWith(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      letterSpacing: 0.25,
    ),
  );

  return base.copyWith(
    textTheme: textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.deepTeal,
        foregroundColor: AppPalette.cloudWhite,
        shadowColor: AppPalette.deepTeal.withOpacity(0.25),
        elevation: 2,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: textTheme.labelLarge,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppPalette.cloudWhite.withOpacity(0.74),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 14),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppPalette.cloudWhite.withOpacity(0.95),
      selectedItemColor: AppPalette.deepTeal,
      unselectedItemColor: AppPalette.ink.withOpacity(0.55),
      selectedLabelStyle: textTheme.labelSmall,
      unselectedLabelStyle: textTheme.labelSmall,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppPalette.deepTeal,
      linearTrackColor: Color(0xFFECE7DE),
    ),
  );
}
