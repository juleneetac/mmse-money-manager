import 'package:flutter/material.dart';
import 'dart:async';

import 'home_screen.dart';
import '../services/preferences_service.dart';

// Screen shown when user already exists
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    loadUser();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  // Load user name from storage
  void loadUser() async {
    _userName = await PreferencesService().getUserName();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Welcome again $_userName',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
