import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

/// Profile screen showing user information
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // Load user name from local storage
  Future<void> _loadUserName() async {
    final name = await PreferencesService().getUserName();
    if (!mounted) return;

    setState(() {
      userName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: userName.isEmpty
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This is your profile',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }
}
