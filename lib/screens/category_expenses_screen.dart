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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.name,
              style: const TextStyle(fontSize: 18),
            ),
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

          // Filter expenses for this category
          final expenses = snapshot.data!
              .where((e) => e.category.id == category.id)
              .toList();

          if (expenses.isEmpty) {
            return const Center(child: Text('No expenses'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),

            itemCount: expenses.length,

            // Subtle separator between items
            separatorBuilder: (_, __) => const SizedBox(height: 8),

            itemBuilder: (context, index) {
              final expense = expenses[index].expense;

              return Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount (main focus)
                      Text(
                        '€${expense.amount.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 6),

                      // Description or fallback
                      Text(
                        expense.description?.isNotEmpty == true
                            ? expense.description!
                            : 'No description',
                        style: Theme.of(context).textTheme.bodyMedium,
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
