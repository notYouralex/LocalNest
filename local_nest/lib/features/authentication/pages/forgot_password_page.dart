import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme.dart';
import '../widgets/widgets.dart';
import '../services/services.dart';
import '../models/models.dart';

/// Forgot Password page with two states:
/// 1. Email input form
/// 2. Email sent confirmation
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  String _sentEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final authService = FirebasePasswordResetService();
        await authService.sendPasswordResetEmail(_emailController.text.trim());
        
        if (mounted) {
          setState(() {
            _isLoading = false;
            _emailSent = true;
            _sentEmail = _emailController.text.trim();
          });
        }
      } on AuthException catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send reset email. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _handleTryAnotherEmail() {
    setState(() {
      _emailSent = false;
      _emailController.clear();
    });
  }

  void _handleBackToSignIn() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with gradient background and back button
          _buildHeader(),
          
          // Form container
          Expanded(
            child: Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0, -24, 0),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 50,
                    offset: Offset(0, -25),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: _emailSent ? _buildEmailSentContent() : _buildEmailFormContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.primaryGradient,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Back button
            Positioned(
              top: 8,
              left: 16,
              child: IconButton(
                onPressed: _handleBackToSignIn,
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textWhite,
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/logo.svg',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Forgot Password?',
                    style: AppTextStyles.heading1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "We'll help you reset it",
                    style: AppTextStyles.subtitle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Description text
          Text(
            "Enter your email address and we'll send you instructions to reset your password.",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Email input field
          AuthTextField(
            label: 'Email Address',
            hintText: 'your.email@example.com',
            prefixIcon: Icons.email_outlined,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email address';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Send Reset Link button
          AuthPrimaryButton(
            text: 'Send Reset Link',
            onPressed: _handleSendResetLink,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 32),
          
          // Back to Sign In link
          TextButton(
            onPressed: _handleBackToSignIn,
            child: Text(
              '← Back to Sign In',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSentContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Success icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 40,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 24),
        
        // Check Your Email heading
        Text(
          'Check Your Email',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        
        // Description with email
        Text(
          "We've sent password reset instructions to",
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          _sentEmail,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        // Info box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                "Didn't receive the email?",
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Check your spam folder or try again in a few minutes.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Try Another Email button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: _handleTryAnotherEmail,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Try Another Email',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        // Back to Sign In link
        TextButton(
          onPressed: _handleBackToSignIn,
          child: Text(
            '← Back to Sign In',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
