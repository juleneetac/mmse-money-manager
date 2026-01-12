import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../models/expense_with_category.dart';
import '../screens/category_expenses_screen.dart';

class DayExpenseDetailSheet extends StatelessWidget {
  final DateTime day;

  const DayExpenseDetailSheet({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase();

    return Scaffold(
      appBar: AppBar(
        title: Text('${day.day}/${day.month}/${day.year}'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: StreamBuilder<List<ExpenseWithCategory>>(
        stream: db.watchExpensesForDay(day),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = snapshot.data!;

          if (expenses.isEmpty) {
            return const Center(child: Text('No expenses for this day'));
          }

          // 🔹 GROUP BY CATEGORY
          final Map<int, List<ExpenseWithCategory>> grouped = {};

          for (final e in expenses) {
            grouped.putIfAbsent(e.category.id, () => []).add(e);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final categoryId = grouped.keys.elementAt(index);
              final items = grouped[categoryId]!;

              final category = items.first.category;
              final total = items.fold<double>(
                0,
                (sum, e) => sum + e.expense.amount,
              );

              return ListTile(
                title: Text(category.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '€${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CategoryExpensesScreen(category: category, date: day),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
