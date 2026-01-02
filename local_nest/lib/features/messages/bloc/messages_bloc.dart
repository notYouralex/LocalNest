import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/repositories.dart';
import 'bloc.dart';

/// BLoC for managing messages list
class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final MessagesRepository repository;
  StreamSubscription? _conversationsSubscription;

  MessagesBloc({required this.repository}) : super(const MessagesInitialState()) {
    on<LoadConversationsEvent>(_onLoadConversations);
    on<SearchConversationsEvent>(_onSearchConversations);
    on<RefreshConversationsEvent>(_onRefreshConversations);
    on<ConversationsUpdatedEvent>(_onConversationsUpdated);
  }

  /// Handle loading conversations and subscribe to real-time updates
  Future<void> _onLoadConversations(
    LoadConversationsEvent event,
    Emitter<MessagesState> emit,
  ) async {
    emit(const MessagesLoadingState());

    try {
      final conversations = await repository.getConversations();
      
      // Separate pinned and regular conversations
      final pinned = conversations.where((c) => c.isPinned).toList();
      final regular = conversations.where((c) => !c.isPinned).toList();

      emit(MessagesLoadedState(
        conversations: regular,
        pinnedConversations: pinned,
      ));

      // Subscribe to real-time updates
      _conversationsSubscription?.cancel();
      _conversationsSubscription = repository.getConversationsStream().listen(
        (conversations) {
          add(ConversationsUpdatedEvent(conversations));
        },
        onError: (error) {
          // Handle error silently, we already have data loaded
        },
      );
    } catch (e) {
      emit(MessagesErrorState('Failed to load conversations: ${e.toString()}'));
    }
  }

  /// Handle real-time conversation updates
  void _onConversationsUpdated(
    ConversationsUpdatedEvent event,
    Emitter<MessagesState> emit,
  ) {
    final pinned = event.conversations.where((c) => c.isPinned).toList();
    final regular = event.conversations.where((c) => !c.isPinned).toList();

    emit(MessagesLoadedState(
      conversations: regular,
      pinnedConversations: pinned,
    ));
  }

  /// Handle searching conversations
  Future<void> _onSearchConversations(
    SearchConversationsEvent event,
    Emitter<MessagesState> emit,
  ) async {
    try {
      if (event.query.isEmpty) {
        // Reload all conversations
        add(const LoadConversationsEvent());
        return;
      }

      final results = await repository.searchConversations(event.query);

      emit(ConversationsSearchState(
        results: results,
        query: event.query,
      ));
    } catch (e) {
      emit(MessagesErrorState('Search failed: ${e.toString()}'));
    }
  }

  /// Handle refreshing conversations
  Future<void> _onRefreshConversations(
    RefreshConversationsEvent event,
    Emitter<MessagesState> emit,
  ) async {
    add(const LoadConversationsEvent());
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    return super.close();
  }
}
