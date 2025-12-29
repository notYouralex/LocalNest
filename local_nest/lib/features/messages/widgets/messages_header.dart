import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';

/// Header widget for Messages page
class MessagesHeader extends StatelessWidget {
  final VoidCallback onSearchChanged;
  final TextEditingController searchController;

  const MessagesHeader({
    super.key,
    required this.onSearchChanged,
    required this.searchController,
  });

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
          Text(
            'Messages',
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.textWhite,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (_) => onSearchChanged(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search messages...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
              ),
            ),
          ),
          if (searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                searchController.clear();
                onSearchChanged();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
