import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../services/category_service.dart';
import '../services/preferences_service.dart';

/// Placeholder screen for categories management
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late final CategoryService categoryService;

  @override
  void initState() {
    super.initState();
    categoryService = CategoryService(AppDatabase(), PreferencesService());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),

      body: FutureBuilder<List<Category>>(
        future: categoryService.getCategories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!;

          return ListView.separated(
            itemCount: categories.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final category = categories[index];

              return ListTile(
                leading: CircleAvatar(backgroundColor: Color(category.color)),
                title: Text(category.name),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await _showAddCategoryDialog(context);

          if (!context.mounted) return;

          if (result == false) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('NOT ADDED. Category already exists'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          if (result == true) {
            setState(() {}); // refresh list
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<bool?> _showAddCategoryDialog(BuildContext context) async {
    final nameController = TextEditingController();

    // Define the "Wheel-style" palette (Hue-ordered)
    final List<Color> wheelPalette = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.blueGrey,
      Colors.grey,
      Colors.black,
    ];

    Color selectedColor = Colors.blue;

    return showDialog<bool>(
      context: context,
      builder: (context) {
        // Allows state updates inside the dialog (color selection)
        // Wrap with StatefulBuilder so the UI refreshes inside the dialog
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Color',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.maxFinite,
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: wheelPalette.map((color) {
                          // Check selection
                          final isSelected =
                              selectedColor.toARGB32() == color.toARGB32();

                          return GestureDetector(
                            onTap: () {
                              // Use setDialogState to refresh the dialog UI
                              setDialogState(() => selectedColor = color);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? color
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundColor: color,
                                radius: 16,
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final success = await categoryService.addCategory(
                      name: nameController.text,
                      color: selectedColor,
                    );

                    if (!context.mounted) return;

                    Navigator.pop(context, success); // Close dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
