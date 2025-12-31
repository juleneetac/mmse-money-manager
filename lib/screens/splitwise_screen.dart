import 'package:flutter/material.dart';

/// Placeholder screen for splitwise feature
class SplitwiseScreen extends StatelessWidget {
  const SplitwiseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Splitwise'),
      ),
      body: const Center(
        child: Text(
          'Hello World from Splitwise Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
