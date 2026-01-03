import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/core.dart';
import '../../features/authentication/authentication.dart';
import '../../features/listing_detail/listing_detail.dart';
import '../../features/messages/messages.dart';
import '../../features/profile/pages/manage_listings_page.dart';

/// Helper class to convert AuthBloc stream to Listenable for GoRouter
class AuthBlocListenable extends ChangeNotifier {
  final AuthBloc authBloc;
  AuthState _previousState;

  AuthBlocListenable(this.authBloc) : _previousState = authBloc.state {
    authBloc.stream.listen((state) {
      if (state != _previousState) {
        _previousState = state;
        notifyListeners();
      }
    });
  }
}

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
    // Pass userType only to signup, not to login
    context.pushNamed('login', extra: 'renter');
  }

  @override
  void onLandlordSelected() {
    // Pass userType only to signup, not to login
    context.pushNamed('login', extra: 'landlord');
  }
}

/// Error page widget for invalid routes
class ErrorPage extends StatelessWidget {
  final String message;

  const ErrorPage({super.key, this.message = 'Page not found'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
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

  /// Create router with AuthBloc for reactive navigation
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: AppRoutes.intro,
      debugLogDiagnostics: true,
      refreshListenable: AuthBlocListenable(authBloc),
      // Auth guard: redirect based on AuthBloc state
      redirect: (context, state) {
        // Get AuthBloc to check authentication status
        final authState = authBloc.state;

        // Don't redirect while loading OR in initial state (waiting for auth check)
        if (authState.isLoading || authState.status == AuthStatus.initial) {
          return null;
        }

        final isAuthenticated = authState.isAuthenticated;
        final isGoingToIntro = state.matchedLocation == '/';
        final isGoingToLoginSignup =
            state.matchedLocation.contains('/login') ||
            state.matchedLocation.contains('/sign-up') ||
            state.matchedLocation.contains('/forgot-password');

        // If not authenticated and trying to access protected routes, go to intro
        if (!isAuthenticated && !isGoingToIntro && !isGoingToLoginSignup) {
          return '/';
        }

        // If authenticated and trying to access INTRO page specifically, go to home
        // This skips the intro page for returning authenticated users
        if (isAuthenticated && isGoingToIntro) {
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
          builder: (context, state) {
            final userType = state.extra as String? ?? 'renter';
            return BlocProvider(
              create: (context) => LoginBloc(
                authService: AuthServiceProvider.getLoginAuthService(),
              ),
              child: LoginPage(
                onSignUpPressed: () =>
                    context.pushNamed('signUp', extra: userType),
                onForgotPasswordPressed: () =>
                    context.pushNamed('forgotPassword'),
              ),
            );
          },
        ),

        // Sign Up screen
        GoRoute(
          path: AppRoutes.signUp,
          name: 'signUp',
          builder: (context, state) {
            final userType = state.extra as String? ?? 'renter';
            return BlocProvider(
              create: (context) => SignUpBloc(
                authService: AuthServiceProvider.getSignUpAuthService(),
              ),
              child: SignUpPage(
                userType: userType,
                onBackPressed: () => context.pop(),
                onSignInPressed: () => context.pop(),
              ),
            );
          },
        ),

        // Forgot Password screen
        GoRoute(
          path: AppRoutes.forgotPassword,
          name: 'forgotPassword',
          builder: (context, state) => const ForgotPasswordPage(),
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
                  return const ErrorPage(message: 'Listing details not found');
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
                    final conversationId =
                        state.pathParameters['conversationId'];
                    if (conversationId == null || conversationId.isEmpty) {
                      return const ErrorPage(message: 'Conversation not found');
                    }
                    return ConversationDetailPage(
                      conversationId: conversationId,
                    );
                  },
                ),
              ],
            ),

            // Manage Listings route
            GoRoute(
              path: 'manage-listings',
              name: 'manageListings',
              builder: (context, state) => const ManageListingsPage(),
            ),
          ],
        ),

        // Manage Listings route (top-level)
        GoRoute(
          path: '/manage-listings',
          name: 'manageListingsTopLevel',
          builder: (context, state) => const ManageListingsPage(),
        ),

        // Error/Fallback route for unmatched paths
        GoRoute(
          path: '/:unrecognized(.*)',
          builder: (context, state) => const ErrorPage(
            message:
                'Page not found\nThe page you are looking for does not exist.',
          ),
        ),
      ],
    );
  }
}

