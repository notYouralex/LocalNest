import '../models/models.dart';
import '../services/messaging_service.dart';

/// Abstract repository for messages
abstract class MessagesRepository {
  Future<List<ConversationModel>> getConversations();
  Stream<List<ConversationModel>> getConversationsStream();
  Future<void> pinConversation(String conversationId);
  Future<void> unpinConversation(String conversationId);
  Future<List<ConversationModel>> searchConversations(String query);
  Stream<int> getTotalUnreadCountStream();
}

/// Implementation of MessagesRepository using Firestore
class MessagesRepositoryImpl implements MessagesRepository {
  final MessagingService _messagingService;

  MessagesRepositoryImpl({MessagingService? messagingService})
      : _messagingService = messagingService ?? MessagingService();

  @override
  Future<List<ConversationModel>> getConversations() {
    return _messagingService.getConversations();
  }

  @override
  Stream<List<ConversationModel>> getConversationsStream() {
    return _messagingService.getConversationsStream();
  }

  @override
  Future<void> pinConversation(String conversationId) {
    return _messagingService.pinConversation(conversationId);
  }

  @override
  Future<void> unpinConversation(String conversationId) {
    return _messagingService.unpinConversation(conversationId);
  }

  @override
  Future<List<ConversationModel>> searchConversations(String query) {
    return _messagingService.searchConversations(query);
  }

  @override
  Stream<int> getTotalUnreadCountStream() {
    return _messagingService.getTotalUnreadCountStream();
  }
}
