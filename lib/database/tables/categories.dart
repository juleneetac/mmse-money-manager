import 'package:drift/drift.dart';

// Expense categories table
// Can be predefined or user-created
@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Category name (Food, Travel, Party, etc.)
  TextColumn get name => text()();
}
