import 'package:flutter/material.dart';
import 'package:local_nest/features/authentication/presentation.dart/intro_page_container.dart' show IntroScreenContainer;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const IntroScreenContainer(),
    );
  }
}