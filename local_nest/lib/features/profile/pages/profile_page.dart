import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme.dart';
import '../../../features/authentication/blocs/auth_bloc.dart';
import '../../../features/favorites/services/favorites_service.dart';
import '../../../features/messages/services/messaging_service.dart';
import '../../../features/listings/repositories/firestore_listing_repository.dart';
import '../constants/profile_constants.dart';
import '../models/user_profile.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../widgets/widgets.dart';
import '../presentation/widgets/stat_card.dart';
import '../presentation/widgets/menu_item.dart';
import 'edit_profile_page.dart';

/// Profile page showing user information and settings
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late RenterStats _renterStats;
  bool _isLoadingStats = true;

  // Landlord stats
  int _activeListingsCount = 0;
  bool _isLoadingListingsCount = true;

  // Stream subscriptions for real-time updates
  StreamSubscription<int>? _favoritesSubscription;
  StreamSubscription<int>? _messagesSubscription;
  StreamSubscription<int>? _activeListingsSubscription;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    _messagesSubscription?.cancel();
    _activeListingsSubscription?.cancel();
    super.dispose();
  }

  /// Initialize data and load user profile from Firestore
  void _initializeData() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Trigger UserBloc to load profile from Firestore
      context.read<UserBloc>().add(LoadUserProfileEvent(currentUser.uid));
      // Subscribe to real-time stats updates
      _subscribeToStats(currentUser.uid);
      _subscribeToLandlordStats(currentUser.uid);
    }

    // Initialize stats with defaults while loading
    _renterStats = RenterStats(favorites: 0, messages: 0);
  }

  /// Subscribe to real-time stats updates from Firestore
  void _subscribeToStats(String userId) {
    final favoritesService = FavoritesServiceImpl();
    final messagingService = MessagingService();

    // Listen to favorites count changes
    _favoritesSubscription = favoritesService
        .watchFavoritesCount(userId)
        .listen(
          (count) {
            if (mounted) {
              setState(() {
                _renterStats = _renterStats.copyWith(favorites: count);
                _isLoadingStats = false;
              });
            }
          },
          onError: (e) {
            debugPrint('Error watching favorites: $e');
            if (mounted) {
              setState(() => _isLoadingStats = false);
            }
          },
        );

    // Listen to conversations count changes
    _messagesSubscription = messagingService.watchConversationsCount().listen(
      (count) {
        if (mounted) {
          setState(() {
            _renterStats = _renterStats.copyWith(messages: count);
            _isLoadingStats = false;
          });
        }
      },
      onError: (e) {
        debugPrint('Error watching messages: $e');
        if (mounted) {
          setState(() => _isLoadingStats = false);
        }
      },
    );
  }

  /// Subscribe to real-time landlord stats updates from Firestore
  void _subscribeToLandlordStats(String userId) {
    final listingRepository = FirestoreListingRepositoryImpl();

    debugPrint('Subscribing to landlord stats for userId: $userId');

    // Listen to active listings count changes
    _activeListingsSubscription = listingRepository
        .watchLandlordActiveListingsCount(userId)
        .listen(
          (count) {
            debugPrint('Received active listings count: $count');
            if (mounted) {
              setState(() {
                _activeListingsCount = count;
                _isLoadingListingsCount = false;
              });
            }
          },
          onError: (e) {
            debugPrint('Error watching active listings: $e');
            if (mounted) {
              setState(() {
                _activeListingsCount = 0;
                _isLoadingListingsCount = false;
              });
            }
          },
        );
  }

  void _handleEditProfile() {
    final userState = context.read<UserBloc>().state;
    if (userState is! UserLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait, loading profile...')),
      );
      return;
    }

    final userBloc = context.read<UserBloc>();

    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ProfileConstants.modalBorderRadius),
          topRight: Radius.circular(ProfileConstants.modalBorderRadius),
        ),
      ),
      builder: (modalContext) => BlocProvider.value(
        value: userBloc,
        child: EditProfilePage(userProfile: userState.userProfile),
      ),
    ).then((updated) {
      if (updated == true && context.mounted) {
        // Reload user profile after edit
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          userBloc.add(LoadUserProfileEvent(currentUser.uid));
        }
      }
    });
  }

  void _handlePrivacySafety() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Safety'),
        content: const Text(
          'Privacy and safety settings are coming soon. '
          'You can manage your account settings here once available.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleHelpSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'Help and support resources are coming soon. '
          'Contact our support team at support@localnest.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(ProfileConstants.logoutDialogTitle),
        content: const Text(ProfileConstants.logoutDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(ProfileConstants.cancelButtonLabel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Clear user profile from UserBloc - use parent context
              context.read<UserBloc>().add(const ClearUserProfileEvent());
              // Trigger AuthBloc logout which will sign out and update auth state
              context.read<AuthBloc>().add(const LogoutRequested());
              // BlocListener will handle the navigation
            },
            child: Text(
              ProfileConstants.logoutLabel,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    if (_isLoadingStats) {
      return Row(
        children: [
          Expanded(
            child: StatCard(
              count: 0,
              label: ProfileConstants.favoritesLabel,
              icon: Icons.favorite,
              backgroundColor: AppColors.statCardFavoritesBackground,
              isLoading: true,
            ),
          ),
          const SizedBox(width: ProfileConstants.itemSpacing),
          Expanded(
            child: StatCard(
              count: 0,
              label: ProfileConstants.messagesLabel,
              icon: Icons.mail,
              backgroundColor: AppColors.statCardMessagesBackground,
              isLoading: true,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: StatCard(
            count: _renterStats.favorites,
            label: ProfileConstants.favoritesLabel,
            icon: Icons.favorite,
            backgroundColor: AppColors.statCardFavoritesBackground,
          ),
        ),
        const SizedBox(width: ProfileConstants.itemSpacing),
        Expanded(
          child: StatCard(
            count: _renterStats.messages,
            label: ProfileConstants.messagesLabel,
            icon: Icons.mail,
            backgroundColor: AppColors.statCardMessagesBackground,
          ),
        ),
      ],
    );
  }

  Widget _buildMyListingsCard() {
    return Container(
      padding: const EdgeInsets.all(ProfileConstants.cardSpacing),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: ProfileConstants.borderWidth,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ProfileConstants.myListingsTitle,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              _isLoadingListingsCount
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_activeListingsCount Active',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ],
          ),
          const SizedBox(height: ProfileConstants.itemSpacing),
          Text(
            ProfileConstants.myListingsDesc,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: ProfileConstants.cardSpacing),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                context.goNamed('manageListings');
              },
              icon: const Icon(Icons.home, size: 18),
              label: Text(
                ProfileConstants.manageListingsButton,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ProfileConstants.buttonBorderRadius,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        // If user logs out, navigate to intro page
        if (!authState.isAuthenticated &&
            authState.status == AuthStatus.unauthenticated) {
          context.goNamed('intro');
        }
      },
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          // Show loading state
          if (state is UserLoading) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          // Show error state
          if (state is UserError) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        final currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser != null) {
                          context.read<UserBloc>().add(
                            LoadUserProfileEvent(currentUser.uid),
                          );
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Show profile when loaded
          if (state is UserLoaded) {
            final userProfile = state.userProfile;
            return Scaffold(
              backgroundColor: AppColors.background,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header with Firestore user data
                    ProfileHeader(
                      userName: userProfile.displayName ?? 'User',
                      email: userProfile.email,
                      userType: userProfile.userType.toUpperCase(),
                      profileImageUrl: userProfile.profileImageUrl,
                      onEditPressed: _handleEditProfile,
                    ),
                    const SizedBox(height: ProfileConstants.sectionSpacing),
                    // Stats cards (Renter only)
                    if (userProfile.userType == 'renter')
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ProfileConstants.contentPadding,
                        ),
                        child: _buildStatsCards(),
                      ),
                    if (userProfile.userType == 'renter')
                      const SizedBox(height: ProfileConstants.sectionSpacing),
                    // My Listings section (Landlord only)
                    if (userProfile.userType == 'landlord')
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ProfileConstants.contentPadding,
                        ),
                        child: _buildMyListingsCard(),
                      ),
                    if (userProfile.userType == 'landlord')
                      const SizedBox(height: ProfileConstants.sectionSpacing),
                    // Settings menu
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ProfileConstants.contentPadding,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(
                            color: AppColors.border,
                            width: ProfileConstants.borderWidth,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            MenuItem(
                              icon: Icons.security,
                              label: ProfileConstants.privacyLabel,
                              onTap: _handlePrivacySafety,
                              showDivider: true,
                            ),
                            MenuItem(
                              icon: Icons.help,
                              label: ProfileConstants.helpLabel,
                              onTap: _handleHelpSupport,
                              showDivider: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: ProfileConstants.sectionSpacing),
                    // Logout button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ProfileConstants.contentPadding,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _handleLogout,
                          icon: const Icon(Icons.logout, size: 18),
                          label: Text(
                            ProfileConstants.logoutLabel,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: AppColors.textWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ProfileConstants.buttonBorderRadius,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Version info
                    Text(
                      ProfileConstants.appVersion,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Bottom padding for navigation
                    SafeArea(
                      child: SizedBox(
                        height: ProfileConstants.bottomNavPadding,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Initial state - show placeholder
          return Scaffold(
            backgroundColor: AppColors.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
