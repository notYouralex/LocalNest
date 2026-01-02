import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../app/theme/theme.dart';
import '../constants/search_constants.dart';

/// Reusable search bar widget with integrated filter button and clear button
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onClearTap;
  final bool showClearButton;
  final bool isFilterActive;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
    required this.onClearTap,
    this.showClearButton = false,
    this.isFilterActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SearchConstants.searchBarHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(SearchConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Input Field
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SvgPicture.asset(
                    'assets/icons/search_notclicked.svg',
                    fit: BoxFit.scaleDown,
                    colorFilter: ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
                  ),
                ),
                suffixIcon: _buildSuffixIcon(),
                hintText: SearchConstants.searchHintText,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
          ),
          // Clear Button
          if (showClearButton)
            GestureDetector(
              onTap: onClearTap,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: SearchConstants.iconSize,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    return GestureDetector(
      onTap: onFilterTap,
      child: Semantics(
        label: 'Open filters',
        button: true,
        enabled: true,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/filter.svg',
                fit: BoxFit.scaleDown,
                colorFilter: ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
              ),
              if (isFilterActive)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
