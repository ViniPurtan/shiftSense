import 'package:flutter/material.dart';
import 'package:shiftsense/screens/debug_page.dart';
import 'package:shiftsense/screens/current_shift_screen.dart';
import 'package:shiftsense/screens/vacation_screen.dart';
import 'package:shiftsense/screens/annual_overview_screen.dart';
import 'package:shiftsense/screens/employees_screen.dart';
import 'package:shiftsense/services/supabase_shift_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _supabaseService = SupabaseShiftService();
  
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
        actions: [
          // 🔍 Botón de Debug para probar Supabase
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug Supabase',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DebugPage(),
                ),
              );
            },
          ),
          // 🔄 Botón de refresh para probar conexión rápida
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Probar conexión',
            onPressed: _testConnection,
          ),
        ],
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

  // 🧪 Método para probar conexión rápida
  Future<void> _testConnection() async {
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final result = await _supabaseService.testConnection();
      
      // Cerrar indicador de carga
      if (mounted) Navigator.pop(context);
      
      // Mostrar resultado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔌 Conexión: $result'),
            backgroundColor: result.contains('Error') 
                ? Colors.red 
                : Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Cerrar indicador de carga
      if (mounted) Navigator.pop(context);
      
      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
