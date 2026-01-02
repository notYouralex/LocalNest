import 'package:equatable/equatable.dart';

/// Conversation model representing a message conversation
class ConversationModel extends Equatable {
  final String id;
  final String odId; // Other user's ID
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
    this.odId = '', // Other user's ID (optional for backwards compatibility)
    required this.userName,
    required this.userAvatar,
    required this.listingId,
    required this.listingName,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isPinned = false,
  });

  // Legacy getter for backwards compatibility
  String get userId => odId;

  /// Create a copy with optional field updates
  ConversationModel copyWith({
    String? id,
    String? odId,
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
      odId: odId ?? this.odId,
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
    odId,
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
