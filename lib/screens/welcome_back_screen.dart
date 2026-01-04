import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'dart:async';
import '../services/preferences_service.dart';

// Screen shown when user already exists
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    loadUser();

    // Automatically navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  // Load user name from storage
  void loadUser() async {
    userName = await PreferencesService().getUserName();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Welcome again $userName',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

