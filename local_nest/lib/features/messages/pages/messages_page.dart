import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../app/router/router.dart';
import '../bloc/bloc.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../widgets/widgets.dart';

class MessagesPage extends StatefulWidget {
  final MessagesRepository? repository;

  const MessagesPage({super.key, this.repository});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late TextEditingController _searchController;
  late MessagesBloc _messagesBloc;
  late MessagesRepository _repository;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _repository = widget.repository ?? MessagesRepositoryImpl();
    _messagesBloc = MessagesBloc(repository: _repository);

    Future.microtask(() {
      _messagesBloc.add(const LoadConversationsEvent());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messagesBloc.close();
    super.dispose();
  }

  void _handleSearch(String query) {
    if (query.isEmpty) {
      _messagesBloc.add(const LoadConversationsEvent());
    } else {
      _messagesBloc.add(SearchConversationsEvent(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MessagesBloc>.value(
      value: _messagesBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              MessagesHeader(
                searchController: _searchController,
                onSearchChanged: () => _handleSearch(_searchController.text),
              ),
              Expanded(
                child: BlocBuilder<MessagesBloc, MessagesState>(
                  builder: (context, state) {
                    if (state is MessagesLoadingState) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is MessagesErrorState) {
                      return ErrorStateWidget(
                        message: state.message,
                        onRetry: () {
                          _messagesBloc.add(const LoadConversationsEvent());
                        },
                      );
                    }

                    if (state is ConversationsSearchState) {
                      if (state.results.isEmpty) {
                        return EmptyStateWidget(
                          title: 'No conversations found',
                          icon: Icons.search_off,
                        );
                      }
                      return _buildConversationsList(state.results);
                    }

                    if (state is MessagesLoadedState) {
                      final allConversations = [
                        ...state.pinnedConversations,
                        ...state.conversations,
                      ];

                      if (allConversations.isEmpty) {
                        return EmptyStateWidget(
                          title: 'No messages yet',
                          icon: Icons.mail_outline,
                        );
                      }

                      return _buildConversationsList(allConversations);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationsList(List<ConversationModel> conversations) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return ConversationListItem(
          conversation: conversation,
          onTap: () {
            AppNavigation.goToConversation(context, conversation.id);
          },
        );
      },
    );
  }
}
