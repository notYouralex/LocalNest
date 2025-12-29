import '../bloc/bloc.dart';

/// Extension to simplify state checking in ConversationBloc handlers
extension ConversationStateX on ConversationState {
  /// Get the current loaded state or throw
  ConversationMessagesLoadedState requireMessagesLoaded() {
    if (this is! ConversationMessagesLoadedState) {
      throw StateError('Expected ConversationMessagesLoadedState but got ${runtimeType}');
    }
    return this as ConversationMessagesLoadedState;
  }

  /// Check if the state is currently loaded
  bool get isMessagesLoaded => this is ConversationMessagesLoadedState;

  /// Safe cast to loaded state
  ConversationMessagesLoadedState? get asMessagesLoaded {
    if (this is ConversationMessagesLoadedState) {
      return this as ConversationMessagesLoadedState;
    }
    return null;
  }
}
