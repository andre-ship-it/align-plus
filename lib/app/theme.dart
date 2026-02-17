import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      fontWeight: FontWeight.w700,
      color: AppPalette.ink,
      letterSpacing: 0.2,
    ),
    headlineMedium: base.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: AppPalette.ink,
      letterSpacing: 0.2,
    ),
    titleLarge: base.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: AppPalette.ink,
    ),
    bodyLarge: base.textTheme.bodyLarge?.copyWith(
      color: AppPalette.ink,
      height: 1.35,
    ),
    bodyMedium: base.textTheme.bodyMedium?.copyWith(
      color: AppPalette.ink,
      height: 1.35,
    ),
    labelLarge: base.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.25,
    ),
  );

  final premiumTextTheme = GoogleFonts.interTextTheme(textTheme).copyWith(
    headlineLarge: GoogleFonts.playfairDisplay(
      textStyle: textTheme.headlineLarge,
    ),
    headlineMedium: GoogleFonts.playfairDisplay(
      textStyle: textTheme.headlineMedium,
    ),
    titleLarge: GoogleFonts.playfairDisplay(textStyle: textTheme.titleLarge),
    bodyLarge: GoogleFonts.inter(textStyle: textTheme.bodyLarge),
    bodyMedium: GoogleFonts.inter(textStyle: textTheme.bodyMedium),
    labelLarge: GoogleFonts.inter(textStyle: textTheme.labelLarge),
  );

  return base.copyWith(
    textTheme: premiumTextTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.deepTeal,
        foregroundColor: AppPalette.cloudWhite,
        shadowColor: AppPalette.deepTeal.withOpacity(0.25),
        elevation: 2,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: premiumTextTheme.labelLarge,
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
      selectedLabelStyle: premiumTextTheme.labelSmall,
      unselectedLabelStyle: premiumTextTheme.labelSmall,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppPalette.deepTeal,
      linearTrackColor: Color(0xFFECE7DE),
    ),
  );
}
