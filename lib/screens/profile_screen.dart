import 'package:flutter/material.dart';

import '../services/preferences_service.dart';
import '../database/app_database.dart';
import '../services/backup_service.dart';

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

  Future<void> _loadUserName() async {
    final name = await PreferencesService().getUserName();
    if (!mounted) return;
    setState(() => userName = name);
  }

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase();
    final backupService = BackupService(db);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Aligns children to the left
        children: [
          // Top section: User info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'User: $userName',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          // This Expanded takes up all remaining space, pushing buttons down
          const Expanded(child: SizedBox()),

          // Bottom Buttons Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Keep buttons on the left
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await backupService.exportData(context);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data exported successfully'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Export Data'),
                ),
                const SizedBox(height: 12), // Space between buttons
                ElevatedButton.icon(
                  onPressed: () async {
                    await backupService.importData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data imported')),
                      );
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Import Data'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
