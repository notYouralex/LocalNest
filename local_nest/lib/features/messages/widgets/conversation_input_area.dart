import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../bloc/bloc.dart';
import '../constants/messages_constants.dart';

/// Input area widget for Conversation Detail page
class ConversationInputArea extends StatefulWidget {
  final TextEditingController messageController;
  final VoidCallback onSendMessage;
  final ConversationMessagesLoadedState state;

  const ConversationInputArea({
    super.key,
    required this.messageController,
    required this.onSendMessage,
    required this.state,
  });

  @override
  State<ConversationInputArea> createState() => _ConversationInputAreaState();
}

class _ConversationInputAreaState extends State<ConversationInputArea> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.textSecondary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TextField(
                    controller: widget.messageController,
                    maxLines: null,
                    maxLength: MessagesConstants.maxMessageLength,
                    buildCounter: (context,
                        {required currentLength, required isFocused, maxLength}) {
                      return Text(
                        '$currentLength/$maxLength',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: MessagesConstants.typingHintText,
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.onSendMessage,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.send,
                    color: AppColors.textWhite,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            MessagesConstants.reportText,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
