import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../listings/repositories/firestore_listing_repository.dart';
import '../models/models.dart';

/// Service for handling messaging with Firestore
class MessagingService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirestoreListingRepository _listingRepository;

  MessagingService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirestoreListingRepository? listingRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _listingRepository = listingRepository ?? FirestoreListingRepositoryImpl();

  String? get currentUserId => _auth.currentUser?.uid;

  // ==================== CONVERSATIONS ====================

  /// Get or create a conversation between current user and another user
  /// If listingId is provided, it creates a conversation related to that listing
  Future<String> getOrCreateConversation({
    required String otherUserId,
    required String otherUserName,
    String? otherUserAvatar,
    String? listingId,
    String? listingName,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not logged in');

    // Prevent messaging yourself
    if (userId == otherUserId) {
      throw Exception('You cannot message yourself');
    }

    // Get both users' data to validate roles
    final currentUserDoc = await _firestore.collection('users').doc(userId).get();
    final otherUserDoc = await _firestore.collection('users').doc(otherUserId).get();
    
    if (!currentUserDoc.exists) throw Exception('Current user not found');
    if (!otherUserDoc.exists) throw Exception('User not found');
    
    final currentUserData = currentUserDoc.data()!;
    final otherUserData = otherUserDoc.data()!;
    
    final currentUserRole = (currentUserData['userType'] as String? ?? '').toLowerCase();
    final otherUserRole = (otherUserData['userType'] as String? ?? '').toLowerCase();
    
    // Get other user's avatar from their profile if not provided
    final resolvedOtherUserAvatar = otherUserAvatar ?? 
                                    otherUserData['profileImageUrl'] as String? ?? 
                                    '';
    
    print('🔍 Role check - Current user: $currentUserRole, Other user: $otherUserRole');
    
    // If roles are not set in database, allow messaging (backward compatibility)
    if (currentUserRole.isEmpty || otherUserRole.isEmpty) {
      print('⚠️ Roles not set in database - allowing conversation');
    } else {
      // Validate that one is renter and one is landlord
      final isValidCombination = 
        (currentUserRole == 'renter' && otherUserRole == 'landlord') ||
        (currentUserRole == 'landlord' && otherUserRole == 'renter');
      
      if (!isValidCombination) {
        print('❌ Invalid role combination - Current: "$currentUserRole", Other: "$otherUserRole"');
        if (currentUserRole == otherUserRole) {
          throw Exception('You can only message between renters and landlords');
        } else {
          throw Exception('Invalid user roles for messaging. Your role: "$currentUserRole", Other role: "$otherUserRole"');
        }
      }
      
      print('✅ Valid role combination - Creating conversation');
    }

    // Create a consistent conversation ID (sorted user IDs)
    final sortedIds = [userId, otherUserId]..sort();
    final conversationId = '${sortedIds[0]}_${sortedIds[1]}';

    final conversationRef = _firestore.collection('conversations').doc(conversationId);
    final conversationDoc = await conversationRef.get();

    if (!conversationDoc.exists) {
      final currentUserName = currentUserData['displayName'] ?? 
                              currentUserData['firstName'] ?? 
                              'User';
      final currentUserAvatar = currentUserData['profileImageUrl'] ?? '';

      // Create new conversation
      await conversationRef.set({
        'id': conversationId,
        'participants': [userId, otherUserId],
        'participantInfo': {
          userId: {
            'name': currentUserName,
            'avatar': currentUserAvatar,
          },
          otherUserId: {
            'name': otherUserName,
            'avatar': resolvedOtherUserAvatar,
          },
        },
        'listingId': listingId ?? '',
        'listingName': listingName ?? '',
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': '',
        'createdAt': FieldValue.serverTimestamp(),
        'unreadCount': {
          userId: 0,
          otherUserId: 0,
        },
        'pinnedBy': [],
        'blockedBy': [],
      });
      
      // Track inquiry if this is about a listing
      if (listingId != null && listingId.isNotEmpty) {
        try {
          await _listingRepository.incrementInquiries(listingId);
          print('✅ Tracked inquiry for listing: $listingId');
        } catch (e) {
          print('⚠️ Failed to track inquiry: $e');
        }
      }
    }

    return conversationId;
  }

  /// Get stream of conversations for current user
  Stream<List<ConversationModel>> getConversationsStream() {
    final userId = currentUserId;
    print('🔍 MessagingService: Current user ID: $userId');
    if (userId == null) {
      print('❌ MessagingService: No user logged in');
      return Stream.value([]);
    }

    print('📡 MessagingService: Setting up conversations stream for user: $userId');
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      print('📥 MessagingService: Received ${snapshot.docs.length} conversation documents');
      final conversations = <ConversationModel>[];
      
      for (final doc in snapshot.docs) {
        print('  - Processing conversation: ${doc.id}');
        final conv = _conversationFromFirestore(doc, userId);
        if (conv != null) {
          // Fetch latest avatar from user document if stored avatar is empty
          if (conv.userAvatar.isEmpty && conv.odId.isNotEmpty) {
            final enrichedConv = await _enrichConversationWithUserAvatar(conv);
            conversations.add(enrichedConv);
          } else {
            conversations.add(conv);
          }
        }
      }
      
      print('✅ MessagingService: Returning ${conversations.length} conversations');
      return conversations;
    });
  }
  
  /// Fetch the latest user avatar from users collection
  Future<ConversationModel> _enrichConversationWithUserAvatar(ConversationModel conv) async {
    try {
      final userDoc = await _firestore.collection('users').doc(conv.odId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final profileImageUrl = userData['profileImageUrl'] as String? ?? '';
        if (profileImageUrl.isNotEmpty) {
          return conv.copyWith(userAvatar: profileImageUrl);
        }
      }
    } catch (e) {
      print('⚠️ Error fetching user avatar: $e');
    }
    return conv;
  }

  /// Get conversations once (not stream)
  Future<List<ConversationModel>> getConversations() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .get();

    final conversations = <ConversationModel>[];
    
    for (final doc in snapshot.docs) {
      final conv = _conversationFromFirestore(doc, userId);
      if (conv != null) {
        // Fetch latest avatar from user document if stored avatar is empty
        if (conv.userAvatar.isEmpty && conv.odId.isNotEmpty) {
          final enrichedConv = await _enrichConversationWithUserAvatar(conv);
          conversations.add(enrichedConv);
        } else {
          conversations.add(conv);
        }
      }
    }
    
    return conversations;
  }

  ConversationModel? _conversationFromFirestore(DocumentSnapshot doc, String currentUserId) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      print('    ⚠️  Conversation ${doc.id}: No data');
      return null;
    }

    // Check if blocked
    final blockedBy = List<String>.from(data['blockedBy'] ?? []);
    if (blockedBy.contains(currentUserId)) {
      print('    ⚠️  Conversation ${doc.id}: Blocked by current user');
      return null;
    }

    // Get other user's info
    final participants = List<String>.from(data['participants'] ?? []);
    print('    📋 Conversation ${doc.id}: Participants: $participants');
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    final participantInfo = data['participantInfo'] as Map<String, dynamic>? ?? {};
    final otherUserInfo = participantInfo[otherUserId] as Map<String, dynamic>? ?? {};

    final unreadCount = data['unreadCount'] as Map<String, dynamic>? ?? {};
    final pinnedBy = List<String>.from(data['pinnedBy'] ?? []);

    final lastMessageTime = data['lastMessageTime'] as Timestamp?;

    final conversation = ConversationModel(
      id: doc.id,
      odId: otherUserId,
      userName: otherUserInfo['name'] ?? 'Unknown',
      userAvatar: otherUserInfo['avatar'] ?? '',
      listingId: data['listingId'] ?? '',
      listingName: data['listingName'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: lastMessageTime?.toDate() ?? DateTime.now(),
      unreadCount: (unreadCount[currentUserId] as num?)?.toInt() ?? 0,
      isPinned: pinnedBy.contains(currentUserId),
    );
    print('    ✅ Conversation ${doc.id}: Created model for ${conversation.userName}');
    return conversation;
  }

  // ==================== MESSAGES ====================

  /// Send a message (max 250 characters)
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not logged in');

    // Enforce 250 character limit
    if (content.length > 250) {
      throw Exception('Message exceeds 250 character limit');
    }

    // Get current user's info
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data() ?? {};
    final userName = userData['displayName'] ?? userData['firstName'] ?? 'User';
    final userAvatar = userData['profileImageUrl'] ?? '';

    final messageRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    final timestamp = DateTime.now();
    final messageData = {
      'id': messageRef.id,
      'conversationId': conversationId,
      'senderId': userId,
      'senderName': userName,
      'senderAvatar': userAvatar,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': false,
      'status': 'sent',
      'isEdited': false,
      'isDeleted': false,
    };

    await messageRef.set(messageData);

    // Update conversation's last message and unread count
    final conversationRef = _firestore.collection('conversations').doc(conversationId);
    final conversationDoc = await conversationRef.get();
    final conversationData = conversationDoc.data() ?? {};
    final participants = List<String>.from(conversationData['participants'] ?? []);
    final otherUserId = participants.firstWhere((id) => id != userId, orElse: () => '');

    final currentUnread = conversationData['unreadCount'] as Map<String, dynamic>? ?? {};
    final otherUserUnread = (currentUnread[otherUserId] as num?)?.toInt() ?? 0;

    await conversationRef.update({
      'lastMessage': content,
      'lastMessageTime': Timestamp.fromDate(timestamp),
      'lastMessageSenderId': userId,
      'unreadCount': {
        ...currentUnread,
        otherUserId: otherUserUnread + 1,
      },
    });

    return MessageModel(
      id: messageRef.id,
      conversationId: conversationId,
      senderId: userId,
      senderName: userName,
      senderAvatar: userAvatar,
      content: content,
      timestamp: timestamp,
      isRead: false,
      status: MessageStatus.sent,
    );
  }

  /// Get stream of messages for a conversation (real-time)
  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            // Skip deleted messages
            if (data['isDeleted'] == true) return null;
            return _messageFromFirestore(doc);
          })
          .whereType<MessageModel>()
          .toList();
    });
  }

  /// Get messages once (not stream)
  Future<List<MessageModel>> getMessages(String conversationId) async {
    final snapshot = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          // Skip deleted messages
          if (data['isDeleted'] == true) return null;
          return _messageFromFirestore(doc);
        })
        .whereType<MessageModel>()
        .toList();
  }

  MessageModel _messageFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['timestamp'] as Timestamp?;
    final statusStr = data['status'] as String? ?? 'sent';

    MessageStatus status;
    switch (statusStr) {
      case 'sending':
        status = MessageStatus.sending;
        break;
      case 'delivered':
        status = MessageStatus.delivered;
        break;
      case 'read':
        status = MessageStatus.read;
        break;
      case 'failed':
        status = MessageStatus.failed;
        break;
      default:
        status = MessageStatus.sent;
    }

    return MessageModel(
      id: doc.id,
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderAvatar: data['senderAvatar'] ?? '',
      content: data['content'] ?? '',
      timestamp: timestamp?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      status: status,
      isEdited: data['isEdited'] ?? false,
    );
  }

  /// Edit a message
  Future<void> editMessage({
    required String conversationId,
    required String messageId,
    required String newContent,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not logged in');

    if (newContent.length > 250) {
      throw Exception('Message exceeds 250 character limit');
    }

    final messageRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId);

    final messageDoc = await messageRef.get();
    if (!messageDoc.exists) throw Exception('Message not found');

    final messageData = messageDoc.data()!;
    if (messageData['senderId'] != userId) {
      throw Exception('You can only edit your own messages');
    }

    await messageRef.update({
      'content': newContent,
      'isEdited': true,
    });

    // Update last message if this was the last message
    final conversationRef = _firestore.collection('conversations').doc(conversationId);
    final conversationDoc = await conversationRef.get();
    if (conversationDoc.data()?['lastMessageSenderId'] == userId) {
      final lastMsgQuery = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (lastMsgQuery.docs.isNotEmpty && lastMsgQuery.docs.first.id == messageId) {
        await conversationRef.update({'lastMessage': newContent});
      }
    }
  }

  /// Delete a message
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final messageRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId);

    final messageDoc = await messageRef.get();
    if (!messageDoc.exists) throw Exception('Message not found');

    final messageData = messageDoc.data()!;
    if (messageData['senderId'] != userId) {
      throw Exception('You can only delete your own messages');
    }

    // Soft delete
    await messageRef.update({
      'isDeleted': true,
      'content': 'This message was deleted',
    });
  }

  /// Mark conversation as read
  Future<void> markConversationAsRead(String conversationId) async {
    final userId = currentUserId;
    if (userId == null) return;

    // Update unread count
    await _firestore.collection('conversations').doc(conversationId).update({
      'unreadCount.$userId': 0,
    });

    // Mark all messages as read
    final messagesQuery = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in messagesQuery.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'status': 'read',
      });
    }
    await batch.commit();
  }

  // ==================== PIN/BLOCK ====================

  /// Pin a conversation
  Future<void> pinConversation(String conversationId) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _firestore.collection('conversations').doc(conversationId).update({
      'pinnedBy': FieldValue.arrayUnion([userId]),
    });
  }

  /// Unpin a conversation
  Future<void> unpinConversation(String conversationId) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _firestore.collection('conversations').doc(conversationId).update({
      'pinnedBy': FieldValue.arrayRemove([userId]),
    });
  }

  /// Block a user (conversation will be hidden but messages remain)
  Future<void> blockUser(String conversationId) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _firestore.collection('conversations').doc(conversationId).update({
      'blockedBy': FieldValue.arrayUnion([userId]),
    });

    // Also store in user's blocked list
    await _firestore.collection('users').doc(userId).update({
      'blockedUsers': FieldValue.arrayUnion([conversationId]),
    });
  }

  /// Unblock a user
  Future<void> unblockUser(String conversationId) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _firestore.collection('conversations').doc(conversationId).update({
      'blockedBy': FieldValue.arrayRemove([userId]),
    });

    await _firestore.collection('users').doc(userId).update({
      'blockedUsers': FieldValue.arrayRemove([conversationId]),
    });
  }

  /// Report a user
  Future<void> reportUser({
    required String conversationId,
    required String reportedUserId,
    required String reason,
  }) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _firestore.collection('reports').add({
      'reporterId': userId,
      'reportedUserId': reportedUserId,
      'conversationId': conversationId,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  // ==================== SEARCH ====================

  /// Search conversations by user name or listing name
  Future<List<ConversationModel>> searchConversations(String query) async {
    final conversations = await getConversations();
    final lowerQuery = query.toLowerCase();

    return conversations.where((conv) {
      return conv.userName.toLowerCase().contains(lowerQuery) ||
          conv.listingName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // ==================== UNREAD COUNT ====================

  /// Get total unread message count for current user
  Stream<int> getTotalUnreadCountStream() {
    final userId = currentUserId;
    if (userId == null) return Stream.value(0);

    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final unreadCount = data['unreadCount'] as Map<String, dynamic>? ?? {};
        total += (unreadCount[userId] as num?)?.toInt() ?? 0;
      }
      return total;
    });
  }

  /// Get conversation details
  Future<Map<String, dynamic>> getConversationDetails(String conversationId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final conversationDoc = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .get();

    if (!conversationDoc.exists) throw Exception('Conversation not found');

    final data = conversationDoc.data()!;
    final participants = List<String>.from(data['participants'] ?? []);
    final otherUserId = participants.firstWhere((id) => id != userId, orElse: () => '');
    final participantInfo = data['participantInfo'] as Map<String, dynamic>? ?? {};
    final otherUserInfo = participantInfo[otherUserId] as Map<String, dynamic>? ?? {};

    // Get the stored avatar, or fetch from user profile if empty
    String userAvatar = otherUserInfo['avatar'] ?? '';
    if (userAvatar.isEmpty && otherUserId.isNotEmpty) {
      try {
        final userDoc = await _firestore.collection('users').doc(otherUserId).get();
        if (userDoc.exists) {
          userAvatar = userDoc.data()?['profileImageUrl'] as String? ?? '';
        }
      } catch (e) {
        print('⚠️ Error fetching user avatar: $e');
      }
    }

    return {
      'conversationId': conversationId,
      'otherUserId': otherUserId,
      'userName': otherUserInfo['name'] ?? 'Unknown',
      'userAvatar': userAvatar,
      'listingName': data['listingName'] ?? '',
      'listingId': data['listingId'] ?? '',
    };
  }
}
