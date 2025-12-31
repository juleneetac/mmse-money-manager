import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/expenses.dart';
import 'tables/categories.dart';
import '../models/expense_with_category.dart';

part 'app_database.g.dart';

/// Main Drift database
@DriftDatabase(tables: [Expenses, Categories])
class AppDatabase extends _$AppDatabase {
  // Singleton instance
  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Insert a new expense into database
  Future<void> insertExpense(ExpensesCompanion expense) {
    return into(expenses).insert(expense);
  }

  // Get all categories
  Future<List<Category>> getAllCategories() {
    return select(categories).get();
  }

  // Get expenses for a specific day with category info
  Stream<List<ExpenseWithCategory>> watchExpensesForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final query =
        select(expenses).join([
            innerJoin(categories, categories.id.equalsExp(expenses.categoryId)),
          ])
          ..where(expenses.date.isBiggerOrEqualValue(start))
          ..where(expenses.date.isSmallerThanValue(end))
          ..orderBy([OrderingTerm.asc(categories.name)]);

    // Map results to ExpenseWithCategory
    return query.watch().map((rows) {
      return rows.map((row) {
        // Use .readTable with type parameter to fix Dart type
        final expense = row.readTable(expenses);
        final category = row.readTable(categories);

        return ExpenseWithCategory(expense: expense, category: category);
      }).toList();
    });
  }

  // Calculate the total expenses of the selected month
  Stream<double> watchTotalForMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    final query = select(expenses)
      ..where((e) => e.date.isBetweenValues(start, end));

    return query.watch().map(
      (rows) => rows.fold<double>(0, (sum, e) => sum + e.amount),
    );
  }
}

/// Open local SQLite database
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'money_manager.sqlite'));
    return NativeDatabase(file);
  });
}
