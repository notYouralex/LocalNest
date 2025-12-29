import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../constants/message_bubble_constants.dart';
import '../models/models.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MessageBubbleConstants.horizontalMargin,
        vertical: MessageBubbleConstants.verticalMargin,
      ),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: onLongPress,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * MessageBubbleConstants.maxWidth,
              ),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? MessageBubbleConstants.userMessageColor
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(MessageBubbleConstants.borderRadius),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: MessageBubbleConstants.horizontalPadding,
                vertical: MessageBubbleConstants.verticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isCurrentUser
                          ? MessageBubbleConstants.userTextColor
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: MessageBubbleConstants.contentTimeSpacing),
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isCurrentUser
                          ? AppColors.textWhite.withOpacity(MessageBubbleConstants.timeStampOpacity)
                          : AppColors.textSecondary,
                      fontSize: MessageBubbleConstants.timeStampFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
