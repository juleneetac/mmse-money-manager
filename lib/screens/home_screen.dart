import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';
import '../widgets/month_calendar.dart';
import '../widgets/month_total.dart';
import '../widgets/day_expense_detail_sheet.dart';

import 'add_expense_screen.dart';
import 'profile_screen.dart';

/// Main screen of the application
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🔑 KEY to access MonthCalendarState
  final GlobalKey<MonthCalendarState> _calendarKey =
      GlobalKey<MonthCalendarState>();

  // Current month shown in calendar
  DateTime _focusedDay = DateTime.now();

  // Selected day by the user
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Left drawer menu
      drawer: const AppDrawer(),

      appBar: AppBar(
        title: const Text('Money Manager'),

        actions: [
          // profile button
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),

      // Button to add a new expense
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_selectedDay == null) return;

          // Open Add Expense screen
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(selectedDate: _selectedDay!),
            ),
          );

          // 🔴 FORCE calendar refresh after adding expense
          _calendarKey.currentState?.refreshMonth();
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          // Monthly total widget
          MonthTotal(focusedDay: _focusedDay),

          // Monthly calendar widget
          MonthCalendar(
            key: _calendarKey,
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            onDaySelected: (day) {
              setState(() {
                _selectedDay = day;
                _focusedDay = day;
              });

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: DayExpenseDetailSheet(day: day),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
