import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/core.dart';
import '../../features/authentication/authentication.dart';
import '../../features/authentication/services/auth_service_provider.dart';
import '../../features/listing_detail/listing_detail.dart';
import '../../features/messages/messages.dart';

/// Route paths constants
class AppRoutes {
  AppRoutes._();

  static const String intro = '/';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String messages = '/home/messages';
}

/// Navigation service implementation using GoRouter
class _AppIntroNavigationService implements IntroNavigationService {
  final BuildContext context;

  _AppIntroNavigationService(this.context);

  @override
  void onRenterSelected() {
    context.pushNamed('login');
  }

  @override
  void onLandlordSelected() {
    context.pushNamed('login');
  }
}

/// Error page widget for invalid routes
class ErrorPage extends StatelessWidget {
  final String message;

  const ErrorPage({
    super.key,
    this.message = 'Page not found',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.goNamed('home'),
              icon: const Icon(Icons.home),
              label: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// App router configuration using Go Router
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.intro,
    debugLogDiagnostics: true,
    // Auth guard: redirect to login if not authenticated
    redirect: (context, state) {
      final isLoggedIn = AuthServiceProvider.isAuthenticated();
      final isGoingToAuthRoute = state.matchedLocation.contains('/login') ||
          state.matchedLocation.contains('/sign-up') ||
          state.matchedLocation.contains('/forgot-password') ||
          state.matchedLocation == '/';

      // If not logged in and trying to access protected routes, go to login
      if (!isLoggedIn && !isGoingToAuthRoute) {
        return '/login';
      }

      // If logged in and trying to access auth routes, go to home
      if (isLoggedIn && isGoingToAuthRoute) {
        return '/home';
      }

      return null; // Allow navigation
    },
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
          onSignUpPressed: () => context.pushNamed('signUp'),
          onForgotPasswordPressed: () => context.pushNamed('forgotPassword'),
          onSignIn: (email, password, rememberMe) {
            // TODO: Implement sign in logic with Bloc
            debugPrint('Sign in: $email, remember: $rememberMe');
            context.goNamed('home');
          },
          onGoogleSignIn: () {
            // TODO: Implement Google sign in
            debugPrint('Google sign in');
            context.goNamed('home');
          },
          onFacebookSignIn: () {
            // TODO: Implement Facebook sign in
            debugPrint('Facebook sign in');
            context.goNamed('home');
          },
        ),
      ),

      // Sign Up screen
      GoRoute(
        path: AppRoutes.signUp,
        name: 'signUp',
        builder: (context, state) => BlocProvider(
          create: (context) => SignUpBloc(
            authService: AuthServiceProvider.getSignUpAuthService(),
          ),
          child: SignUpPage(
            onBackPressed: () => context.pop(),
            onSignInPressed: () => context.pop(),
          ),
        ),
      ),

      // Forgot Password screen
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Forgot Password')),
          body: const Center(child: Text('Forgot Password Page - Coming Soon')),
        ),
      ),

      // Main app with bottom navigation
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const MainNavigationShell(),
        routes: [
          // Search route with query parameter
          GoRoute(
            path: 'search',
            name: 'search',
            builder: (context, state) {
              final query = state.extra as String? ?? '';
              return MainNavigationShell(
                initialPageIndex: 1,
                searchQuery: query,
              );
            },
          ),

          // Listing detail route
          GoRoute(
            path: 'listing/:id',
            name: 'listingDetail',
            builder: (context, state) {
              final listing = state.extra as ListingDetail?;
              if (listing == null) {
                return const ErrorPage(
                  message: 'Listing details not found',
                );
              }
              return ListingDetailPage(listing: listing);
            },
          ),

          // Messages routes
          GoRoute(
            path: 'messages',
            name: 'messages',
            builder: (context, state) => const MessagesPage(),
            routes: [
              // Conversation detail route
              GoRoute(
                path: ':conversationId',
                name: 'conversation',
                builder: (context, state) {
                  final conversationId = state.pathParameters['conversationId'];
                  if (conversationId == null || conversationId.isEmpty) {
                    return const ErrorPage(
                      message: 'Conversation not found',
                    );
                  }
                  return ConversationDetailPage(
                    conversationId: conversationId,
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // Error/Fallback route for unmatched paths
      GoRoute(
        path: '/:unrecognized(.*)',
        builder: (context, state) => const ErrorPage(
          message: 'Page not found\nThe page you are looking for does not exist.',
        ),
      ),
    ],
  );
}
