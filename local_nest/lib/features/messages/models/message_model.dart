import 'package:equatable/equatable.dart';

/// Message model representing a single message in a conversation
class MessageModel extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageStatus status;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.status = MessageStatus.sent,
  });

  /// Create a copy with optional field updates
  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    MessageStatus? status,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    senderName,
    senderAvatar,
    content,
    timestamp,
    isRead,
    status,
  ];
}

/// Enum for message status
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}
