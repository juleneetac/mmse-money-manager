import 'package:flutter/material.dart';

/// Placeholder screen for charts
class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts'),
      ),
      body: const Center(
        child: Text(
          'Hello World from Charts Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
