import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme.dart';
import '../bloc/bloc.dart';

/// App bar widget for Conversation Detail page
class ConversationAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ConversationState state;
  final VoidCallback onMenuPressed;

  const ConversationAppBar({
    super.key,
    required this.state,
    required this.onMenuPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    if (state is ConversationMessagesLoadedState) {
      final loadedState = state as ConversationMessagesLoadedState;
      return AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loadedState.userName,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              loadedState.listingName,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.more_vert),
              color: AppColors.textPrimary,
              onPressed: onMenuPressed,
            ),
          ),
        ],
      );
    }

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: AppColors.textPrimary,
        onPressed: () => context.pop(),
      ),
    );
  }
}
