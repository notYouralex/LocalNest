import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../constants/profile_constants.dart';

/// Notifications settings section
class NotificationsSection extends StatefulWidget {
  final bool newListingsEnabled;
  final bool messagesEnabled;
  final bool availabilityEnabled;
  final ValueChanged<Map<String, bool>> onSettingsChanged;

  const NotificationsSection({
    super.key,
    this.newListingsEnabled = true,
    this.messagesEnabled = true,
    this.availabilityEnabled = false,
    required this.onSettingsChanged,
  });

  @override
  State<NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<NotificationsSection> {
  late bool _newListingsEnabled;
  late bool _messagesEnabled;
  late bool _availabilityEnabled;

  @override
  void initState() {
    super.initState();
    _newListingsEnabled = widget.newListingsEnabled;
    _messagesEnabled = widget.messagesEnabled;
    _availabilityEnabled = widget.availabilityEnabled;
  }

  void _updateSettings() {
    widget.onSettingsChanged({
      'newListings': _newListingsEnabled,
      'messages': _messagesEnabled,
      'availability': _availabilityEnabled,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.all(ProfileConstants.contentPadding),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ProfileConstants.notificationsTitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Divider(
            height: 0,
            color: AppColors.border,
            thickness: 1,
          ),
          // New Listings toggle
          _NotificationItem(
            title: ProfileConstants.newListingsTitle,
            description: ProfileConstants.newListingsDesc,
            value: _newListingsEnabled,
            onChanged: (value) {
              setState(() => _newListingsEnabled = value);
              _updateSettings();
            },
          ),
          Divider(
            height: 0,
            color: AppColors.border,
            thickness: 1,
          ),
          // Messages toggle
          _NotificationItem(
            title: ProfileConstants.messagesTitle,
            description: ProfileConstants.messagesDesc,
            value: _messagesEnabled,
            onChanged: (value) {
              setState(() => _messagesEnabled = value);
              _updateSettings();
            },
          ),
          Divider(
            height: 0,
            color: AppColors.border,
            thickness: 1,
          ),
          // Availability updates toggle
          _NotificationItem(
            title: ProfileConstants.availabilityTitle,
            description: ProfileConstants.availabilityDesc,
            value: _availabilityEnabled,
            onChanged: (value) {
              setState(() => _availabilityEnabled = value);
              _updateSettings();
            },
          ),
        ],
      ),
    );
  }
}

/// Individual notification toggle item
class _NotificationItem extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationItem({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ProfileConstants.contentPadding,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
