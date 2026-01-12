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
        CategoriesCompanion.insert(name: 'Food'),
        CategoriesCompanion.insert(name: 'Party'),
        CategoriesCompanion.insert(name: 'Travel'),
        CategoriesCompanion.insert(name: 'Flights'),
        CategoriesCompanion.insert(name: 'Clothes'),
      ]);
    });
    await prefs.markDefaultCategoriesInserted();
  }

  /// Get all categories
  Future<List<Category>> getCategories() {
    return db.getAllCategories();
  }
}
