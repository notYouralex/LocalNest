import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../app/theme/theme.dart';

/// Social login button type
enum SocialLoginType { google, facebook }

/// Social login button widget
class SocialLoginButton extends StatelessWidget {
  final SocialLoginType type;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.type,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
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
                  _buildIcon(),
                  const SizedBox(width: 8),
                  Text(
                    _getLabel(),
                    style: AppTextStyles.buttonTextDark,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (type) {
      case SocialLoginType.google:
        return const FaIcon(
          FontAwesomeIcons.google,
          size: 18,
          color: AppColors.google,
        );
      case SocialLoginType.facebook:
        return const FaIcon(
          FontAwesomeIcons.facebookF,
          size: 18,
          color: AppColors.facebook,
        );
    }
  }

  String _getLabel() {
    switch (type) {
      case SocialLoginType.google:
        return 'Google';
      case SocialLoginType.facebook:
        return 'Facebook';
    }
  }
}

/// Row with Google and Facebook buttons
class SocialLoginRow extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onFacebookPressed;
  final bool isGoogleLoading;
  final bool isFacebookLoading;

  const SocialLoginRow({
    super.key,
    this.onGooglePressed,
    this.onFacebookPressed,
    this.isGoogleLoading = false,
    this.isFacebookLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SocialLoginButton(
            type: SocialLoginType.google,
            onPressed: onGooglePressed,
            isLoading: isGoogleLoading,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SocialLoginButton(
            type: SocialLoginType.facebook,
            onPressed: onFacebookPressed,
            isLoading: isFacebookLoading,
          ),
        ),
      ],
    );
  }
}
