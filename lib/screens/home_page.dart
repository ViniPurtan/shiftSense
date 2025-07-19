import 'package:flutter/material.dart';
import 'package:shiftsense/screens/current_shift_screen.dart';
import 'package:shiftsense/screens/vacation_screen.dart';
import 'package:shiftsense/screens/annual_overview_screen.dart';
import 'package:shiftsense/screens/employees_screen.dart';
import 'package:shiftsense/services/shift_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  bool _isLoading = true;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.schedule_outlined,
      activeIcon: Icons.schedule,
      label: 'Turnos',
    ),
    NavigationItem(
      icon: Icons.beach_access_outlined,
      activeIcon: Icons.beach_access,
      label: 'Vacaciones',
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Resumen',
    ),
    NavigationItem(
      icon: Icons.people_outlined,
      activeIcon: Icons.people,
      label: 'Equipo',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _navigationItems.length, vsync: this);
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await ShiftService().initialize();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Inicializando ShiftSense...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          CurrentShiftScreen(),
          VacationScreen(),
          AnnualOverviewScreen(),
          EmployeesScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: Theme.of(context).colorScheme.surface,
          indicatorColor: Theme.of(context).colorScheme.primaryContainer,
          height: 80,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: _navigationItems.map((item) {
            final isSelected = _navigationItems.indexOf(item) == _selectedIndex;
            return NavigationDestination(
              icon: Icon(
                item.icon,
                color: isSelected 
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              selectedIcon: Icon(
                item.activeIcon,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}