import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:drift/drift.dart'; // NECESARIO para customSelect y Variable
import '../database/app_database.dart';

/// Monthly calendar widget used in HomeScreen
class MonthCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  const MonthCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase();

    // Start and end of current month
    final monthStart = DateTime(focusedDay.year, focusedDay.month, 1);
    final monthEnd = DateTime(focusedDay.year, focusedDay.month + 1, 1);

    return StreamBuilder<List<QueryRow>>(
      stream: db.customSelect(
        '''
        SELECT date, amount
        FROM expenses
        WHERE date >= ? AND date < ?
        ''',
        variables: [
          Variable<DateTime>(monthStart),
          Variable<DateTime>(monthEnd),
        ],
        readsFrom: {db.expenses},
      ).watch(),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? [];

        // Total spent per day
        final Map<DateTime, double> dailyTotals = {};

        for (final row in rows) {
          final date = row.read<DateTime>('date');
          final amount = row.read<num>('amount').toDouble();

          final dayKey = DateTime(date.year, date.month, date.day);
          dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + amount;
        }

        final double maxSpent = dailyTotals.values.isEmpty
            ? 0
            : dailyTotals.values.reduce((a, b) => a > b ? a : b);

        return TableCalendar(
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: focusedDay,

          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
          },

          selectedDayPredicate: (day) {
            return selectedDay != null && isSameDay(selectedDay, day);
          },

          onDaySelected: (selected, _) {
            onDaySelected(selected);
          },

          // 🔴 Custom red intensity per day
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, _) {
              final key = DateTime(day.year, day.month, day.day);
              final spent = dailyTotals[key];

              if (spent == null || maxSpent == 0) {
                return null;
              }

              final opacity = (spent / maxSpent).clamp(0.25, 1.0);

              return Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),

          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blueGrey,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),

          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
          ),
        );
      },
    );
  }
}
