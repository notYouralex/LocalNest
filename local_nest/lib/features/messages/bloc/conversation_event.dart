import 'package:equatable/equatable.dart';

/// Abstract class for conversation events
abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load messages in a conversation
class LoadConversationMessagesEvent extends ConversationEvent {
  final String conversationId;

  const LoadConversationMessagesEvent(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Event to send a message
class SendMessageEvent extends ConversationEvent {
  final String conversationId;
  final String content;

  const SendMessageEvent({
    required this.conversationId,
    required this.content,
  });

  @override
  List<Object?> get props => [conversationId, content];
}

/// Event to edit a message
class EditMessageEvent extends ConversationEvent {
  final String conversationId;
  final String messageId;
  final String newContent;

  const EditMessageEvent({
    required this.conversationId,
    required this.messageId,
    required this.newContent,
  });

  @override
  List<Object?> get props => [conversationId, messageId, newContent];
}

/// Event to delete a message
class DeleteMessageEvent extends ConversationEvent {
  final String conversationId;
  final String messageId;

  const DeleteMessageEvent({
    required this.conversationId,
    required this.messageId,
  });

  @override
  List<Object?> get props => [conversationId, messageId];
}

/// Event to pin conversation to top
class PinConversationEvent extends ConversationEvent {
  final String conversationId;

  const PinConversationEvent(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Event to block user
class BlockUserEvent extends ConversationEvent {
  final String conversationId;

  const BlockUserEvent(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Event to report user
class ReportUserEvent extends ConversationEvent {
  final String conversationId;
  final String reportedUserId;
  final String reason;

  const ReportUserEvent({
    required this.conversationId,
    required this.reportedUserId,
    required this.reason,
  });

  @override
  List<Object?> get props => [conversationId, reportedUserId, reason];
}

/// Event to mark messages as read
class MarkMessagesAsReadEvent extends ConversationEvent {
  final String conversationId;

  const MarkMessagesAsReadEvent(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Event when messages are updated from stream
class MessagesUpdatedEvent extends ConversationEvent {
  final List messages;

  const MessagesUpdatedEvent(this.messages);

  @override
  List<Object?> get props => [messages];
}
