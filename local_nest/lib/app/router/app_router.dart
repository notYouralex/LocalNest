import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/authentication.dart';

/// Route paths constants
class AppRoutes {
  AppRoutes._();
  
  static const String intro = '/';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
}

/// Navigation service implementation using GoRouter
class _AppIntroNavigationService implements IntroNavigationService {
  final BuildContext context;

  _AppIntroNavigationService(this.context);

  @override
  void onRenterSelected() {
    context.push(AppRoutes.login);
  }

  @override
  void onLandlordSelected() {
    context.push(AppRoutes.login);
  }
}

/// App router configuration using Go Router
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.intro,
    debugLogDiagnostics: true,
    routes: [
      // Intro/Welcome screen
      GoRoute(
        path: AppRoutes.intro,
        name: 'intro',
        builder: (context, state) => IntroPage.withDefaults(
          navigationService: _AppIntroNavigationService(context),
        ),
      ),
      
      // Login screen
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => LoginPage(
          onSignUpPressed: () => context.push(AppRoutes.signUp),
          onForgotPasswordPressed: () => context.push(AppRoutes.forgotPassword),
          onSignIn: (email, password, rememberMe) {
            // TODO: Implement sign in logic with Bloc
            debugPrint('Sign in: $email, remember: $rememberMe');
          },
          onGoogleSignIn: () {
            // TODO: Implement Google sign in
            debugPrint('Google sign in');
          },
          onFacebookSignIn: () {
            // TODO: Implement Facebook sign in
            debugPrint('Facebook sign in');
          },
        ),
      ),
      
      // Sign Up screen
      GoRoute(
        path: AppRoutes.signUp,
        name: 'signUp',
        builder: (context, state) => SignUpPage(
          onBackPressed: () => context.pop(),
          onSignInPressed: () => context.pop(),
          onSignUp: (name, email, password) {
            // TODO: Implement sign up logic with Bloc
            debugPrint('Sign up: $name, $email');
          },
          onGoogleSignUp: () {
            // TODO: Implement Google sign up
            debugPrint('Google sign up');
          },
          onFacebookSignUp: () {
            // TODO: Implement Facebook sign up
            debugPrint('Facebook sign up');
          },
        ),
      ),
      
      // Forgot Password screen (placeholder for now)
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Forgot Password')),
          body: const Center(child: Text('Forgot Password Page - Coming Soon')),
        ),
      ),
    ],
  );
}
