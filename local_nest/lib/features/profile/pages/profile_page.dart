import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme.dart';
import '../../../features/authentication/blocs/auth_bloc.dart';
import '../constants/profile_constants.dart';
import '../models/user_model.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /// Initialize data and load user profile from Firestore
  void _initializeData() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Trigger UserBloc to load profile from Firestore
      context.read<UserBloc>().add(LoadUserProfileEvent(currentUser.uid));
    }

    // Initialize stats with defaults
    _renterStats = RenterStats(
      favorites: ProfileConstants.defaultFavorites,
      messages: ProfileConstants.defaultMessages,
    );
  }

  void _handleEditProfile() {
    final userState = context.read<UserBloc>().state;
    if (userState is! UserLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait, loading profile...'),
        ),
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
      if (updated == true) {
        // Reload user profile after edit
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          context.read<UserBloc>().add(LoadUserProfileEvent(currentUser.uid));
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
        color: AppColors.primary.withOpacity(0.1),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '3 Active',
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
            height: 44,
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
        if (!authState.isAuthenticated && authState.status == AuthStatus.unauthenticated) {
          context.goNamed('intro');
        }
      },
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          // Show loading state
          if (state is UserLoading) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: const Center(
                child: CircularProgressIndicator(),
              ),
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
                    Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
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
                    height: 44,
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
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        );
        },
      ),
    );
  }

}
