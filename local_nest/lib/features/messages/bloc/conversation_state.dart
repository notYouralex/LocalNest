import 'package:equatable/equatable.dart';
import '../models/models.dart';

/// Abstract class for conversation states
abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ConversationInitialState extends ConversationState {
  const ConversationInitialState();
}

/// Loading state
class ConversationLoadingState extends ConversationState {
  const ConversationLoadingState();
}

/// Messages loaded state
class ConversationMessagesLoadedState extends ConversationState {
  final String conversationId;
  final String userName;
  final String userAvatar;
  final String listingName;
  final List<MessageModel> messages;
  final bool safetyReminderDismissed;

  const ConversationMessagesLoadedState({
    required this.conversationId,
    required this.userName,
    required this.userAvatar,
    required this.listingName,
    required this.messages,
    this.safetyReminderDismissed = false,
  });

  ConversationMessagesLoadedState copyWith({
    String? conversationId,
    String? userName,
    String? userAvatar,
    String? listingName,
    List<MessageModel>? messages,
    bool? safetyReminderDismissed,
  }) {
    return ConversationMessagesLoadedState(
      conversationId: conversationId ?? this.conversationId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      listingName: listingName ?? this.listingName,
      messages: messages ?? this.messages,
      safetyReminderDismissed: safetyReminderDismissed ?? this.safetyReminderDismissed,
    );
  }

  @override
  List<Object?> get props => [
    conversationId,
    userName,
    userAvatar,
    listingName,
    messages,
    safetyReminderDismissed,
  ];
}

/// Sending message state
class MessageSendingState extends ConversationState {
  final String conversationId;
  final List<MessageModel> messages;

  const MessageSendingState({
    required this.conversationId,
    required this.messages,
  });

  @override
  List<Object?> get props => [conversationId, messages];
}

/// Message sent state
class MessageSentState extends ConversationState {
  final String conversationId;
  final MessageModel message;
  final List<MessageModel> allMessages;

  const MessageSentState({
    required this.conversationId,
    required this.message,
    required this.allMessages,
  });

  @override
  List<Object?> get props => [conversationId, message, allMessages];
}

/// Error state
class ConversationErrorState extends ConversationState {
  final String message;

  const ConversationErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

/// Success state for actions (edit, delete, block, report)
class ConversationActionSuccessState extends ConversationState {
  final String actionType;
  final String conversationId;
  final List<MessageModel>? updatedMessages;

  const ConversationActionSuccessState({
    required this.actionType,
    required this.conversationId,
    this.updatedMessages,
  });

  @override
  List<Object?> get props => [actionType, conversationId, updatedMessages];
}
