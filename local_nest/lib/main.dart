import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'features/authentication/services/auth_service_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase - wrapped in try-catch for auto-initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase might already be initialized on Android via FirebaseInitProvider
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }

  // Initialize authentication services
  AuthServiceProvider.initializeFirebaseServices();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'LocalNest',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}