import '../database/app_database.dart';

/// Service responsible for category-related logic
class CategoryService {
  final AppDatabase db;

  CategoryService(this.db);

  /// Insert default categories if database is empty
  Future<void> insertDefaultCategories() async {
    final existing = await db.getAllCategories();

    // Do nothing if categories already exist
    if (existing.isNotEmpty) return;

    await db.batch((batch) {
      batch.insertAll(db.categories, [
        CategoriesCompanion.insert(name: 'Food'),
        CategoriesCompanion.insert(name: 'Party'),
        CategoriesCompanion.insert(name: 'Travel'),
        CategoriesCompanion.insert(name: 'Flights'),
        CategoriesCompanion.insert(name: 'Clothes'),
      ]);
    });
  }

  /// Get all categories
  Future<List<Category>> getCategories() {
    return db.getAllCategories();
  }
}
