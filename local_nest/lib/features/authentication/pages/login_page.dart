import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../widgets/widgets.dart';

/// Login page UI matching the Figma design
class LoginPage extends StatefulWidget {
  /// Callback when user selects sign up
  final VoidCallback? onSignUpPressed;
  
  /// Callback when user selects forgot password
  final VoidCallback? onForgotPasswordPressed;
  
  /// Callback when user signs in with email/password
  final void Function(String email, String password, bool rememberMe)? onSignIn;
  
  /// Callback when user signs in with Google
  final VoidCallback? onGoogleSignIn;
  
  /// Callback when user signs in with Facebook
  final VoidCallback? onFacebookSignIn;

  const LoginPage({
    super.key,
    this.onSignUpPressed,
    this.onForgotPasswordPressed,
    this.onSignIn,
    this.onGoogleSignIn,
    this.onFacebookSignIn,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSignIn?.call(
        _emailController.text.trim(),
        _passwordController.text,
        _rememberMe,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with gradient background
          const AuthHeader(
            title: 'Welcome Back',
            subtitle: 'Sign in to continue',
          ),
          
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
                      // Email field
                      AuthTextField(
                        label: 'Email Address',
                        hintText: 'your.email@example.com',
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validateEmail,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Password field
                      PasswordTextField(
                        label: 'Password',
                        hintText: 'Enter your password',
                        controller: _passwordController,
                        textInputAction: TextInputAction.done,
                        validator: _validatePassword,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Remember me & Forgot password row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Remember me checkbox
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _rememberMe = !_rememberMe;
                                  });
                                },
                                child: Text(
                                  'Remember me',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          
                          // Forgot password button
                          TextButton(
                            onPressed: widget.onForgotPasswordPressed,
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyles.link,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Sign in button
                      AuthPrimaryButton(
                        text: 'Sign In',
                        onPressed: _handleSignIn,
                        isLoading: _isLoading,
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Divider with text
                      const AuthDivider(text: 'or continue with'),
                      
                      const SizedBox(height: 24),
                      
                      // Social login buttons
                      SocialLoginRow(
                        onGooglePressed: widget.onGoogleSignIn,
                        onFacebookPressed: widget.onFacebookSignIn,
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: widget.onSignUpPressed,
                            child: Text(
                              'Sign Up',
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
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
