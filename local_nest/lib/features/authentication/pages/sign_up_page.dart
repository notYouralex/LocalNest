import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme.dart';
import '../../../app/router/app_router.dart';
import '../blocs/blocs.dart';
import '../validators/sign_up_validators.dart';
import '../widgets/widgets.dart';

/// Sign Up page UI matching the Figma design with app theme
class SignUpPage extends StatefulWidget {
  /// User type selected in intro page (renter or landlord)
  final String userType;

  /// Callback when user selects sign in
  final VoidCallback? onSignInPressed;

  /// Callback when user presses back
  final VoidCallback? onBackPressed;

  const SignUpPage({
    super.key,
    required this.userType,
    this.onSignInPressed,
    this.onBackPressed,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final signUpBloc = context.read<SignUpBloc>();
      final state = signUpBloc.state;

      if (!state.agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please agree to the Terms & Conditions'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      context.read<SignUpBloc>().add(SignUpSubmitted(widget.userType));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SignUpBloc, SignUpState>(
        listener: (context, state) {
          if (state.status == SignUpStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Sign up failed'),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state.status == SignUpStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sign up successful'),
                backgroundColor: AppColors.primary,
              ),
            );
            // Navigate to login page after successful sign up
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.go(AppRoutes.login);
                }
              }
            );
          }
        },
        child: Column(
          children: [
            // Header with gradient background
            SignUpHeader(onBackPressed: widget.onBackPressed),

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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Full Name field
                        BlocBuilder<SignUpBloc, SignUpState>(
                          buildWhen: (previous, current) =>
                              previous.name != current.name,
                          builder: (context, state) {
                            return AuthTextField(
                              label: 'Full Name',
                              hintText: 'Juan Dela Cruz',
                              prefixIcon: Icons.person_outline,
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                context.read<SignUpBloc>().add(
                                      SignUpNameChanged(value),
                                    );
                              },
                              validator: SignUpValidators.validateName,
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Email field
                        BlocBuilder<SignUpBloc, SignUpState>(
                          buildWhen: (previous, current) =>
                              previous.email != current.email,
                          builder: (context, state) {
                            return AuthTextField(
                              label: 'Email Address',
                              hintText: 'your.email@example.com',
                              prefixIcon: Icons.email_outlined,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                context.read<SignUpBloc>().add(
                                      SignUpEmailChanged(value),
                                    );
                              },
                              validator: SignUpValidators.validateEmail,
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password field
                        BlocBuilder<SignUpBloc, SignUpState>(
                          buildWhen: (previous, current) =>
                              previous.password != current.password,
                          builder: (context, state) {
                            return PasswordTextField(
                              label: 'Password',
                              hintText: 'Create a password',
                              controller: _passwordController,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                context.read<SignUpBloc>().add(
                                      SignUpPasswordChanged(value),
                                    );
                              },
                              validator: SignUpValidators.validatePassword,
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password field
                        BlocBuilder<SignUpBloc, SignUpState>(
                          buildWhen: (previous, current) =>
                              previous.confirmPassword !=
                              current.confirmPassword ||
                              previous.password != current.password,
                          builder: (context, state) {
                            return PasswordTextField(
                              label: 'Confirm Password',
                              hintText: 'Confirm your password',
                              controller: _confirmPasswordController,
                              textInputAction: TextInputAction.done,
                              onChanged: (value) {
                                context.read<SignUpBloc>().add(
                                      SignUpConfirmPasswordChanged(value),
                                    );
                              },
                              validator: (value) =>
                                  SignUpValidators.validateConfirmPassword(
                                value,
                                state.password,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Terms & Conditions checkbox
                        BlocBuilder<SignUpBloc, SignUpState>(
                          buildWhen: (previous, current) =>
                              previous.agreeToTerms != current.agreeToTerms,
                          builder: (context, state) {
                            return TermsCheckbox(
                              value: state.agreeToTerms,
                              onChanged: (value) {
                                context.read<SignUpBloc>().add(
                                      SignUpTermsToggled(value ?? false),
                                    );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Create Account button
                        BlocBuilder<SignUpBloc, SignUpState>(
                          buildWhen: (previous, current) =>
                              previous.status != current.status,
                          builder: (context, state) {
                            return AuthPrimaryButton(
                              text: 'Create Account',
                              onPressed: () => _handleSignUp(context),
                              isLoading: state.status == SignUpStatus.loading,
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // Divider with text
                        const AuthDivider(text: 'or sign up with'),

                        const SizedBox(height: 24),

                        // Social login buttons
                        SocialLoginRow(
                          onGooglePressed: () {
                            context.read<SignUpBloc>().add(
                                  const SignUpWithGooglePressed(),
                                );
                          },
                          onFacebookPressed: () {
                            context.read<SignUpBloc>().add(
                                  const SignUpWithFacebookPressed(),
                                );
                          },
                        ),
                        const SizedBox(height: 32),

                        // Sign in link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: widget.onSignInPressed,
                              child: Text(
                                'Sign In',
                                style: AppTextStyles.linkLarge,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}