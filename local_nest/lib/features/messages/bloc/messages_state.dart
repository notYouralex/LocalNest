import 'package:equatable/equatable.dart';
import '../models/models.dart';

/// Abstract class for messages states
abstract class MessagesState extends Equatable {
  const MessagesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class MessagesInitialState extends MessagesState {
  const MessagesInitialState();
}

/// Loading state
class MessagesLoadingState extends MessagesState {
  const MessagesLoadingState();
}

/// Success state with conversations list
class MessagesLoadedState extends MessagesState {
  final List<ConversationModel> conversations;
  final List<ConversationModel> pinnedConversations;

  const MessagesLoadedState({
    required this.conversations,
    this.pinnedConversations = const [],
  });

  @override
  List<Object?> get props => [conversations, pinnedConversations];
}

/// Search results state
class ConversationsSearchState extends MessagesState {
  final List<ConversationModel> results;
  final String query;

  const ConversationsSearchState({
    required this.results,
    required this.query,
  });

  @override
  List<Object?> get props => [results, query];
}

/// Error state
class MessagesErrorState extends MessagesState {
  final String message;

  const MessagesErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
