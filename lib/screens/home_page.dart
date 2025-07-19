import 'package:flutter/material.dart';
import 'package:shiftsense/screens/current_shift_screen.dart';
import 'package:shiftsense/screens/vacation_screen.dart';
import 'package:shiftsense/screens/annual_overview_screen.dart';
import 'package:shiftsense/screens/employees_screen.dart';
import 'package:shiftsense/services/supabase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  bool _isLoading = true;
  bool _supabaseConnected = false;
  String? _error;

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
    try {
      // Verificar conexión a Supabase
      final supabaseService = SupabaseService();
      _supabaseConnected = await supabaseService.isConnected();
      
      if (_supabaseConnected) {
        print('✅ Conectado a Supabase');
        // Intentar inicializar tablas
        try {
          await supabaseService.initializeTables();
        } catch (e) {
          print('⚠️ Error inicializando tablas (continuando en modo local): $e');
          _supabaseConnected = false;
        }
      } else {
        print('ℹ️ Funcionando en modo local');
      }
      
      // Simular carga adicional
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('⚠️ Error durante la inicialización: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo de la aplicación
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.schedule,
                  size: 50,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 40),
              
              // Indicador de carga
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              
              // Texto de carga
              Text(
                'Inicializando ShiftSense...',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Conectando con la base de datos',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Modo Sin Conexión',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No se pudo conectar a la base de datos. La aplicación funcionará en modo local.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _error = null;
                        });
                        _initializeServices();
                      },
                      child: const Text('Reintentar'),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _error = null;
                        });
                      },
                      child: const Text('Continuar sin conexión'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Aplicación cargada exitosamente
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ShiftSense',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          // Indicador de estado de conexión
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  _supabaseConnected 
                      ? Icons.cloud_done 
                      : Icons.cloud_off,
                  color: _supabaseConnected 
                      ? Colors.green 
                      : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  _supabaseConnected ? 'Online' : 'Local',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _supabaseConnected 
                        ? Colors.green 
                        : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
