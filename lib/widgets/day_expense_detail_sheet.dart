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

      body: Column(
        children: [
          // 🔹 EXPENSE LIST
          Expanded(
            child: StreamBuilder<List<ExpenseWithCategory>>(
              stream: db.watchExpensesForDay(day),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final expenses = snapshot.data!;

                if (expenses.isEmpty) {
                  return const Center(child: Text('There is no expenses yet'));
                }

                final Map<int, List<ExpenseWithCategory>> grouped = {};

                for (final e in expenses) {
                  grouped.putIfAbsent(e.category.id, () => []).add(e);
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: grouped.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12), // Spacing between cards
                  itemBuilder: (context, index) {
                    final items = grouped.values.elementAt(index);
                    final category = items.first.category;
                    final total = items.fold<double>(
                      0,
                      (sum, e) => sum + e.expense.amount,
                    );

                    // Convert the int color from DB to a Flutter Color object
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
                          // Subtle background using
                          color: catColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border(
                            // Thick colored indicator on the left
                            left: BorderSide(color: catColor, width: 6),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        child: Row(
                          children: [
                            // Category Icon/Circle
                            CircleAvatar(backgroundColor: catColor, radius: 6),
                            const SizedBox(width: 10),
                            // Category Name
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
                            // The Big Bold Price with Arrow next to it
                            Row(
                              mainAxisSize: MainAxisSize
                                  .min, // Takes only as much space as needed
                              crossAxisAlignment: CrossAxisAlignment
                                  .center, // Aligns arrow to the middle of the text
                              children: [
                                Text(
                                  '€${total.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(
                                  width: 6,
                                ), // Space between number and arrow
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size:
                                      14, // Slightly larger for better visibility next to big text
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
          ),
        ],
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
  }
}
