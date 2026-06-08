import 'package:flutter/material.dart';

/// Wellness AI brand palette — calm teal + warm coral, trustworthy and modern.
/// Deliberately distinct from Tayyibat's emerald/gold.
class WColors {
  // Brand
  static const Color primary = Color(0xFF0F766E); // teal-700
  static const Color primaryDark = Color(0xFF115E59); // teal-800
  static const Color primaryDeep = Color(0xFF0B4A45);
  static const Color accent = Color(0xFFF2784B); // warm coral
  static const Color accentSoft = Color(0xFFFBD9CB);

  // Surfaces
  static const Color background = Color(0xFFF6FAF9); // off-white mint
  static const Color surface = Color(0xFFFFFFFF);
  static Color cardShadow = Colors.black.withOpacity(0.06);

  // Text
  static const Color textPrimary = Color(0xFF15302D);
  static const Color textSecondary = Color(0xFF5E726F);

  // Plan-fit zones (green / amber / red) — shared scoring language
  static const Color zoneGreen = Color(0xFF16A34A);
  static const Color zoneAmber = Color(0xFFD97706);
  static const Color zoneRed = Color(0xFFDC2626);

  /// Color for an overall 0–100 plan-fit score.
  static Color scoreColor(int score) {
    if (score >= 85) return zoneGreen;
    if (score >= 60) return zoneAmber;
    return zoneRed;
  }
}

final ThemeData wellnessTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: WColors.background,
  colorScheme: ColorScheme.fromSeed(
    seedColor: WColors.primary,
    primary: WColors.primary,
    background: WColors.background,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: WColors.background,
    foregroundColor: WColors.textPrimary,
    elevation: 0,
    centerTitle: true,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w800,
      color: WColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: WColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: WColors.textPrimary,
    ),
    bodyLarge: TextStyle(fontSize: 15, color: WColors.textPrimary),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: WColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: WColors.primary.withOpacity(0.2)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: WColors.primary.withOpacity(0.2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: WColors.primary, width: 1.6),
    ),
  ),
);
