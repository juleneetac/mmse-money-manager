import 'package:flutter/material.dart';
import '../screens/charts_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/splitwise_screen.dart';

// Left side navigation drawer
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Text('Menu'),
          ),

          // Charts screen
          ListTile(
            title: const Text('Charts'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChartsScreen(),
                ),
              );
            },
          ),

          // Categories screen
          ListTile(
            title: const Text('Categories'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoriesScreen(),
                ),
              );
            },
          ),

          // Splitwise screen
          ListTile(
            title: const Text('Splitwise'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SplitwiseScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
