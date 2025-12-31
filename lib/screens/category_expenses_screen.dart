import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../models/expense_with_category.dart';

/// Screen that shows all expenses of a category for a specific day
class CategoryExpensesScreen extends StatelessWidget {
  final Category category;

  final DateTime date;

  const CategoryExpensesScreen({
    super.key,
    required this.category,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase();

    return Scaffold(
      appBar: AppBar(
        // Show category name in the app bar
        title: Text(category.name),
      ),

      body: StreamBuilder<List<ExpenseWithCategory>>(
        // Reuse same stream, filtered later by category
        stream: db.watchExpensesForDay(date),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Keep only expenses that belong to this category
          final expenses = snapshot.data!
              .where((e) => e.category.id == category.id)
              .toList();

          if (expenses.isEmpty) {
            return const Center(child: Text('No expenses'));
          }

          // List of expenses with amount + description
          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index].expense;

              return ListTile(
                // Expense amount
                title: Text('€${expense.amount.toStringAsFixed(2)}'),

                // Optional description
                subtitle: expense.description != null
                    ? Text(expense.description!)
                    : const Text('No description'),
              );
            },
          );
        },
      ),
    );
  }
}
