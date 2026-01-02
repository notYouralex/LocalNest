import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Reusable user avatar widget that displays profile picture or initials
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? displayName;
  final double radius;
  final double fontSize;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.displayName,
    this.radius = 40,
    this.fontSize = 18,
  });

  String get _initials {
    if (displayName == null || displayName!.isEmpty) {
      return '?';
    }
    final names = displayName!.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return displayName![0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Show image if available
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(imageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Show initials if no image
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite,
          ),
        ),
      ),
    );
  }
}
