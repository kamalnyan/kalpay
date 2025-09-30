import 'package:flutter/material.dart';

/// App color constants following the UPI-style design system
class AppColors {
  // Primary brand colors (calm & trust)
  static const Color primaryBlue = Color(0xFF0B66FF);
  static const Color accentGreen = Color(0xFF00C853);
  static const Color darkSlate = Color(0xFF121827);

  // Neutrals
  static const Color grey1 = Color(0xFFF6F8FA); // Background
  static const Color grey2 = Color(0xFFFFFFFF); // Surface
  static const Color textMuted = Color(0xFF6B7280);

  // Danger/overdue
  static const Color dangerRed = Color(0xFFFF3B30);

  // Highlights/chips
  static const Color softYellow = Color(0xFFFFF8E1);

  // Additional accent colors
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentPurple = Color(0xFF9C27B0);

  // Additional UI colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF0052CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [accentGreen, Color(0xFF00A843)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow colors
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);

  // Status colors
  static const Color success = accentGreen;
  static const Color error = dangerRed;
  static const Color warning = Color(0xFFFF9500);
  static const Color info = primaryBlue;

  // Text colors
  static const Color textPrimary = darkSlate;
  static const Color textSecondary = textMuted;
  static const Color textOnPrimary = white;
  static const Color textOnDark = white;

  // Background colors
  static const Color backgroundPrimary = Color(0xFFF8F9FA);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundSecondary = Color(0xFFFFFFFF);
  static const Color backgroundTertiary = Color(0xFFF1F3F4);
  static const Color backgroundCard = white;

  // Border colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFF9CA3AF);

  // Shimmer colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
