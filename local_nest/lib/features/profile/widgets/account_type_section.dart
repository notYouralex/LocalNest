import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../constants/profile_constants.dart';

/// Account type selector widget
class AccountTypeSection extends StatefulWidget {
  final String selectedType; // 'renter' or 'landlord'
  final ValueChanged<String> onTypeChanged;

  const AccountTypeSection({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  State<AccountTypeSection> createState() => _AccountTypeSectionState();
}

class _AccountTypeSectionState extends State<AccountTypeSection> {
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(ProfileConstants.cardBorderRadius),
      ),
      padding: const EdgeInsets.all(ProfileConstants.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ProfileConstants.accountTypeTitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Toggle buttons
          Row(
            children: [
              Expanded(
                child: _AccountTypeButton(
                  label: ProfileConstants.renterLabel,
                  isSelected: _selectedType == 'renter',
                  icon: Icons.person,
                  onTap: () {
                    setState(() => _selectedType = 'renter');
                    widget.onTypeChanged('renter');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AccountTypeButton(
                  label: ProfileConstants.landlordLabel,
                  isSelected: _selectedType == 'landlord',
                  icon: Icons.home,
                  onTap: () {
                    setState(() => _selectedType = 'landlord');
                    widget.onTypeChanged('landlord');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual account type button
class _AccountTypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  const _AccountTypeButton({
    required this.label,
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : AppColors.background,
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
            width: 1,
          ),
          borderRadius:
              BorderRadius.circular(ProfileConstants.buttonBorderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color:
                    isSelected ? AppColors.textWhite : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
