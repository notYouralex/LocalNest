import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme.dart';
import '../constants/constants.dart';
import '../../messages/services/messaging_service.dart';

class ActionButtons extends StatelessWidget {
  final String? listingId;
  final String? listingTitle;
  final String? landlordId;
  final String? landlordName;

  const ActionButtons({
    Key? key,
    this.listingId,
    this.listingTitle,
    this.landlordId,
    this.landlordName,
  }) : super(key: key);

  Future<void> _handleMessage(BuildContext context) async {
    if (landlordId == null || landlordId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to contact landlord')),
      );
      return;
    }

    try {
      final messagingService = MessagingService();
      
      // Get or create conversation
      final conversationId = await messagingService.getOrCreateConversation(
        otherUserId: landlordId!,
        otherUserName: landlordName ?? 'Landlord',
        listingId: listingId,
        listingName: listingTitle,
      );

      // Navigate to conversation
      if (context.mounted) {
        context.push('/home/messages/$conversationId');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start conversation: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Message Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handleMessage(context),
            icon: const Icon(Icons.message),
            label: const Text('Message Landlord'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(badgeBorderRadius),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: itemSpacing),

        // Report Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement report functionality
            },
            icon: const Icon(Icons.flag),
            label: const Text('Report Listing'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(badgeBorderRadius),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
