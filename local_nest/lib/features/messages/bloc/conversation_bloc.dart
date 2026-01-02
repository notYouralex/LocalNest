import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import 'bloc.dart';

/// BLoC for managing a single conversation
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ConversationRepository repository;
  final MessagesRepository messagesRepository;
  StreamSubscription? _messagesSubscription;
  String? _otherUserId;

  ConversationBloc({
    required this.repository,
    required this.messagesRepository,
  }) : super(const ConversationInitialState()) {
    on<LoadConversationMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<EditMessageEvent>(_onEditMessage);
    on<DeleteMessageEvent>(_onDeleteMessage);
    on<MarkMessagesAsReadEvent>(_onMarkAsRead);
    on<PinConversationEvent>(_onPinConversation);
    on<BlockUserEvent>(_onBlockUser);
    on<ReportUserEvent>(_onReportUser);
    on<MessagesUpdatedEvent>(_onMessagesUpdated);
  }

  /// Load messages for a conversation and subscribe to real-time updates
  Future<void> _onLoadMessages(
    LoadConversationMessagesEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(const ConversationLoadingState());

    try {
      final result = await repository.getConversationWithMessages(event.conversationId);
      
      _otherUserId = result['otherUserId'] as String?;

      emit(ConversationMessagesLoadedState(
        conversationId: event.conversationId,
        otherUserId: _otherUserId ?? '',
        userName: result['userName'] as String,
        userAvatar: result['userAvatar'] as String,
        listingName: result['listingName'] as String,
        messages: result['messages'] as List<MessageModel>,
      ));

      // Mark messages as read
      add(MarkMessagesAsReadEvent(event.conversationId));

      // Subscribe to real-time message updates
      _messagesSubscription?.cancel();
      _messagesSubscription = repository.getMessagesStream(event.conversationId).listen(
        (messages) {
          add(MessagesUpdatedEvent(messages));
        },
        onError: (error) {
          debugPrint('Error in messages stream: $error');
        },
      );
    } catch (e) {
      emit(ConversationErrorState('Failed to load messages: ${e.toString()}'));
    }
  }

  /// Handle real-time message updates
  void _onMessagesUpdated(
    MessagesUpdatedEvent event,
    Emitter<ConversationState> emit,
  ) {
    final currentState = state.asMessagesLoaded;
    if (currentState == null) return;

    emit(ConversationMessagesLoadedState(
      conversationId: currentState.conversationId,
      otherUserId: currentState.otherUserId,
      userName: currentState.userName,
      userAvatar: currentState.userAvatar,
      listingName: currentState.listingName,
      messages: event.messages.cast<MessageModel>(),
      safetyReminderDismissed: currentState.safetyReminderDismissed,
    ));
  }

  /// Send a new message
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final currentState = state.asMessagesLoaded;
    if (currentState == null) return;

    try {
      final newMessage = await repository.sendMessage(
        conversationId: event.conversationId,
        content: event.content,
      );

      final updatedMessages = [...currentState.messages, newMessage];

      emit(ConversationMessagesLoadedState(
        conversationId: currentState.conversationId,
        userName: currentState.userName,
        userAvatar: currentState.userAvatar,
        listingName: currentState.listingName,
        messages: updatedMessages,
        safetyReminderDismissed: currentState.safetyReminderDismissed,
      ));
    } catch (e) {
      emit(ConversationErrorState('Failed to send message: ${e.toString()}'));
    }
  }

  /// Edit a message
  Future<void> _onEditMessage(
    EditMessageEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final currentState = state.asMessagesLoaded;
    if (currentState == null) return;

    try {
      await repository.editMessage(
        conversationId: event.conversationId,
        messageId: event.messageId,
        newContent: event.newContent,
      );

      final updatedMessages = currentState.messages.map((msg) {
        if (msg.id == event.messageId) {
          return msg.copyWith(content: event.newContent);
        }
        return msg;
      }).toList();

      emit(ConversationMessagesLoadedState(
        conversationId: currentState.conversationId,
        userName: currentState.userName,
        userAvatar: currentState.userAvatar,
        listingName: currentState.listingName,
        messages: updatedMessages,
        safetyReminderDismissed: currentState.safetyReminderDismissed,
      ));

      emit(ConversationActionSuccessState(
        actionType: 'edit',
        conversationId: event.conversationId,
        updatedMessages: updatedMessages,
      ));
    } catch (e) {
      emit(ConversationErrorState('Failed to edit message: ${e.toString()}'));
    }
  }

  /// Delete a message
  Future<void> _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final currentState = state.asMessagesLoaded;
    if (currentState == null) return;

    try {
      await repository.deleteMessage(
        conversationId: event.conversationId,
        messageId: event.messageId,
      );

      final updatedMessages = currentState.messages
          .where((msg) => msg.id != event.messageId)
          .toList();

      emit(ConversationMessagesLoadedState(
        conversationId: currentState.conversationId,
        userName: currentState.userName,
        userAvatar: currentState.userAvatar,
        listingName: currentState.listingName,
        messages: updatedMessages,
        safetyReminderDismissed: currentState.safetyReminderDismissed,
      ));

      emit(ConversationActionSuccessState(
        actionType: 'delete',
        conversationId: event.conversationId,
        updatedMessages: updatedMessages,
      ));
    } catch (e) {
      emit(ConversationErrorState('Failed to delete message: ${e.toString()}'));
    }
  }

  /// Mark messages as read
  Future<void> _onMarkAsRead(
    MarkMessagesAsReadEvent event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      await repository.markConversationAsRead(event.conversationId);
    } catch (e) {
      // Silently handle - marking as read is non-critical
      // but log in debug mode
      assert(() {
        debugPrint('Warning: Failed to mark conversation as read: $e');
        return true;
      }());
    }
  }

  /// Pin conversation to top
  Future<void> _onPinConversation(
    PinConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      await messagesRepository.pinConversation(event.conversationId);
      
      emit(ConversationActionSuccessState(
        actionType: 'pin',
        conversationId: event.conversationId,
      ));
    } catch (e) {
      emit(ConversationErrorState('Failed to pin conversation: ${e.toString()}'));
    }
  }

  /// Block user
  Future<void> _onBlockUser(
    BlockUserEvent event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      await repository.blockUser(event.conversationId);
      
      emit(ConversationActionSuccessState(
        actionType: 'block',
        conversationId: event.conversationId,
      ));
    } catch (e) {
      emit(ConversationErrorState('Failed to block user: ${e.toString()}'));
    }
  }

  /// Report user
  Future<void> _onReportUser(
    ReportUserEvent event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      await repository.reportUser(
        conversationId: event.conversationId,
        reportedUserId: event.reportedUserId,
        reason: event.reason,
      );
      
      emit(ConversationActionSuccessState(
        actionType: 'report',
        conversationId: event.conversationId,
      ));
    } catch (e) {
      emit(ConversationErrorState('Failed to report user: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
