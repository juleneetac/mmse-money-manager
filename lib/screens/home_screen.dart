import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/month_calendar.dart';
import '../widgets/category_summary_list.dart';
import '../widgets/month_total.dart';
import 'add_expense_screen.dart';
import 'profile_screen.dart';
import 'dashboard_screen.dart';

/// Main screen of the application
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
          // 🔹 Botón Dashboard
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: 'Dashboard',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),

          // 🔹 Botón Perfil (el que ya tenías)
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
        onPressed: () {
          if (_selectedDay == null) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(selectedDate: _selectedDay!),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          // Monthly total widget
          MonthTotal(focusedDay: _focusedDay),

          // Monthly calendar widget
          MonthCalendar(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            onDaySelected: (day) {
              setState(() {
                _selectedDay = day;
                _focusedDay = day;
              });
            },
          ),

          // List of expenses for selected day
          Expanded(child: CategorySummaryList(selectedDay: _selectedDay)),
        ],
      ),
    );
  }
}
