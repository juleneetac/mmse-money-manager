import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
    return TableCalendar(
      // First and last available dates
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),

      // Current month
      focusedDay: focusedDay,

      // Calendar format (month only)
      calendarFormat: CalendarFormat.month,

      // Hide format button
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },

      // Check if a day is selected
      selectedDayPredicate: (day) {
        return selectedDay != null && isSameDay(selectedDay, day);
      },

      // Handle day selection
      onDaySelected: (selected, focused) {
        onDaySelected(selected);
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

      // Header style
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }
}
