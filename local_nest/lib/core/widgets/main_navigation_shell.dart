import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app/theme/theme.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/search/pages/search_page.dart';
import '../../features/favorites/favorites.dart';
import '../../features/messages/messages.dart';
import '../../features/messages/services/messaging_service.dart';
import '../../features/profile/profile.dart';
import '../../features/profile/bloc/user_bloc.dart';
import '../../features/profile/repositories/firestore_user_repository.dart';

/// Main navigation shell with bottom navigation bar
class MainNavigationShell extends StatefulWidget {
  final int? initialPageIndex;
  final String? searchQuery;

  const MainNavigationShell({
    super.key,
    this.initialPageIndex,
    this.searchQuery,
  });

  static void switchToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainNavigationShellState>();
    state?._onTabTapped(index);
  }

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;
  late List<Widget> _pages;
  final MessagingService _messagingService = MessagingService();
  StreamSubscription<int>? _unreadCountSubscription;
  int _unreadMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPageIndex ?? 0;
    _pages = [
      const HomePage(),
      SearchPage(initialQuery: widget.searchQuery),
      const FavoritesPage(),
      const MessagesPage(),
      BlocProvider(
        create: (context) => UserBloc(
          userRepository: FirestoreUserRepository(),
        ),
        child: const ProfilePage(),
      ),
    ];

    _subscribeToUnreadCount();
  }

  void _subscribeToUnreadCount() {
    try {
      _unreadCountSubscription = _messagingService
          .getTotalUnreadCountStream()
          .listen(
            (count) {
              if (mounted) {
                setState(() {
                  _unreadMessageCount = count;
                });
              }
            },
            onError: (error) {
              // Silently ignore stream error
            },
          );
    } catch (_) {}
  }

  @override
  void dispose() {
    _unreadCountSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  label: 'Home',
                  activeIcon: 'assets/icons/home_clicked.svg',
                  inactiveIcon: 'assets/icons/home_notclicked.svg',
                  isSelected: _currentIndex == 0,
                  onTap: () => _onTabTapped(0),
                ),
                _NavItem(
                  label: 'Search',
                  activeIcon: 'assets/icons/search_clicked.svg',
                  inactiveIcon: 'assets/icons/search_notclicked.svg',
                  isSelected: _currentIndex == 1,
                  onTap: () => _onTabTapped(1),
                ),
                _NavItem(
                  label: 'Favorites',
                  activeIcon: 'assets/icons/heart_clicked.svg',
                  inactiveIcon: 'assets/icons/heart_notclicked.svg',
                  isSelected: _currentIndex == 2,
                  onTap: () => _onTabTapped(2),
                ),
                _NavItem(
                  label: 'Messages',
                  activeIcon: 'assets/icons/messages_clicked.svg',
                  inactiveIcon: 'assets/icons/messages_notclicked.svg',
                  isSelected: _currentIndex == 3,
                  badgeCount: _unreadMessageCount,
                  onTap: () => _onTabTapped(3),
                ),
                _NavItem(
                  label: 'Profile',
                  activeIcon: 'assets/icons/profile_clicked.svg',
                  inactiveIcon: 'assets/icons/profile_notclicked.svg',
                  isSelected: _currentIndex == 4,
                  onTap: () => _onTabTapped(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

/// Navigation item widget with optional unread badge
class _NavItem extends StatelessWidget {
  final String label;
  final String activeIcon;
  final String inactiveIcon;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.isSelected,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  isSelected ? activeIcon : inactiveIcon,
                  width: 24,
                  height: 24,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
