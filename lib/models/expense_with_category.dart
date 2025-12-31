// lib/models/expense_with_category.dart

import 'package:myapp/database/app_database.dart';

/// Helper model to combine an expense with its category
class ExpenseWithCategory {
  final Expense expense;
  final Category category;

  ExpenseWithCategory({
    required this.expense,
    required this.category,
  });
}
