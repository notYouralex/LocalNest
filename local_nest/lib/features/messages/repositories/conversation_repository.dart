import '../models/models.dart';

/// Abstract repository for conversation messages
abstract class ConversationRepository {
  Future<Map<String, dynamic>> getConversationWithMessages(String conversationId);
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
  });
  Future<void> editMessage({
    required String conversationId,
    required String messageId,
    required String newContent,
  });
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  });
  Future<void> markConversationAsRead(String conversationId);
  Future<void> blockUser(String userId);
  Future<void> reportUser({
    required String userId,
    required String reason,
  });
}

/// Implementation of ConversationRepository
class ConversationRepositoryImpl implements ConversationRepository {
  @override
  Future<Map<String, dynamic>> getConversationWithMessages(String conversationId) async {
    // TODO: Implement API call to fetch conversation with messages
    await Future.delayed(const Duration(milliseconds: 500));
    
    final messages = [
      MessageModel(
        id: '1',
        conversationId: conversationId,
        senderId: 'user1',
        senderName: 'Maria Santos',
        senderAvatar: 'MS',
        content: 'Hello! Are you interested in the room?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        isRead: true,
      ),
      MessageModel(
        id: '2',
        conversationId: conversationId,
        senderId: 'currentUser',
        senderName: 'You',
        senderAvatar: 'YU',
        content: 'Yes! Is it still available?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
        isRead: true,
      ),
      MessageModel(
        id: '3',
        conversationId: conversationId,
        senderId: 'user1',
        senderName: 'Maria Santos',
        senderAvatar: 'MS',
        content: 'Yes, we still have rooms available!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: true,
      ),
      MessageModel(
        id: '4',
        conversationId: conversationId,
        senderId: 'currentUser',
        senderName: 'You',
        senderAvatar: 'YU',
        content: 'Great! Can I schedule a visit?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
        isRead: true,
      ),
    ];

    return {
      'userName': 'Maria Santos',
      'userAvatar': 'MS',
      'listingName': 'Cozy Haven Boarding House',
      'messages': messages,
    };
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    // TODO: Implement API call to send message
    await Future.delayed(const Duration(milliseconds: 300));
    
    return MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      senderId: 'currentUser',
      senderName: 'You',
      senderAvatar: 'YU',
      content: content,
      timestamp: DateTime.now(),
      isRead: true,
      status: MessageStatus.sent,
    );
  }

  @override
  Future<void> editMessage({
    required String conversationId,
    required String messageId,
    required String newContent,
  }) async {
    // TODO: Implement API call to edit message
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    // TODO: Implement API call to delete message
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> markConversationAsRead(String conversationId) async {
    // TODO: Implement API call to mark conversation as read
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> blockUser(String userId) async {
    // TODO: Implement API call to block user
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> reportUser({
    required String userId,
    required String reason,
  }) async {
    // TODO: Implement API call to report user
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
