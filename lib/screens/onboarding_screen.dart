import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import 'welcome_back_screen.dart';
import '../services/category_service.dart';
import '../database/app_database.dart';

// Screen shown ONLY the first time the app is opened
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title text
            const Text(
              'Welcome! What is your name?',
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 16),

            // Input field for user name
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Your name'),
            ),
            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: () async {
                // Save name only if it is not empty
                if (controller.text.isNotEmpty) {
                  final db = AppDatabase();
                  final prefs = PreferencesService();
                  final categoryService = CategoryService(db, prefs);
                  await prefs.saveUserName(controller.text);
                  await categoryService.insertDefaultCategoriesIfNeeded();

                  // Replace screen and go to welcome screen
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
