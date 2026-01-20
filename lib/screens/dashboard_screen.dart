import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../database/app_database.dart';

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
      // 1. Wrap the body in SafeArea
      body: SafeArea(
        child: Padding(
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
                  return _SummaryCard(
                    title: 'Total expenses this month',
                    value: snapshot.data ?? 0.0,
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

              // Pie chart
              SizedBox(
                height: 220,
                child: StreamBuilder<Map<Category, double>>(
                  stream: db.watchCategoryTotalsForMonth(
                    startOfMonth,
                    endOfMonth,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No expenses for this month'),
                      );
                    }
                    return _CategoryPieChart(data: snapshot.data!);
                  },
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Monthly expenses (full year)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // 2. Expanded now respects the bottom SafeArea,
              // so the chart labels won't be hidden.
              Expanded(
                child: _YearlyBarChart(db: db, year: selectedMonth.year),
              ),
            ],
          ),
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
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Month & Year'),
              content: Row(
                children: [
                  // Year Dropdown
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Year'),
                      initialValue: tempYear,
                      items: List.generate(10, (i) {
                        final year = DateTime.now().year - i;
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }),
                      onChanged: (v) => setDialogState(() => tempYear = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Month Dropdown
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Month'),
                      initialValue: tempMonth,
                      items: List.generate(12, (i) {
                        final m = i + 1;
                        return DropdownMenuItem(
                          value: m,
                          child: Text(
                            DateFormat.MMMM().format(DateTime(2000, m)),
                          ),
                        );
                      }),
                      onChanged: (v) => setDialogState(() => tempMonth = v!),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, DateTime(tempYear, tempMonth)),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => selectedMonth = result);
    }
  }
}

// =======================
// Widgets
// =======================

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

class _CategoryPieChart extends StatefulWidget {
  final Map<Category, double> data;

  const _CategoryPieChart({required this.data});

  @override
  State<_CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<_CategoryPieChart> {
  // Keeps track of which section is currently clicked/hovered
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final entries = widget.data.entries.toList();

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        centerSpaceRadius: 50,
        sectionsSpace: 2,
        sections: List.generate(entries.length, (i) {
          final isTouched = i == touchedIndex;
          final entry = entries[i];

          // Dynamic styling based on touch
          final fontSize = isTouched ? 16.0 : 11.0;
          final radius = isTouched ? 80.0 : 70.0;
          //final widgetSize = isTouched ? 55.0 : 40.0;

          return PieChartSectionData(
            color: Color(entry.key.color),
            value: entry.value,
            // Show name normally, or amount when clicked
            title: isTouched
                ? '${entry.value.toStringAsFixed(2)}€'
                : entry.key.name,
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
            ),
          );
        }),
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
    return StreamBuilder<List<double>>(
      stream: db.watchYearlyTotals(year),
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
                  getTitlesWidget: (value, _) {
                    final i = value.toInt();
                    if (i < 0 || i > 11) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        monthInitials[i],
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
