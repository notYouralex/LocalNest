import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import 'bloc.dart';

/// BLoC for managing messages list
class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final MessagesRepository repository;

  MessagesBloc({required this.repository}) : super(const MessagesInitialState()) {
    on<LoadConversationsEvent>(_onLoadConversations);
    on<SearchConversationsEvent>(_onSearchConversations);
    on<RefreshConversationsEvent>(_onRefreshConversations);
  }

  /// Handle loading conversations
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
    } catch (e) {
      emit(MessagesErrorState('Failed to load conversations: ${e.toString()}'));
    }
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

      final conversations = await repository.getConversations();
      final results = conversations
          .where((c) => c.userName.toLowerCase().contains(event.query.toLowerCase()))
          .toList();

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
}
