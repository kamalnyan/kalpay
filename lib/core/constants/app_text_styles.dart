import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App text styles following the design system specifications
class AppTextStyles {
  // Base text styles using Inter font
  static TextStyle get _baseInter => GoogleFonts.inter();
  static TextStyle get _basePoppins => GoogleFonts.poppins();

  // H1 / App title: 20–22sp (bold)
  static TextStyle get h1 => _basePoppins.copyWith(
        fontSize: 22.0,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  // H2 / Section headings: 16–18sp (semibold)
  static TextStyle get h2 => _basePoppins.copyWith(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get h3 => _basePoppins.copyWith(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  // Body: 14sp (regular)
  static TextStyle get bodyLarge => _baseInter.copyWith(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _baseInter.copyWith(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => _baseInter.copyWith(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // Buttons: 14–16sp (600)
  static TextStyle get buttonLarge => _baseInter.copyWith(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
        height: 1.2,
      );

  static TextStyle get buttonMedium => _baseInter.copyWith(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
        height: 1.2,
      );

  // Caption / Small: 12sp (regular)
  static TextStyle get caption => _baseInter.copyWith(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.3,
      );

  // Label styles
  static TextStyle get labelLarge => _baseInter.copyWith(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get labelMedium => _baseInter.copyWith(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get labelSmall => _baseInter.copyWith(
        fontSize: 11.0,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.3,
      );

  // Special text styles
  static TextStyle get currency => _baseInter.copyWith(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get currencyLarge => _baseInter.copyWith(
        fontSize: 32.0,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.1,
      );

  static TextStyle get amount => _baseInter.copyWith(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get amountSuccess => amount.copyWith(
        color: AppColors.success,
      );

  static TextStyle get amountError => amount.copyWith(
        color: AppColors.error,
      );

  // Status text styles
  static TextStyle get statusPaid => _baseInter.copyWith(
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        color: AppColors.success,
        height: 1.2,
      );

  static TextStyle get statusPending => _baseInter.copyWith(
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        color: AppColors.warning,
        height: 1.2,
      );

  static TextStyle get statusOverdue => _baseInter.copyWith(
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        color: AppColors.error,
        height: 1.2,
      );

  // Link text
  static TextStyle get link => _baseInter.copyWith(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryBlue,
        decoration: TextDecoration.underline,
        height: 1.4,
      );

  // Error text
  static TextStyle get error => _baseInter.copyWith(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: AppColors.error,
        height: 1.3,
      );

  // Success text
  static TextStyle get success => _baseInter.copyWith(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: AppColors.success,
        height: 1.3,
      );

  // Hint text
  static TextStyle get hint => _baseInter.copyWith(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 1.4,
      );

  // App bar title
  static TextStyle get appBarTitle => _basePoppins.copyWith(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
        height: 1.2,
      );

  // Tab text
  static TextStyle get tabActive => _baseInter.copyWith(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryBlue,
        height: 1.2,
      );

  static TextStyle get tabInactive => _baseInter.copyWith(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        height: 1.2,
      );
}
