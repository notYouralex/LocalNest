import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

/// Reusable input field for edit profile modal
class EditProfileInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Function(String)? onChanged;
  final bool readOnly;

  const EditProfileInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          readOnly: readOnly,
          enabled: !readOnly,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: AppTextStyles.inputHint,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
          style: AppTextStyles.inputText,
        ),
      ],
    );
  }
}
