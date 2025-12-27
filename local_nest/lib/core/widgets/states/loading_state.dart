import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';

/// Reusable loading state widget for displaying loading indicators
/// Used across multiple pages to maintain consistent UX
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final double? height;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
