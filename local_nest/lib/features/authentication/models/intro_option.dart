import 'package:flutter/material.dart';
import 'feature_item.dart';

/// Represents an intro option card (Renter or Landlord)
class IntroOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final List<FeatureItem> features;
  final String buttonText;
  final Color buttonColor;
  final Color borderColor;
  final bool isOutline;

  const IntroOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.features,
    required this.buttonText,
    required this.buttonColor,
    required this.borderColor,
    this.isOutline = false,
  });
}
