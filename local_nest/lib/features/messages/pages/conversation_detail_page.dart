import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../app/theme/theme.dart';
import '../bloc/bloc.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../widgets/widgets.dart';

class ConversationDetailPage extends StatefulWidget {
  final String conversationId;
  final ConversationRepository? repository;
  final MessagesRepository? messagesRepository;

  const ConversationDetailPage({
    super.key,
    required this.conversationId,
    this.repository,
    this.messagesRepository,
  });

  @override
  State<ConversationDetailPage> createState() => _ConversationDetailPageState();
}

class _ConversationDetailPageState extends State<ConversationDetailPage> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  late ConversationBloc _conversationBloc;
  late ConversationRepository _repository;
  late MessagesRepository _messagesRepository;
  bool _safetyReminderDismissed = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _repository = widget.repository ?? ConversationRepositoryImpl();
    _messagesRepository = widget.messagesRepository ?? MessagesRepositoryImpl();

    _conversationBloc = ConversationBloc(
      repository: _repository,
      messagesRepository: _messagesRepository,
    );

    Future.microtask(() {
      _conversationBloc.add(LoadConversationMessagesEvent(widget.conversationId));
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _conversationBloc.close();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || content.length > 250) return;

    _conversationBloc.add(
      SendMessageEvent(
        conversationId: widget.conversationId,
        content: content,
      ),
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: BlocBuilder<ConversationBloc, ConversationState>(
        buildWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        builder: (context, state) {
          return ConversationAppBar(
            state: state,
            onMenuPressed: _showConversationMenu,
          );
        },
      ),
    );
  }

  void _showMessageOptions(MessageModel message, List<MessageModel> allMessages) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MessageOptionsBottomSheet(
        message: message,
        onEdit: () {
          Navigator.pop(context);
          _showEditMessageDialog(message);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteMessage(message.id);
        },
      ),
    );
  }

  void _showEditMessageDialog(MessageModel message) {
    showDialog(
      context: context,
      builder: (context) => EditMessageDialog(
        message: message,
        onCancel: () => Navigator.pop(context),
        onSave: (newContent) {
          _conversationBloc.add(
            EditMessageEvent(
              conversationId: widget.conversationId,
              messageId: message.id,
              newContent: newContent,
            ),
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deleteMessage(String messageId) {
    _conversationBloc.add(
      DeleteMessageEvent(
        conversationId: widget.conversationId,
        messageId: messageId,
      ),
    );
  }

  void _showConversationMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ConversationMenuBottomSheet(
        onBlock: () {
          Navigator.pop(context);
          _showBlockConfirmation();
        },
        onReport: () {
          Navigator.pop(context);
          _showReportDialog();
        },
      ),
    );
  }

  void _showBlockConfirmation() {
    showDialog(
      context: context,
      builder: (context) => BlockConfirmationDialog(
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          // TODO: Get userId from state
          // _conversationBloc.add(BlockUserEvent('userId'));
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User blocked')),
          );
        },
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => ReportUserDialog(
        onCancel: () => Navigator.pop(context),
        onSubmit: (reason) {
          // TODO: Get userId from state
          // _conversationBloc.add(ReportUserEvent(
          //   userId: 'userId',
          //   reason: reason,
          // ));
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConversationBloc>.value(
      value: _conversationBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: BlocListener<ConversationBloc, ConversationState>(
          listener: (context, state) {
            if (state is ConversationActionSuccessState) {
              if (state.actionType == 'delete') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message deleted')),
                );
              }
            }
            if (state is ConversationErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: BlocBuilder<ConversationBloc, ConversationState>(
            builder: (context, state) {
              if (state is ConversationLoadingState) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ConversationMessagesLoadedState) {
                return Column(
                  children: [
                    // Safety reminder
                    if (!_safetyReminderDismissed)
                      SafetyReminderBanner(
                        onDismiss: () {
                          setState(() => _safetyReminderDismissed = true);
                        },
                      ),
                    // Messages list
                    Expanded(
                      child: _buildMessagesList(state),
                    ),
                    // Input area
                    ConversationInputArea(
                      messageController: _messageController,
                      onSendMessage: _sendMessage,
                      state: state,
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(ConversationMessagesLoadedState state) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    // Show empty state if no messages
    if (state.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No messages yet',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start the conversation by sending a message',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final previousMessage = index > 0 ? state.messages[index - 1] : null;
        final showDateSeparator = previousMessage == null ||
            !_isSameDay(previousMessage.timestamp, message.timestamp);

        return Column(
          children: [
            if (showDateSeparator)
              DateSeparator(
                date: message.timestamp,
              ),
            MessageBubble(
              message: message,
              isCurrentUser: message.senderId == currentUserId,
              onLongPress: () => _showMessageOptions(message, state.messages),
            ),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
