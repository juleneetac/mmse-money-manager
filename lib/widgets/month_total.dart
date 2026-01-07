import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/app_database.dart';

// Widget that displays the total amount spent in the selected month
class MonthTotal extends StatelessWidget {
  final DateTime focusedDay;

  const MonthTotal({super.key, required this.focusedDay});

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase();

    // Format month and year (e.g. "September 2025")
    final monthLabel = DateFormat('MMMM yyyy').format(focusedDay);

    return StreamBuilder<double>(
      stream: db.watchTotalForMonth(focusedDay),
      builder: (context, snapshot) {
        final total = snapshot.data ?? 0;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 1, // flatter look

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Month label (smaller)
                Text(
                  '$monthLabel total test:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                // Total amount (slightly emphasized)
                Text(
                  '€${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
