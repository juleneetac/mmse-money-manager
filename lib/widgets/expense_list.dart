import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../models/expense_with_category.dart';

/// Shows expenses for a selected day, grouped by category
class ExpenseList extends StatelessWidget {
  final DateTime? selectedDay;

  const ExpenseList({
    super.key,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    // If no day is selected, show helper message
    if (selectedDay == null) {
      return const Center(
        child: Text(
          'Select a day to see expenses',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    final db = AppDatabase();

    return StreamBuilder<List<ExpenseWithCategory>>(
      stream: db.watchExpensesForDay(selectedDay!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final expenses = snapshot.data!;

        if (expenses.isEmpty) {
          return const Center(
            child: Text(
              'No expenses for this day',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        // Group expenses by category
        final Map<String, List<ExpenseWithCategory>> grouped = {};

        for (final item in expenses) {
          grouped.putIfAbsent(item.category.name, () => []);
          grouped[item.category.name]!.add(item);
        }

        return ListView(
          padding: const EdgeInsets.all(8),
          children: grouped.entries.map((entry) {
            final categoryName = entry.key;
            final items = entry.value;

            final total = items.fold<double>(
              0,
              (sum, e) => sum + e.expense.amount,
            );

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category title + total
                    Text(
                      '$categoryName - €${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),

                    // Expenses inside category
                    ...items.map((e) {
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '€${e.expense.amount.toStringAsFixed(2)}',
                        ),
                        subtitle: e.expense.description != null
                            ? Text(e.expense.description!)
                            : null,
                      );
                    }),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
