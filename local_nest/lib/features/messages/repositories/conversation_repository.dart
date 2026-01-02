import '../models/models.dart';
import '../services/messaging_service.dart';

/// Abstract repository for conversation messages
abstract class ConversationRepository {
  Future<Map<String, dynamic>> getConversationWithMessages(String conversationId);
  Stream<List<MessageModel>> getMessagesStream(String conversationId);
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
  Future<void> blockUser(String conversationId);
  Future<void> reportUser({
    required String conversationId,
    required String reportedUserId,
    required String reason,
  });
}

/// Implementation of ConversationRepository using Firestore
class ConversationRepositoryImpl implements ConversationRepository {
  final MessagingService _messagingService;

  ConversationRepositoryImpl({MessagingService? messagingService})
      : _messagingService = messagingService ?? MessagingService();

  @override
  Future<Map<String, dynamic>> getConversationWithMessages(String conversationId) async {
    final details = await _messagingService.getConversationDetails(conversationId);
    final messages = await _messagingService.getMessages(conversationId);

    return {
      'conversationId': conversationId,
      'otherUserId': details['otherUserId'],
      'userName': details['userName'],
      'userAvatar': details['userAvatar'],
      'listingName': details['listingName'],
      'messages': messages,
    };
  }

  @override
  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    return _messagingService.getMessagesStream(conversationId);
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
  }) {
    return _messagingService.sendMessage(
      conversationId: conversationId,
      content: content,
    );
  }

  @override
  Future<void> editMessage({
    required String conversationId,
    required String messageId,
    required String newContent,
  }) {
    return _messagingService.editMessage(
      conversationId: conversationId,
      messageId: messageId,
      newContent: newContent,
    );
  }

  @override
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) {
    return _messagingService.deleteMessage(
      conversationId: conversationId,
      messageId: messageId,
    );
  }

  @override
  Future<void> markConversationAsRead(String conversationId) {
    return _messagingService.markConversationAsRead(conversationId);
  }

  @override
  Future<void> blockUser(String conversationId) {
    return _messagingService.blockUser(conversationId);
  }

  @override
  Future<void> reportUser({
    required String conversationId,
    required String reportedUserId,
    required String reason,
  }) {
    return _messagingService.reportUser(
      conversationId: conversationId,
      reportedUserId: reportedUserId,
      reason: reason,
    );
  }
}
