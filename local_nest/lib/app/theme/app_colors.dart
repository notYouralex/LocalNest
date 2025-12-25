import 'package:flutter/material.dart';

/// App color palette based on Greens-9 color scheme
class AppColors {
  AppColors._();

  // Green Palette (from lightest to darkest)
  static const Color green50 = Color(0xFFF7FCF5);   // rgba(247, 252, 245, 1)
  static const Color green100 = Color(0xFFE5F5E0);  // rgba(229, 245, 224, 1)
  static const Color green200 = Color(0xFFC7E9C0);  // rgba(199, 233, 192, 1)
  static const Color green300 = Color(0xFFA1D99B);  // rgba(161, 217, 155, 1)
  static const Color green400 = Color(0xFF74C476);  // rgba(116, 196, 118, 1)
  static const Color green500 = Color(0xFF41AB5D);  // rgba(65, 171, 93, 1)
  static const Color green600 = Color(0xFF238B45);  // rgba(35, 139, 69, 1)
  static const Color green700 = Color(0xFF006D2C);  // rgba(0, 109, 44, 1)
  static const Color green800 = Color(0xFF00441B);  // rgba(0, 68, 27, 1)

  // Primary Colors
  static const Color primary = Color(0xFF238B45);      // green600 - main primary
  static const Color primaryLight = Color(0xFF41AB5D); // green500
  static const Color primaryDark = Color(0xFF006D2C);  // green700
  
  // Gradient colors for header
  static const List<Color> primaryGradient = [
    Color(0xFF41AB5D),  // green500
    Color(0xFF238B45),  // green600
    Color(0xFF006D2C),  // green700
  ];

  // Background Colors
  static const Color background = Color(0xFFFAFAF9);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color greenBackground = Color(0xFFF7FCF5); // green50

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textWhite = Colors.white;
  static const Color textWhite80 = Color(0xCCFFFFFF); // 80% opacity white

  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);

  // Status Colors
  static const Color success = Color(0xFF41AB5D);  // green500
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Social Button Colors
  static const Color google = Color(0xFFDB4437);
  static const Color facebook = Color(0xFF1877F2);
}
