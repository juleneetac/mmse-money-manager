import 'package:flutter/material.dart';
import 'dart:async';

import 'home_screen.dart';
import '../services/preferences_service.dart';
import '../services/category_service.dart';
import '../database/app_database.dart';

// Screen shown when user already exists
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String userName = '';
  late final CategoryService categoryService;

  @override
  void initState() {
    super.initState();
    loadUser();

    final db = AppDatabase();
    categoryService = CategoryService(db);
    categoryService.insertDefaultCategories();

    // 🔁 Navegación ORIGINAL a HomeScreen (como lo tenías tú)
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
