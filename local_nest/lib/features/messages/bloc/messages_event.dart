import 'package:equatable/equatable.dart';

/// Abstract class for messages events
abstract class MessagesEvent extends Equatable {
  const MessagesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all conversations
class LoadConversationsEvent extends MessagesEvent {
  const LoadConversationsEvent();
}

/// Event to search conversations by name
class SearchConversationsEvent extends MessagesEvent {
  final String query;

  const SearchConversationsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to refresh conversations
class RefreshConversationsEvent extends MessagesEvent {
  const RefreshConversationsEvent();
}
