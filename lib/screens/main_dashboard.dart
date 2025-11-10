import 'package:budgetflow/screens/transactions/transactions_screen.dart';
import 'package:budgetflow/screens/home/home_screen.dart';
import 'package:budgetflow/screens/profile/profile_screen.dart';
import 'package:budgetflow/screens/projects/projects_screen.dart';
import 'package:budgetflow/utils/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    TransactionsScreen(),
    ProjectsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      extendBody: false,
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
