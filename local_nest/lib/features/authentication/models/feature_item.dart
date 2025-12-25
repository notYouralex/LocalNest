import 'package:flutter/material.dart';

/// Represents a feature item displayed in the intro option cards
class FeatureItem {
  final IconData icon;
  final String label;
  final Color color;

  const FeatureItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}
