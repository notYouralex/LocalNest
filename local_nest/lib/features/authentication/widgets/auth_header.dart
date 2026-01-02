import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../app/theme/theme.dart';

/// Gradient header for authentication screens
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? icon;
  final double height;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.height = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.primaryGradient,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(height: 16),
            ] else ...[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/logo.svg',
                    fit: BoxFit.fill
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: AppTextStyles.heading1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
