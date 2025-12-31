import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../models/expense_with_category.dart';
import '../screens/category_expenses_screen.dart';

/// Widget that shows total expenses per category for a selected day
class CategorySummaryList extends StatelessWidget {
  final DateTime? selectedDay;

  const CategorySummaryList({
    super.key,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedDay == null) {
      return const Center(
        child: Text('Select a day to see expenses'),
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
          return const Center(child: Text('No expenses for this day'));
        }

        // Group expenses by category
        final Map<int, List<ExpenseWithCategory>> grouped = {};

        for (final item in expenses) {
          grouped.putIfAbsent(item.category.id, () => []);
          grouped[item.category.id]!.add(item);
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          children: grouped.values.map((items) {
            final category = items.first.category;

            // Calculate total per category
            final total = items.fold<double>(
              0,
              (sum, e) => sum + e.expense.amount,
            );

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 1,
              child: InkWell(
                // Navigate to CategoryExpensesScreen
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryExpensesScreen(
                        category: category,
                        date: selectedDay!,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category name
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Category total (bigger)
                      Text(
                        '€${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
