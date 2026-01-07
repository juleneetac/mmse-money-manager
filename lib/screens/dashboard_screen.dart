import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../database/app_database.dart';
import '../models/expense_with_category.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AppDatabase db = AppDatabase();

  DateTime selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final endOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month / Year selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMM().format(selectedMonth),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: _openMonthYearPicker,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Monthly total
            StreamBuilder<double>(
              stream: db.watchTotalForMonth(selectedMonth),
              builder: (context, snapshot) {
                final total = snapshot.data ?? 0.0;

                return _SummaryCard(
                  title: 'Total expenses this month',
                  value: total,
                  color: Colors.red,
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Expenses by category (selected month)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // Pie chart with category colors
            SizedBox(
              height: 220,
              child: StreamBuilder<List<ExpenseWithCategory>>(
                stream: _watchExpensesForMonth(startOfMonth, endOfMonth),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No expenses for this month'),
                    );
                  }

                  final Map<String, double> categoryTotals = {};

                  for (final item in snapshot.data!) {
                    final category = item.category.name;
                    final amount = item.expense.amount;
                    categoryTotals[category] =
                        (categoryTotals[category] ?? 0) + amount;
                  }

                  return _CategoryPieChart(data: categoryTotals);
                },
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Monthly expenses (full year)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: _YearlyBarChart(db: db, year: selectedMonth.year),
            ),
          ],
        ),
      ),
    );
  }

  // Month / Year picker (only month & year)
  Future<void> _openMonthYearPicker() async {
    int tempYear = selectedMonth.year;
    int tempMonth = selectedMonth.month;

    final result = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select month'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<int>(
                value: tempYear,
                items: List.generate(10, (i) {
                  final year = DateTime.now().year - i;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
                onChanged: (value) {
                  if (value != null) tempYear = value;
                },
              ),
              DropdownButton<int>(
                value: tempMonth,
                items: List.generate(12, (i) {
                  final month = i + 1;
                  return DropdownMenuItem(
                    value: month,
                    child: Text(DateFormat.MMMM().format(DateTime(0, month))),
                  );
                }),
                onChanged: (value) {
                  if (value != null) tempMonth = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, DateTime(tempYear, tempMonth));
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedMonth = result;
      });
    }
  }

  // Expenses for selected month
  Stream<List<ExpenseWithCategory>> _watchExpensesForMonth(
    DateTime start,
    DateTime end,
  ) {
    final query = db.select(db.expenses).join([
      drift.innerJoin(
        db.categories,
        db.categories.id.equalsExp(db.expenses.categoryId),
      ),
    ])..where(db.expenses.date.isBetweenValues(start, end));

    return query.watch().map((rows) {
      return rows.map((row) {
        final expense = row.readTable(db.expenses);
        final category = row.readTable(db.categories);
        return ExpenseWithCategory(expense: expense, category: category);
      }).toList();
    });
  }
}

//////////////////////////////////////////////////////////
// Widgets
//////////////////////////////////////////////////////////

class _SummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          '${value.toStringAsFixed(2)} €',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final Map<String, double> data;

  const _CategoryPieChart({required this.data});

  // 🎨 Fixed colors per category
  static const Map<String, Color> categoryColors = {
    'Food': Colors.orange,
    'Travel': Colors.blue,
    'Party': Colors.purple,
    'Shopping': Colors.green,
    'Bills': Colors.red,
    'Health': Colors.teal,
  };

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        centerSpaceRadius: 40,
        sections: data.entries.map((entry) {
          final color = categoryColors[entry.key] ?? Colors.grey;

          return PieChartSectionData(
            value: entry.value,
            title: entry.key,
            radius: 70,
            color: color,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _YearlyBarChart extends StatelessWidget {
  final AppDatabase db;
  final int year;

  const _YearlyBarChart({required this.db, required this.year});

  static const List<String> monthInitials = [
    'J',
    'F',
    'M',
    'A',
    'M',
    'J',
    'J',
    'A',
    'S',
    'O',
    'N',
    'D',
  ];

  @override
  Widget build(BuildContext context) {
    final months = List.generate(12, (i) => DateTime(year, i + 1));

    return StreamBuilder<List<double>>(
      stream: Rx.combineLatest<double, List<double>>(
        months.map((m) => db.watchTotalForMonth(m)),
        (values) => values,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final totals = snapshot.data!;

        return BarChart(
          BarChartData(
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),

            barGroups: List.generate(12, (i) {
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: totals[i],
                    width: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }),

            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index > 11) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        monthInitials[index],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
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
