import 'package:flutter/material.dart';

import '../screens/dashboard_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/splitwise_screen.dart';

// Left side navigation drawer
class AppDrawer extends StatelessWidget {
  final String userName;

  const AppDrawer({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // =====================
            // HEADER (TITLE + USER)
            // =====================
            DrawerHeader(
              margin: EdgeInsets.zero,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Dashboard
            ListTile(
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              },
            ),

            // Categories
            ListTile(
              title: const Text('Categories'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                );
              },
            ),

            // Splitwise
            ListTile(
              title: const Text('Splitwise'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SplitwiseScreen()),
                );
              },
            ),

            const Spacer(),

            const Divider(),

            // App version
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('App Version'),
              trailing: const Text('1.0.0'),
            ),

            // Licenses
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Licenses'),
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: 'Money Manager',
                  applicationVersion: '1.0.0',
                );
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
