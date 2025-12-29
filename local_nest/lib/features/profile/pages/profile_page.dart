import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme.dart';
import '../constants/profile_constants.dart';
import '../widgets/widgets.dart';
import 'edit_profile_page.dart';

/// Profile page showing user information and settings
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _selectedAccountType = 'renter';
  bool _newListingsEnabled = true;
  bool _messagesEnabled = true;
  bool _availabilityEnabled = false;

  // TODO: Replace with real user data from Firebase Auth / Firestore
  final String _userName = 'Juan Dela Cruz';
  final String _userEmail = 'juandc@email.com';
  final int _favoriteCount = 5;
  final int _messageCount = 12;
  final int _alertCount = 3;

  void _handleAccountTypeChange(String type) {
    setState(() => _selectedAccountType = type);
    // TODO: Update user account type in backend
  }

  void _handleNotificationSettingsChange(Map<String, bool> settings) {
    setState(() {
      _newListingsEnabled = settings['newListings'] ?? true;
      _messagesEnabled = settings['messages'] ?? true;
      _availabilityEnabled = settings['availability'] ?? false;
    });
    // TODO: Save notification preferences to backend
  }

  void _handleEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => const EditProfilePage(),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Call logout from auth service
              context.go('/login');
            },
            child: Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemTile(String title, IconData icon) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: () {
        // TODO: Handle menu item tap
      },
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: AppColors.border,
      indent: 16,
      endIndent: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            ProfileHeader(
              userName: _userName,
              email: _userEmail,
              userType: _selectedAccountType.toUpperCase(),
              onEditPressed: _handleEditProfile,
            ),
            const SizedBox(height: ProfileConstants.sectionSpacing),
            // Account type section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ProfileConstants.contentPadding,
              ),
              child: AccountTypeSection(
                selectedType: _selectedAccountType,
                onTypeChanged: _handleAccountTypeChange,
              ),
            ),
            const SizedBox(height: ProfileConstants.sectionSpacing),
            // Stats cards
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ProfileConstants.contentPadding,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      count: _favoriteCount,
                      label: ProfileConstants.favoritesLabel,
                      icon: Icons.favorite,
                      iconBackgroundColor: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      count: _messageCount,
                      label: ProfileConstants.messagesLabel,
                      icon: Icons.mail,
                      iconBackgroundColor: AppColors.successLight.withOpacity(
                        0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      count: _alertCount,
                      label: ProfileConstants.alertsLabel,
                      icon: Icons.notifications,
                      iconBackgroundColor: const Color(
                        0xFFF3E8FF,
                      ).withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ProfileConstants.sectionSpacing),
            // Notifications section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ProfileConstants.contentPadding,
              ),
              child: NotificationsSection(
                newListingsEnabled: _newListingsEnabled,
                messagesEnabled: _messagesEnabled,
                availabilityEnabled: _availabilityEnabled,
                onSettingsChanged: _handleNotificationSettingsChange,
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
            SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
          ],
        ),
      ),
    );
  }
}
