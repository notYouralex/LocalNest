import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'features/authentication/services/auth_service_provider.dart';
import 'features/authentication/blocs/blocs.dart';
import 'features/favorites/bloc/favorites_cubit.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc()..add(const CheckAuthStatus());
    _router = AppRouter.createRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider(
          create: (context) => FavoritesCubit(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'LocalNest',
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}