import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app/theme/theme.dart';

/// Custom header for Sign Up page with back button
class SignUpHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const SignUpHeader({
    super.key,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.primaryGradient,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Back button
            Positioned(
              left: 16,
              top: 8,
              child: IconButton(
                onPressed: onBackPressed,
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textWhite,
                  size: 24,
                ),
              ),
            ),
            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container
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
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Create Account',
                    style: AppTextStyles.heading1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Join LocalNest today',
                    style: AppTextStyles.subtitle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}