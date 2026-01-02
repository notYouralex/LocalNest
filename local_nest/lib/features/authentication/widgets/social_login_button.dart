import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../app/theme/theme.dart';

/// Social login button widget for Google
class GoogleLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleLoginButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.background,
          side: const BorderSide(color: AppColors.border, width: 1.18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textSecondary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.google,
                    size: 18,
                    color: AppColors.google,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Google',
                    style: AppTextStyles.buttonTextDark,
                  ),
                ],
              ),
      ),
    );
  }
}
