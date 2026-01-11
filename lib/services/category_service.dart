import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../services/preferences_service.dart';

/// Service responsible for category-related logic
class CategoryService {
  final AppDatabase db;
  final PreferencesService prefs;

  CategoryService(this.db, this.prefs);

  /// Insert default categories in database ONLY ONCE
  Future<void> insertDefaultCategoriesIfNeeded() async {
    final alreadyInserted = await prefs.areDefaultCategoriesInserted();

    if (alreadyInserted) return;

    await db.batch((batch) {
      batch.insertAll(db.categories, [
        CategoriesCompanion.insert(name: 'Food', color: Colors.red.toARGB32()),
        CategoriesCompanion.insert(
          name: 'Party',
          color: Colors.purple.toARGB32(),
        ),
        CategoriesCompanion.insert(
          name: 'Travel',
          color: Colors.blue.toARGB32(),
        ),
        CategoriesCompanion.insert(
          name: 'Flights',
          color: Colors.indigo.toARGB32(),
        ),
        CategoriesCompanion.insert(
          name: 'Clothes',
          color: Colors.green.toARGB32(),
        ),
      ]);
    });
    await prefs.markDefaultCategoriesInserted();
  }

  /// Get all categories
  Future<List<Category>> getCategories() {
    return db.getAllCategories();
  }

  /// Add a new category
  Future<bool> addCategory({required String name, required Color color}) async {
    final formattedName = _formatCategoryName(name);

    if (formattedName.isEmpty) return false;

    // Prevent duplicates
    if (await categoryExists(formattedName)) {
      return false;
    }

    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: formattedName,
            color: color.toARGB32(),
          ),
        );

    return true;
  }

  // Helper to format category name
  String _formatCategoryName(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) return trimmed;

    final lower = trimmed.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  // Helper to check if a category already exists
  Future<bool> categoryExists(String name) async {
    final formatted = _formatCategoryName(name);
    return db.rawCategoryExists(formatted);
  }
}
