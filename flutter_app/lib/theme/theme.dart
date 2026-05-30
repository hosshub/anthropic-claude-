import 'package:flutter/material.dart';

/// ألوان النظام البصرية — تطابق Theme.swift في نسخة SwiftUI.
class TColors {
  // العلامة
  static const Color primary = Color(0xFF0F5132);
  static const Color gold = Color(0xFFC9A35B);
  static const Color khabith = Color(0xFF9B2C2C);

  // الأسطح
  static const Color background = Color(0xFFFAF7F2);
  static const Color surface = Color(0xFFFFFFFF);

  // النصوص
  static const Color textPrimary = Color(0xFF1C1A16);
  static const Color textSecondary = Color(0xFF6B6457);

  // إشارات المناطق (FoodZone في SwiftUI)
  static const Color zoneGreen = Color(0xFF147A4A);
  static const Color zoneYellow = Color(0xFFC9A35B);
  static const Color zoneRed = Color(0xFF9B2C2C);

  // ظل البطاقات
  static Color cardShadow = Colors.black.withOpacity(0.06);

  /// لون نقاط الالتزام تبعاً لنسبتها (مثل Theme.scoreColor في SwiftUI).
  static Color scoreColor(int score) {
    if (score >= 90) return primary;
    if (score >= 70) return const Color(0xFF4C9A6A);
    if (score >= 50) return gold;
    return khabith;
  }
}

/// ثيم Material 3 الرئيسي للتطبيق.
final ThemeData tayyibatTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: TColors.primary,
    primary: TColors.primary,
    secondary: TColors.gold,
    error: TColors.khabith,
    surface: TColors.surface,
  ),
  scaffoldBackgroundColor: TColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: TColors.background,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    foregroundColor: TColors.textPrimary,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: TColors.textPrimary,
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: TColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: TColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: TColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: TColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.6,
      color: TColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.5,
      color: TColors.textPrimary,
    ),
    bodySmall: TextStyle(
      fontSize: 13,
      color: TColors.textSecondary,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: TColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: TColors.textSecondary.withOpacity(0.25)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: TColors.textSecondary.withOpacity(0.25)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: TColors.primary, width: 1.6),
    ),
  ),
);
