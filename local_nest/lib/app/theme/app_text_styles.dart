import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App text styles based on the Figma design using Inter font
class AppTextStyles {
  AppTextStyles._();

  /// Base Inter text style
  static TextStyle get _inter => GoogleFonts.inter();

  // Headings
  static TextStyle get heading1 => _inter.copyWith(
    fontSize: 30,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite,
    height: 1.2,
  );

  static TextStyle get heading2 => _inter.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Body Text
  static TextStyle get bodyLarge => _inter.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => _inter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.43,
  );

  static TextStyle get bodySmall => _inter.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.33,
  );

  // Subtitle
  static TextStyle get subtitle => _inter.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite80,
    height: 1.5,
  );

  // Label
  static TextStyle get label => _inter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.0,
  );

  // Input
  static TextStyle get inputText => _inter.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get inputHint => _inter.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Button
  static TextStyle get buttonText => _inter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
    height: 1.43,
  );

  static TextStyle get buttonTextDark => _inter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.43,
  );

  // Link
  static TextStyle get link => _inter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
    height: 1.43,
  );

  static TextStyle get linkLarge => _inter.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    height: 1.5,
  );
}
