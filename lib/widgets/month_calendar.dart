import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// Monthly calendar widget used in HomeScreen
class MonthCalendar extends StatefulWidget {
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
  MonthCalendarState createState() => MonthCalendarState();
}

// ✅ STATE PÚBLICO (SIN _)
class MonthCalendarState extends State<MonthCalendar> {
  final AppDatabase db = AppDatabase();

  DateTime _focusedDay = DateTime.now();

  Map<DateTime, double> dailyTotals = {};
  double maxDailyAmount = 0;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;
    _loadMonthData(_focusedDay);
  }

  /// 🔴 Called from HomeScreen
  void refreshMonth() {
    _loadMonthData(_focusedDay);
  }

  Future<void> _loadMonthData(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    final rows = await db
        .customSelect(
          'SELECT * FROM expenses WHERE date >= ? AND date < ?',
          variables: [Variable<DateTime>(start), Variable<DateTime>(end)],
          readsFrom: {db.expenses},
        )
        .get();

    final Map<DateTime, double> totals = {};

    for (final row in rows) {
      final expense = db.expenses.map(row.data);
      final day = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );

      totals[day] = (totals[day] ?? 0) + expense.amount;
    }

    setState(() {
      dailyTotals = totals;
      maxDailyAmount = totals.values.isEmpty
          ? 0
          : totals.values.reduce((a, b) => a > b ? a : b);
    });
  }

  Color? _getDayColor(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final amount = dailyTotals[key];

    if (amount == null || maxDailyAmount == 0) return null;

    final intensity = (amount / maxDailyAmount).clamp(0.0, 1.0);

    return Color.lerp(Colors.red.shade100, Colors.red.shade900, intensity);
  }

  Widget _buildDay(DateTime day, {bool isSelected = false}) {
    final color = _getDayColor(day);

    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color == null ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      // First and last available dates
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      // Current month
      focusedDay: _focusedDay,
      // Calendar format (month only)
      calendarFormat: CalendarFormat.month,
      // Hide format button
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      // Check if a day is selected
      selectedDayPredicate: (day) =>
          widget.selectedDay != null && isSameDay(widget.selectedDay, day),
      // Handle day selection
      onDaySelected: (selected, focused) {
        widget.onDaySelected(selected);
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
        _loadMonthData(focusedDay);
      },
      // Calendar style
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
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          return _buildDay(day);
        },
        todayBuilder: (context, day, focusedDay) {
          return _buildDay(day);
        },
        selectedBuilder: (context, day, focusedDay) {
          return _buildDay(day, isSelected: true);
        },
      ),
    );
  }
}
