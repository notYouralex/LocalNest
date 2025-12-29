import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../constants/profile_constants.dart';

/// Profile header widget with user info and avatar
class ProfileHeader extends StatelessWidget {
  final String userName;
  final String email;
  final String userType;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.email,
    required this.userType,
    this.onEditPressed,
  });

  String get _initials {
    final names = userName.split(' ');
    return names.map((name) => name[0]).take(2).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ProfileConstants.profileTitle,
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.textWhite,
                  fontSize: 20,
                ),
              ),
              IconButton(
                onPressed: onEditPressed,
                icon: const Icon(Icons.edit),
                color: AppColors.textWhite,
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // User info and avatar
          Row(
            children: [
              // Avatar
              Container(
                width: ProfileConstants.avatarRadius * 2,
                height: ProfileConstants.avatarRadius * 2,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initials,
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.primary,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textWhite80,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // User type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        userType,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textWhite,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
