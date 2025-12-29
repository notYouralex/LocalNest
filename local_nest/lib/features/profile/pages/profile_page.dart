import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme.dart';
import '../constants/profile_constants.dart';
import '../models/user_model.dart';
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
  late UserProfile _userProfile;
  late NotificationSettings _notificationSettings;
  late RenterStats _renterStats;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /// Initialize user data synchronously
  void _initializeData() {
    try {
      // Initialize with default/mock data immediately
      _userProfile = UserProfile(
        id: '1',
        name: 'Juan Dela Cruz',
        email: 'juandc@email.com',
        accountType: 'renter',
        isVerified: false,
      );
      
      _notificationSettings = NotificationSettings(
        newListings: true,
        messages: true,
        availability: false,
      );
      
      _renterStats = RenterStats(
        favorites: ProfileConstants.defaultFavorites,
        messages: ProfileConstants.defaultMessages,
        alerts: ProfileConstants.defaultAlerts,
      );
      
      // Mark as loaded
      if (mounted) {
        setState(() => _isLoading = false);
      }

      // TODO: In real app, fetch from Firebase here asynchronously
      _loadUserDataFromBackend();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load profile: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Load user data from Firebase/backend (non-blocking)
  Future<void> _loadUserDataFromBackend() async {
    try {
      // TODO: Replace with actual Firebase call
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // TODO: Update with real user data
      // _userProfile = await FirebaseAuth.instance.currentUser?.toUserProfile();
      // _notificationSettings = await userService.getNotificationSettings();
      // _renterStats = await statsService.getRenterStats();
      
      setState(() {
        // Data updated
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
      // Don't show error for background loading, just keep initial data
    }
  }

  /// Legacy async load - replaced with sync init above
  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);
      
      // TODO: Replace with actual Firebase call
      await Future.delayed(const Duration(milliseconds: 300));
      
      _userProfile = UserProfile(
        id: '1',
        name: 'Juan Dela Cruz',
        email: 'juandc@email.com',
        accountType: 'renter',
        isVerified: false,
      );
      
      _notificationSettings = NotificationSettings(
        newListings: true,
        messages: true,
        availability: false,
      );
      
      _renterStats = RenterStats(
        favorites: ProfileConstants.defaultFavorites,
        messages: ProfileConstants.defaultMessages,
        alerts: ProfileConstants.defaultAlerts,
      );
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  void _handleAccountTypeChange(String type) {
    setState(() {
      _userProfile = _userProfile.copyWith(accountType: type);
    });
    // TODO: Update user account type in backend
  }

  void _handleNotificationSettingsChange(Map<String, bool> settings) {
    setState(() {
      _notificationSettings = _notificationSettings.copyWith(
        newListings: settings['newListings'],
        messages: settings['messages'],
        availability: settings['availability'],
      );
    });
    // TODO: Save notification preferences to backend
  }

  void _handleEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ProfileConstants.modalBorderRadius),
          topRight: Radius.circular(ProfileConstants.modalBorderRadius),
        ),
      ),
      builder: (context) => const EditProfilePage(),
    );
  }

  void _handleSavedSearches() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved Searches - Coming Soon')),
    );
    // TODO: Navigate to saved searches page
  }

  void _handlePrivacySafety() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy & Safety - Coming Soon')),
    );
    // TODO: Navigate to privacy settings page
  }

  void _handleHelpSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Support - Coming Soon')),
    );
    // TODO: Navigate to help/support page
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(ProfileConstants.logoutDialogTitle),
        content: const Text(ProfileConstants.logoutDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(ProfileConstants.cancelButtonLabel),
          ),
          TextButton(
            onPressed: () {
              // TODO: Call logout from auth service
              context.go('/login');
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
        const SizedBox(width: ProfileConstants.itemSpacing),
        Expanded(
          child: StatCard(
            count: _renterStats.alerts,
            label: ProfileConstants.alertsLabel,
            icon: Icons.notifications,
            backgroundColor: AppColors.statCardAlertsBackground,
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
                context.push('/manage-listings');
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
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
                _errorMessage!,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            ProfileHeader(
              userName: _userProfile.name,
              email: _userProfile.email,
              userType: _userProfile.accountType.toUpperCase(),
              onEditPressed: _handleEditProfile,
            ),
            const SizedBox(height: ProfileConstants.sectionSpacing),
            // Account type section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ProfileConstants.contentPadding,
              ),
              child: AccountTypeSection(
                selectedType: _userProfile.accountType,
                onTypeChanged: _handleAccountTypeChange,
              ),
            ),
            const SizedBox(height: ProfileConstants.sectionSpacing),
            // Stats cards (Renter only)
            if (_userProfile.accountType == 'renter')
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ProfileConstants.contentPadding,
                ),
                child: _buildStatsCards(),
              ),
            if (_userProfile.accountType == 'renter')
              const SizedBox(height: ProfileConstants.sectionSpacing),
            // My Listings section (Landlord only)
            if (_userProfile.accountType == 'landlord')
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ProfileConstants.contentPadding,
                ),
                child: _buildMyListingsCard(),
              ),
            if (_userProfile.accountType == 'landlord')
              const SizedBox(height: ProfileConstants.sectionSpacing),
            // Notifications section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ProfileConstants.contentPadding,
              ),
              child: NotificationsSection(
                newListingsEnabled: _notificationSettings.newListings,
                messagesEnabled: _notificationSettings.messages,
                availabilityEnabled: _notificationSettings.availability,
                onSettingsChanged: _handleNotificationSettingsChange,
              ),
            ),
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
                      icon: Icons.bookmark,
                      label: ProfileConstants.savedSearchesLabel,
                      onTap: _handleSavedSearches,
                      showDivider: true,
                    ),
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

}
