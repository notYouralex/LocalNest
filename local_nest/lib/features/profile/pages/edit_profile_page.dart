import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/cloudinary_service.dart';
import '../constants/edit_profile_modal_style.dart';
import '../widgets/edit_profile_input_field.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../models/user_profile.dart';

/// Edit profile bottom sheet modal
/// Shows form to edit user profile information
class EditProfilePage extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfilePage({
    super.key,
    required this.userProfile,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = false;
  String? _selectedImagePath;
  String? _uploadedImageUrl;
  final ImagePicker _imagePicker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.userProfile.displayName ?? '',
    );
    _emailController = TextEditingController(
      text: widget.userProfile.email,
    );
    _phoneController = TextEditingController(
      text: widget.userProfile.phoneNumber ?? '',
    );
    _uploadedImageUrl = widget.userProfile.profileImageUrl;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _initials {
    final names = _fullNameController.text.split(' ');
    return names.map((name) => name.isEmpty ? '' : name[0]).join().toUpperCase();
  }

  Future<void> _handleChangePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSaveChanges() async {
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? profileImageUrl = _uploadedImageUrl;

      // Upload image if new one is selected
      if (_selectedImagePath != null) {
        profileImageUrl = await _cloudinaryService.uploadImage(
          _selectedImagePath!,
          folder: 'localnest/profiles',
        );
      }

      // Update profile via BLoC
      if (mounted) {
        context.read<UserBloc>().add(
          UpdateUserProfileEvent(
            userId: widget.userProfile.id,
            displayName: _fullNameController.text.trim(),
            phoneNumber: _phoneController.text.trim().isEmpty 
                ? null 
                : _phoneController.text.trim(),
            profileImageUrl: profileImageUrl,
          ),
        );

        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(EditProfileModalStyle.horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  _buildAvatar(),
                  const SizedBox(height: EditProfileModalStyle.avatarPhotoSpacing),
                  // Change photo button
                  _buildChangePhotoButton(),
                  const SizedBox(height: EditProfileModalStyle.contentBottomSpacing),
                  // Full Name field
                  EditProfileInputField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: EditProfileModalStyle.fieldSpacing),
                  // Email field (read-only)
                  EditProfileInputField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email,
                    readOnly: true,
                  ),
                  const SizedBox(height: EditProfileModalStyle.fieldSpacing),
                  // Phone field
                  EditProfileInputField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                  ),
                ],
              ),
            ),
          ),
          // Bottom buttons
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(EditProfileModalStyle.modalBorderRadius),
          topRight: Radius.circular(EditProfileModalStyle.modalBorderRadius),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: EditProfileModalStyle.horizontalPadding,
        vertical: EditProfileModalStyle.verticalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Edit Profile',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textWhite,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.close,
              color: AppColors.textWhite,
              size: EditProfileModalStyle.closeIconSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    // Show selected image, uploaded image, or initials
    if (_selectedImagePath != null) {
      return Container(
        width: EditProfileModalStyle.avatarRadius,
        height: EditProfileModalStyle.avatarRadius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(File(_selectedImagePath!)),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty) {
      return Container(
        width: EditProfileModalStyle.avatarRadius,
        height: EditProfileModalStyle.avatarRadius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(_uploadedImageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: EditProfileModalStyle.avatarRadius,
        height: EditProfileModalStyle.avatarRadius,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            _initials,
            style: AppTextStyles.heading1.copyWith(
              fontSize: EditProfileModalStyle.avatarFontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textWhite,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildChangePhotoButton() {
    return GestureDetector(
      onTap: _handleChangePhoto,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            EditProfileModalStyle.buttonBorderRadius,
          ),
          color: AppColors.greenBackground,
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt,
              size: EditProfileModalStyle.cameraIconSize,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              'Change Photo',
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
        color: AppColors.greenBackground,
      ),
      padding: const EdgeInsets.all(EditProfileModalStyle.horizontalPadding),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    EditProfileModalStyle.buttonBorderRadius,
                  ),
                  color: AppColors.surface,
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(width: EditProfileModalStyle.itemSpacing),
          Expanded(
            child: GestureDetector(
              onTap: _isLoading ? null : _handleSaveChanges,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: _isLoading
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          EditProfileModalStyle.buttonBorderRadius,
                        ),
                        color: AppColors.primary.withValues(alpha: 0.5),
                      )
                    : BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppColors.primaryGradient,
                        ),
                        borderRadius: BorderRadius.circular(
                          EditProfileModalStyle.buttonBorderRadius,
                        ),
                      ),
                child: _isLoading
                    ? const SizedBox(
                        height: EditProfileModalStyle.loadingIndicatorSize,
                        width: EditProfileModalStyle.loadingIndicatorSize,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textWhite,
                          ),
                          strokeWidth:
                              EditProfileModalStyle.loadingStrokeWidth,
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}