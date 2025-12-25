import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation.dart/intro_page_container.dart';
import '../../features/authentication/pages/login_page.dart';

/// Route paths constants
class AppRoutes {
  AppRoutes._();
  
  static const String intro = '/';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
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
        builder: (context, state) => const IntroScreenContainer(),
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
      
      // Sign Up screen (placeholder for now)
      GoRoute(
        path: AppRoutes.signUp,
        name: 'signUp',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Sign Up')),
          body: const Center(child: Text('Sign Up Page - Coming Soon')),
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
