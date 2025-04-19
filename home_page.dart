import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'view_report.dart';
import 'expense_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ViewReportPage(),
    ExpenseFormPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'View Report'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Expense'),
        ],
      ),
    );
  }
}
