import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../models/expense_with_category.dart';
import '../services/expense_service.dart';
import 'edit_expense_screen.dart';

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
    final expenseService = ExpenseService(db); // Initialize service

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.name, style: const TextStyle(fontSize: 18)),
            Text(
              date.toLocal().toString().split(' ')[0],
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<ExpenseWithCategory>>(
        stream: db.watchExpensesForDay(date),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final expenses = snapshot.data!
              .where((e) => e.category.id == category.id)
              .toList();

          if (expenses.isEmpty) return const Center(child: Text('No expenses'));

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: expenses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final expenseObj =
                  expenses[index].expense; // The actual expense object

              return Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // LEFT: Expense Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '€${expenseObj.amount.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              expenseObj.description?.isNotEmpty == true
                                  ? expenseObj.description!
                                  : 'No description',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),

                      // RIGHT: Action Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // EDIT BUTTON
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.lightGreen,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditExpenseScreen(expense: expenseObj),
                                ),
                              );
                            },
                          ),

                          // DELETE BUTTON
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              // Show confirmation dialog
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Expense'),
                                  content: const Text(
                                    'Are you sure you want to delete this?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        expenseService.deleteExpense(
                                          expenseObj.id,
                                        );
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
