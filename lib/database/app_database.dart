import 'dart:io';
import 'dart:convert';
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

  // Insert a new expense (normalized without hours, only days) into database
  Future<void> insertExpense(ExpensesCompanion expense) {
    return into(
      expenses,
    ).insert(expense.copyWith(date: Value(normalizeDate(expense.date.value))));
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

  // Export all categories and expenses to a JSON string
  Future<String> exportToJson() async {
    final allCategories = await select(categories).get();
    final allExpenses = await select(expenses).get();

    final data = {
      'categories': allCategories.map((c) {
        return {'id': c.id, 'name': c.name};
      }).toList(),
      'expenses': allExpenses.map((e) {
        return {
          'id': e.id,
          'amount': e.amount,
          'description': e.description,
          'date': e.date.toIso8601String(),
          'categoryId': e.categoryId,
        };
      }).toList(),
    };

    return jsonEncode(data);
  }

  // Import database from a JSON string
  Future<void> importFromJson(String jsonString) async {
    final decoded = jsonDecode(jsonString);

    final categoriesJson = decoded['categories'] as List;
    final expensesJson = decoded['expenses'] as List;

    await transaction(() async {
      // Clear existing data
      await delete(expenses).go();
      await delete(categories).go();

      // 2Map old category IDs to new category IDs
      final Map<int, int> categoryIdMap = {};

      for (final c in categoriesJson) {
        final oldId = c['id'] as int;

        final newId = await into(
          categories,
        ).insert(CategoriesCompanion.insert(name: c['name']));

        categoryIdMap[oldId] = newId;
      }

      // Insert expenses
      for (final e in expensesJson) {
        final parsedDate = DateTime.parse(e['date']);
        await into(expenses).insert(
          ExpensesCompanion.insert(
            amount: (e['amount'] as num).toDouble(),
            description: Value(e['description'] as String?),
            date: DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
            categoryId: categoryIdMap[e['categoryId']]!,
          ),
        );
      }
    });
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

DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
