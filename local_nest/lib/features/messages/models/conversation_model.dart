import 'package:equatable/equatable.dart';

/// Conversation model representing a message conversation
class ConversationModel extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String listingId;
  final String listingName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isPinned;

  const ConversationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.listingId,
    required this.listingName,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isPinned = false,
  });

  /// Create a copy with optional field updates
  ConversationModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? listingId,
    String? listingName,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isPinned,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      listingId: listingId ?? this.listingId,
      listingName: listingName ?? this.listingName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userAvatar,
    listingId,
    listingName,
    lastMessage,
    lastMessageTime,
    unreadCount,
    isPinned,
  ];
}
