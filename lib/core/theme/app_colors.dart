import 'package:flutter/material.dart';

/// Centralized color palette for the Trezo app.
class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF2E6FF3);
  static const Color primaryLight = Color(0xFF5A8DF5);
  static const Color primaryDark = Color(0xFF1E4AB2);

  // Background
  static const Color background = Color(0xFF0A0A0C);
  static const Color surface = Color(0xFF141416);
  static const Color surfaceLight = Color(0xFF222225);

  // Status Colors
  static const Color expiring = Color(0xFFFF6B35);
  static const Color expired = Colors.redAccent;
  static const Color active = Color(0xFF8AFF80);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textTertiary = Colors.white30;

  // Outline
  static const Color border = Color(0x1AFFFFFF); // Colors.white.withValues(alpha: 0.1)
}
