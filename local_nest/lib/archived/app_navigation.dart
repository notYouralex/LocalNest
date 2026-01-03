import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/listing_detail/listing_detail.dart';

/// Centralized navigation methods for the app
/// This removes hardcoded route strings scattered throughout the codebase
class AppNavigation {
  AppNavigation._();

  // Auth routes
  static void goToIntro(BuildContext context) {
    context.goNamed('intro');
  }

  static void goToLogin(BuildContext context) {
    context.pushNamed('login');
  }

  static void goToSignUp(BuildContext context) {
    context.pushNamed('signUp');
  }

  static void goToForgotPassword(BuildContext context) {
    context.pushNamed('forgotPassword');
  }

  // Main app routes
  static void goToHome(BuildContext context) {
    context.goNamed('home');
  }

  static void goToSearch(BuildContext context, {String? query}) {
    if (query != null && query.isNotEmpty) {
      context.pushNamed('search', extra: query);
    } else {
      context.pushNamed('search');
    }
  }

  // Listing routes
  static void goToListingDetail(BuildContext context, ListingDetail listing) {
    context.pushNamed(
      'listingDetail',
      extra: listing,
    );
  }

  // Messages routes
  static void goToMessages(BuildContext context) {
    context.pushNamed('messages');
  }

  static void goToConversation(
    BuildContext context,
    String conversationId,
  ) {
    context.pushNamed(
      'conversation',
      pathParameters: {'conversationId': conversationId},
    );
  }

  // Navigation with replacement
  static void replaceWithLogin(BuildContext context) {
    context.goNamed('login');
  }

  static void replaceWithHome(BuildContext context) {
    context.goNamed('home');
  }

  // Pop navigation
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }

  static void goBackWithResult<T>(BuildContext context, T result) {
    if (context.canPop()) {
      context.pop<T>(result);
    }
  }
}
