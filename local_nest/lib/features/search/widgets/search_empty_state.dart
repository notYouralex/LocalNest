import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../../../core/widgets/widgets.dart';

/// Widget that displays when search results are empty
class SearchEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final bool isError;

  const SearchEmptyState({
    super.key,
    required this.message,
    required this.icon,
    this.onRetry,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: message,
      icon: icon,
    );
  }
}
