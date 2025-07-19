import 'package:flutter/material.dart';
import 'package:shiftsense/screens/current_shift_screen.dart';
import 'package:shiftsense/screens/vacation_screen.dart';
import 'package:shiftsense/screens/annual_overview_screen.dart';
import 'package:shiftsense/screens/employees_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const CurrentShiftScreen(),
    const VacationScreen(),
    const AnnualOverviewScreen(),
    const EmployeesScreen(),
  ];

  final List<String> _titles = [
    'Turnos Actuales',
    'Vacaciones',
    'Resumen',
    'Equipo',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Turnos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.beach_access),
            label: 'Vacaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Resumen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Equipo',
          ),
        ],
      ),
    );
  }
}
