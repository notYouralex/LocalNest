import '../models/models.dart';

/// Abstract repository for messages
abstract class MessagesRepository {
  Future<List<ConversationModel>> getConversations();
  Future<void> pinConversation(String conversationId);
  Future<void> unpinConversation(String conversationId);
}

/// Implementation of MessagesRepository
class MessagesRepositoryImpl implements MessagesRepository {
  @override
  Future<List<ConversationModel>> getConversations() async {
    // TODO: Implement API call to fetch conversations
    // For now, return mock data
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      ConversationModel(
        id: '1',
        userId: 'user1',
        userName: 'Maria Santos',
        userAvatar: 'MS',
        listingId: 'listing1',
        listingName: 'Cozy Haven Boarding House',
        lastMessage: 'Yes, we still have rooms available!',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
        unreadCount: 2,
        isPinned: false,
      ),
      ConversationModel(
        id: '2',
        userId: 'user2',
        userName: 'Juan Reyes',
        userAvatar: 'JR',
        listingId: 'listing2',
        listingName: 'Student Hub Residence',
        lastMessage: 'You can visit this Saturday',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
        isPinned: false,
      ),
      ConversationModel(
        id: '3',
        userId: 'user3',
        userName: 'Anna Lim',
        userAvatar: 'AL',
        listingId: 'listing3',
        listingName: 'Modern Studio Suites',
        lastMessage: 'Pet deposit is ₱5,000',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 11)),
        unreadCount: 1,
        isPinned: false,
      ),
    ];
  }

  @override
  Future<void> pinConversation(String conversationId) async {
    // TODO: Implement API call to pin conversation
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> unpinConversation(String conversationId) async {
    // TODO: Implement API call to unpin conversation
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
