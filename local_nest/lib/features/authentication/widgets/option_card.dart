import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../models/models.dart';
import 'feature_chip.dart';

/// Option card widget for selecting user type (Renter/Landlord)
class OptionCard extends StatefulWidget {
  final IntroOption option;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.option,
    required this.onTap,
  });

  @override
  State<OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<OptionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.option.borderColor.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OptionHeader(option: widget.option),
              const SizedBox(height: 16),
              FeaturesList(features: widget.option.features),
              const SizedBox(height: 16),
              _OptionButton(option: widget.option, onTap: widget.onTap),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header section of the option card with icon and text
class _OptionHeader extends StatelessWidget {
  final IntroOption option;

  const _OptionHeader({required this.option});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon container
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: option.iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            option.icon,
            size: 24,
            color: option.iconColor,
          ),
        ),
        const SizedBox(width: 16),
        
        // Title and subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                option.title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                option.subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Action button for the option card
class _OptionButton extends StatelessWidget {
  final IntroOption option;
  final VoidCallback onTap;

  const _OptionButton({
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: option.isOutline ? Colors.transparent : option.buttonColor,
          foregroundColor: option.isOutline ? AppColors.textPrimary : AppColors.textWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: option.isOutline
                ? BorderSide(color: option.borderColor.withOpacity(0.2))
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              option.buttonText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 16),
          ],
        ),
      ),
    );
  }
}
