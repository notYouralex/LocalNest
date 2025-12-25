import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';

/// Header widget for the intro screen with logo and title
class IntroHeader extends StatelessWidget {
  const IntroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 24, left: 24, right: 24),
      child: Column(
        children: [
          // Logo container
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.home,
                size: 32,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // App name
          const Text(
            'LocalNest',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          
          // Tagline
          Text(
            'Find your perfect boarding house',
            style: TextStyle(
              color: AppColors.textWhite.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
