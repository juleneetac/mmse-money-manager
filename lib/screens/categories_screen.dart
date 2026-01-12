import 'package:flutter/material.dart';

/// Placeholder screen for categories management
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: const Center(
        child: Text(
          'Hello World from Categories Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
