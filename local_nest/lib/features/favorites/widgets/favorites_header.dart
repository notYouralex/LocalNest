import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../constants/favorites_constants.dart';

/// Favorites page header with gradient background
class FavoritesHeader extends StatelessWidget {
  final int count;

  const FavoritesHeader({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: FavoritesConstants.headerExpandedHeight,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeader(),
        collapseMode: CollapseMode.none,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FavoritesConstants.headerHorizontalPadding,
          vertical: FavoritesConstants.headerVerticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildTitle(),
            const SizedBox(height: 8),
            _buildSubtitle(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Favorites',
      style: AppTextStyles.heading1.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      '$count saved properties',
      style: AppTextStyles.bodySmall.copyWith(
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }
}
