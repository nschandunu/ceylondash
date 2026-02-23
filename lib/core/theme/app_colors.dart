import 'package:flutter/material.dart';

/// Premium color palette for CeylonDash
/// Designed for accessibility and luxury aesthetics
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color background = Color(0xFFF5F7FA);

  // Secondary Color - Cyan
  static const Color cyan = Color(0xFF00BCD4);
  static const Color cyanLight = Color(0xFF4DD0E1);
  static const Color cyanDark = Color(0xFF0097A7);
  static const Color cyanAccent = Color(0xFF00E5FF);

  // Status Colors - Distinct and accessible
  static const Color pending = Color(0xFFB0BEC5); // Soft Grey
  static const Color inTransit = Color(0xFF00BCD4); // Bright Cyan
  static const Color outForDelivery = Color(0xFF26C6DA); // Light Cyan
  static const Color delivered = Color(0xFF4CAF50); // Success Green
  static const Color cancelled = Color(0xFFEF5350); // Soft Red
  static const Color failed = Color(0xFFFF7043); // Soft Orange

  // Neutral Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFE0E0E0);

  // Glassmorphism Colors
  static const Color glassWhite = Color(0xB3FFFFFF); // 70% white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white
  static const Color glassShadow = Color(0x1A000000); // 10% black

  // Card Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x14000000); // 8% black
}
