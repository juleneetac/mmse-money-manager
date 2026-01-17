import 'package:drift/drift.dart';
import '../database/app_database.dart';

/// Service responsible for expense-related database logic
class ExpenseService {
  final AppDatabase db;

  ExpenseService(this.db);

  /// Save a new expense into the database
  Future<void> saveExpense({
    required double amount,
    String? description,
    required int categoryId,
    required DateTime date,
  }) async {
    await db.insertExpense(
      ExpensesCompanion.insert(
        amount: amount,
        description: Value(description),
        date: date,
        categoryId: categoryId,
      ),
    );
  }


  /// Update an existing expense
  Future<void> updateExpense(Expense expense, {
    required double amount,
    String? description,
    required int categoryId,
    required DateTime date,
  }) async {
    await db.updateExpense(
      ExpensesCompanion(
        id: Value(expense.id), //Pass the ID to identify the row
        amount: Value(amount),
        description: Value(description),
        date: Value(date),
        categoryId: Value(categoryId),
      ),
    );
  }

  /// Delete an expense
  Future<void> deleteExpense(int id) async {
    await db.deleteExpense(id);
  }
}
