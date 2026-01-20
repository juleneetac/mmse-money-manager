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
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await PreferencesService().getUserName();
    if (!mounted) return;
    setState(() => _userName = name);
  }

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase();
    final backupService = BackupService(db);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      // Wrap the entire body in SafeArea
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section: User info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'User: $_userName',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const Spacer(),

            // Bottom Buttons Area
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Keeps buttons to the left
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

                  const SizedBox(height: 12),

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
      ),
    );
  }
}
