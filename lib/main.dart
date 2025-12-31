import 'package:flutter/material.dart';
import 'services/preferences_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/welcome_back_screen.dart';

void main() {
  runApp(const MyApp());
}

// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Manager',
      theme: ThemeData(useMaterial3: true),
      home: const RootScreen(),
    );
  }
}

// This screen decides which screen to show:
// - Onboarding (first launch)
// - Welcome back (next launches)
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PreferencesService().isInitialized(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // First app launch
        if (!snapshot.data!) {
          return const OnboardingScreen();
        }

        // Returning user
        return const WelcomeScreen();
      },
    );
  }
}
