import 'package:flutter/material.dart';
import '../../constants/manage_listings_constants.dart';
import '../../../../app/theme/theme.dart';

class AddListingButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddListingButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56.0,
        height: 56.0,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.add,
          color: AppColors.textWhite,
          size: ManageListingsConstants.largeIconSize,
        ),
      ),
    );
  }
}
