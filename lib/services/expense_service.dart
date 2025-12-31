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
}
