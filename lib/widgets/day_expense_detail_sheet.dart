import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../models/expense_with_category.dart';
import '../screens/category_expenses_screen.dart';
import '../screens/add_expense_screen.dart';

class DayExpenseDetailSheet extends StatelessWidget {
  final DateTime day;

  const DayExpenseDetailSheet({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase();

    // 1. We move the StreamBuilder here to wrap the Scaffold
    return StreamBuilder<List<ExpenseWithCategory>>(
      stream: db.watchExpensesForDay(day),
      builder: (context, snapshot) {
        // Handle loading state
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final expenses = snapshot.data!;

        // 2. Calculate the Total for the whole day
        final dailyTotal = expenses.fold<double>(
          0,
          (sum, item) => sum + item.expense.amount,
        );

        // Group expenses by category (Your existing logic)
        final Map<int, List<ExpenseWithCategory>> grouped = {};
        for (final e in expenses) {
          grouped.putIfAbsent(e.category.id, () => []).add(e);
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                // The Date
                Text(
                  '${day.day}/${day.month}/${day.year}',
                  style: const TextStyle(fontSize: 18),
                ),
                const Spacer(),
                // The Beautiful Total Chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    // Subtle grey/blue background
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: 'Day total: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: '€${dailyTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          body: expenses.isEmpty
              ? const Center(child: Text('There are no expenses yet'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: grouped.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final items = grouped.values.elementAt(index);
                    final category = items.first.category;

                    // Total for this specific category
                    final categoryTotal = items.fold<double>(
                      0,
                      (sum, e) => sum + e.expense.amount,
                    );

                    final catColor = Color(category.color);

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryExpensesScreen(
                              category: category,
                              date: day,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border(
                            left: BorderSide(color: catColor, width: 6),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(backgroundColor: catColor, radius: 6),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '€${categoryTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_ios, size: 14),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

          // ADD EXPENSE BUTTON
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add expense'),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddExpenseScreen(selectedDate: day),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
